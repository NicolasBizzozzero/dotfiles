// ==UserScript==
// @name         X: archives of deleted posts
// @namespace    https://github.com/NicolasBizzozzero/dotfiles
// @version      1.1
// @description  When X says a post no longer exists or its author hid it, look for archived copies on the Wayback Machine and show their text. Also on demand, from the Violentmonkey menu.
// @match        https://x.com/*
// @match        https://twitter.com/*
// @match        https://mobile.twitter.com/*
// @run-at       document-idle
// @grant        GM_xmlhttpRequest
// @grant        GM_registerMenuCommand
// @grant        GM_getValue
// @grant        GM_setValue
// @connect      web.archive.org
// @downloadURL  https://raw.githubusercontent.com/NicolasBizzozzero/dotfiles/master/userscripts/x-deleted-post-archive.user.js
// @updateURL    https://raw.githubusercontent.com/NicolasBizzozzero/dotfiles/master/userscripts/x-deleted-post-archive.user.js
// ==/UserScript==

// Requires the Violentmonkey extension in Firefox.
//
// On a post's page (/USER/status/ID), once X has shown that the post doesn't
// exist any more (deleted, account suspended...) or that its author limits who
// can see it (protected account), this asks the Wayback
// Machine's CDX API for captures of it, under twitter.com, mobile.twitter.com
// and x.com: most captures of X are filed under twitter.com, and archive.org's
// simpler "available" API misses the ones that aren't HTML pages (X's are often
// JSON). A panel then shows the text of the newest capture that has it, every
// capture, and search links for archive.today and Ghostarchive, which don't
// answer scripts.
//
// Only then, or from the Violentmonkey menu ("Chercher une archive de ce post"),
// is the post's address sent to archive.org. Results are kept for a day.
// The same search from a terminal: ~/scripts/network/tweet_archive.py URL

'use strict';

const HOSTS = ['twitter.com', 'mobile.twitter.com', 'x.com'];
const CDX = 'https://web.archive.org/cdx/search/cdx';
const CACHE_HOURS = 24;
// A famous post has tens of thousands of captures: the newest ones per host,
// the first ones listed, the first ones read for the text
const CDX_LIMIT = 300;
const LISTED = 10;
const READ = 5;
// How long to wait for X to show either the post or its "doesn't exist" page
const WAIT_SECONDS = 10;
// What X writes instead of a post that is gone or hidden, in English and French
const MISSING = [
    // Protected account: only its approved followers see its posts
    /posts are protected/i,
    /posts sont protégés/i,
    /limits who can view/i,
    /limite (les personnes|qui peut)/i,
    /unable to view this post/i,
    /ne pouvez pas (voir|afficher) ce post/i,
    /only approved followers/i,
    /seul(e)?s les abonné(e)?s/i,
    /this page doesn.t exist/i,
    /cette page n.existe pas/i,
    /post (was|has been) deleted/i,
    /post a été supprimé/i,
    /this post is unavailable/i,
    /ce post (n.est pas disponible|est indisponible)/i,
    /account suspended/i,
    /compte (a été )?suspendu/i,
];

// --- Pure functions (no browser needed) ----------------------------------

// {user, id} from a path like /USER/status/ID/photo/1, or null
function postFromPath(path) {
    const match = /^\/([A-Za-z0-9_]{1,15})\/status(?:es)?\/(\d{1,25})(?:[/?#]|$)/.exec(path);
    if (!match || match[1] === 'i') return null; // /i/status/ID: no user to search with
    return { user: match[1], id: match[2] };
}

// The captures from CDX answers (one JSON table per host), one per content,
// newest first
function parseCaptures(answers, id) {
    const exact = new RegExp(`/status(?:es)?/${id}(?:[/?#]|$)`);
    const byDigest = new Map();
    for (const answer of answers) {
        for (const [timestamp, url, status, mimetype, digest] of answer.slice(1)) {
            if (exact.test(url) && !byDigest.has(digest)) {
                byDigest.set(digest, { timestamp, url, status, mimetype });
            }
        }
    }
    return [...byDigest.values()].sort((a, b) => b.timestamp.localeCompare(a.timestamp));
}

function waybackUrl(capture, raw = false) {
    return `https://web.archive.org/web/${capture.timestamp}${raw ? 'id_' : ''}/${capture.url}`;
}

// "20260924214241" (UTC) as a local date
function captureDate(timestamp) {
    const [, y, mo, d, h, mi, s] = /^(\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/.exec(timestamp);
    return new Date(Date.UTC(y, mo - 1, d, h, mi, s)).toLocaleString();
}

function findStrings(value, key, found = []) {
    if (Array.isArray(value)) {
        for (const item of value) findStrings(item, key, found);
    } else if (value && typeof value === 'object') {
        for (const [k, v] of Object.entries(value)) {
            if (k === key && typeof v === 'string') found.push(v);
            else findStrings(v, key, found);
        }
    }
    return found;
}

function decodeEntities(text) {
    const named = { amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: ' ' };
    return text.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (entity, code) => {
        if (code[0] === '#') {
            const number = code[1] === 'x' || code[1] === 'X' ? parseInt(code.slice(2), 16) : parseInt(code.slice(1), 10);
            return String.fromCodePoint(number);
        }
        return named[code.toLowerCase()] ?? entity;
    });
}

// {text, posted, author, protected} from a capture's raw content (X's JSON, or
// an old HTML page), {refusal} for a capture of X refusing to show the post,
// or null
function textOf(content) {
    let data;
    try {
        data = JSON.parse(content);
    } catch {
        data = undefined;
    }
    if (data !== undefined) {
        const post = data && typeof data === 'object' ? data.data ?? data : {};
        const text = post.note_tweet?.text || post.text || post.full_text || findStrings(data, 'full_text')[0];
        if (!text) {
            const error = Array.isArray(data?.errors) ? data.errors[0] : null;
            return error ? { refusal: error.message || error.detail || 'error' } : null;
        }
        const user = data.includes?.users?.[0] ?? {};
        // X marks where a picture sits with U+FFFC
        return { text: text.replace(/\ufffc/g, ' ').trim(), posted: post.created_at ?? null, author: user.username ?? null, protected: user.protected ?? null };
    }
    const patterns = [
        /<meta\s+property="og:description"\s+content="([^"]*)"/,
        /<meta\s+content="([^"]*)"\s+property="og:description"/,
        /<p[^>]*js-tweet-text[^>]*>([\s\S]*?)<\/p>/,
    ];
    for (const pattern of patterns) {
        const match = pattern.exec(content);
        if (match) {
            const text = decodeEntities(match[1].replace(/<[^>]+>/g, '')).trim().replace(/^[“"]|[”"]$/g, '');
            if (text) return { text, posted: null, author: null, protected: null };
        }
    }
    return null;
}

// --- Browser side ----------------------------------------------------------

function request(url) {
    return new Promise((resolve, reject) => {
        GM_xmlhttpRequest({
            url,
            timeout: 30000,
            onload: (response) => (response.status === 200 ? resolve(response.responseText) : reject(new Error(`HTTP ${response.status}`))),
            onerror: () => reject(new Error('network error')),
            ontimeout: () => reject(new Error('timeout')),
        });
    });
}

// The raw form (id_) sometimes answers 404 where the normal replay works: for
// JSON, the replay is the JSON itself
async function readCapture(capture) {
    try {
        return await request(waybackUrl(capture, true));
    } catch {
        return request(waybackUrl(capture));
    }
}

async function searchArchives(post) {
    const cached = GM_getValue(`post:${post.id}`);
    if (cached && Date.now() - cached.time < CACHE_HOURS * 3600e3) return cached;

    const answers = [];
    const failed = [];
    for (const host of HOSTS) {
        const query = new URLSearchParams({
            url: `${host}/${post.user}/status/${post.id}`,
            matchType: 'prefix', // Also ?s=20, /photo/1...
            output: 'json',
            fl: 'timestamp,original,statuscode,mimetype,digest',
            limit: String(-CDX_LIMIT), // Negative: the newest
        });
        try {
            answers.push(JSON.parse(await request(`${CDX}?${query}`)));
        } catch (error) {
            // JSON.parse fails on archive.org's "Temporarily Offline" page
            failed.push(host);
        }
    }
    if (failed.length === HOSTS.length) throw new Error("archive.org ne répond pas, réessaie plus tard");

    const captures = parseCaptures(answers, post.id);
    let content = null;
    for (const capture of captures.slice(0, READ)) {
        try {
            content = textOf(await readCapture(capture));
        } catch {
            content = null;
        }
        // A capture of X's refusal: an older capture may have the text
        if (content?.refusal) content = null;
        if (content) {
            content.capture = capture;
            break;
        }
    }
    const result = { time: Date.now(), captures, content, partial: failed.length > 0 };
    if (!result.partial) GM_setValue(`post:${post.id}`, result);
    return result;
}

const STYLE = `
    :host { all: initial; }
    .panel { position: fixed; right: 16px; bottom: 16px; z-index: 2147483647;
        width: min(420px, calc(100vw - 32px)); max-height: 70vh; overflow: auto;
        box-sizing: border-box; padding: 14px 16px; border-radius: 12px;
        font: 14px/1.4 system-ui, sans-serif; color: #e7e9ea; background: #16181c;
        border: 1px solid #2f3336; box-shadow: 0 4px 24px rgba(0, 0, 0, .5); }
    .head { display: flex; justify-content: space-between; align-items: center;
        font-weight: 700; margin-bottom: 8px; }
    button { all: unset; cursor: pointer; padding: 0 6px; font-size: 18px; color: #71767b; }
    button:hover { color: #e7e9ea; }
    .text { white-space: pre-wrap; padding: 10px 12px; margin: 8px 0;
        border-left: 3px solid #1d9bf0; background: #202327; border-radius: 4px; }
    .meta, .status { color: #71767b; font-size: 13px; }
    ul { margin: 6px 0; padding-left: 18px; }
    a { color: #1d9bf0; text-decoration: none; }
    a:hover { text-decoration: underline; }
`;

let panelHost = null;

function closePanel() {
    panelHost?.remove();
    panelHost = null;
}

function element(tag, text, attributes = {}) {
    const node = document.createElement(tag);
    if (text) node.textContent = text;
    for (const [name, value] of Object.entries(attributes)) node.setAttribute(name, value);
    return node;
}

function link(text, href) {
    return element('a', text, { href, target: '_blank', rel: 'noopener noreferrer' });
}

// The panel lives in a shadow root, styled with a constructed stylesheet: X's
// page styles can't reach it, and its CSP doesn't block it
function openPanel() {
    closePanel();
    panelHost = document.createElement('div');
    const root = panelHost.attachShadow({ mode: 'closed' });
    const sheet = new CSSStyleSheet();
    sheet.replaceSync(STYLE);
    root.adoptedStyleSheets = [sheet];
    const panel = element('div', '', { class: 'panel' });
    const head = element('div', '', { class: 'head' });
    head.append(element('span', 'Archives de ce post'));
    const close = element('button', '×', { title: 'Fermer' });
    close.addEventListener('click', closePanel);
    head.append(close);
    const body = element('div');
    panel.append(head, body);
    root.append(panel);
    document.body.append(panelHost);
    return body;
}

async function showArchives(post) {
    const body = openPanel();
    body.append(element('div', 'Recherche sur la Wayback Machine…', { class: 'status' }));
    let result;
    try {
        result = await searchArchives(post);
    } catch (error) {
        body.replaceChildren(element('div', `Échec : ${error.message}.`, { class: 'status' }));
        appendOtherArchives(body, post);
        return;
    }
    body.replaceChildren();
    const { captures, content } = result;
    if (!captures.length) {
        body.append(element('div', 'Aucune capture sur la Wayback Machine.', { class: 'status' }));
    } else {
        if (content) {
            let meta = `Capture du ${captureDate(content.capture.timestamp)}`;
            if (content.author) meta += `, par @${content.author}`;
            if (content.posted) meta += `, publié le ${new Date(content.posted).toLocaleString()}`;
            if (content.protected !== null) meta += content.protected ? ', compte alors protégé' : ', compte alors public';
            body.append(element('div', meta, { class: 'meta' }), element('div', content.text, { class: 'text' }));
        } else {
            body.append(element('div', "Aucune capture ne contient le texte : seulement la page vide de X.", { class: 'status' }));
        }
        body.append(element('div', `Wayback Machine, ${captures.length} capture(s) :`, { class: 'meta' }));
        const list = element('ul');
        for (const capture of captures.slice(0, LISTED)) {
            const item = element('li');
            item.append(link(captureDate(capture.timestamp), waybackUrl(capture)));
            list.append(item);
        }
        if (captures.length > LISTED) list.append(element('li', `et ${captures.length - LISTED} plus anciennes`));
        body.append(list);
    }
    if (result.partial) body.append(element('div', "Recherche incomplète : archive.org n'a pas toujours répondu.", { class: 'status' }));
    appendOtherArchives(body, post);
}

function appendOtherArchives(body, post) {
    body.append(element('div', 'Ailleurs, à ouvrir :', { class: 'meta' }));
    const list = element('ul');
    for (const host of ['x.com', 'twitter.com']) {
        const item = element('li');
        item.append(link(`archive.today (${host})`, `https://archive.ph/https://${host}/${post.user}/status/${post.id}`));
        list.append(item);
    }
    const ghost = element('li');
    ghost.append(link('Ghostarchive', `https://ghostarchive.org/search?term=${encodeURIComponent(`https://x.com/${post.user}/status/${post.id}`)}`));
    list.append(ghost);
    body.append(list);
}

// 'present', 'missing', or null while X is still loading
function postState(post) {
    const article = [...document.querySelectorAll('article')].find((node) =>
        node.querySelector(`a[href*="/status/${post.id}"] time`));
    if (article) return 'present';
    const column = document.querySelector('[data-testid="primaryColumn"]') ?? document.body;
    const text = column?.innerText ?? '';
    return MISSING.some((pattern) => pattern.test(text)) ? 'missing' : null;
}

let watched = null;

// X changes pages without reloading: follow the address
function onAddressChange() {
    closePanel();
    const post = postFromPath(location.pathname);
    watched = post ? `${post.user}/${post.id}` : null;
    if (!post) return;
    const key = watched;
    const started = Date.now();
    const timer = setInterval(() => {
        if (watched !== key || Date.now() - started > WAIT_SECONDS * 1000) {
            clearInterval(timer);
            return;
        }
        const state = postState(post);
        if (state) clearInterval(timer);
        if (state === 'missing') showArchives(post);
    }, 500);
}

if (typeof GM_registerMenuCommand === 'function') {
    GM_registerMenuCommand('Chercher une archive de ce post', () => {
        const post = postFromPath(location.pathname);
        if (post) showArchives(post);
        else alert("Ouvre d'abord la page d'un post (x.com/NOM/status/NUMÉRO).");
    });
    let address = '';
    setInterval(() => {
        if (location.href !== address) {
            address = location.href;
            onAddressChange();
        }
    }, 500);
}

// For tests outside the browser (node)
if (typeof module !== 'undefined') module.exports = { postFromPath, parseCaptures, textOf, waybackUrl, captureDate, decodeEntities };
