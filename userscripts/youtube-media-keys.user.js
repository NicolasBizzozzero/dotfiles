// ==UserScript==
// @name         YouTube media keys: next / previous everywhere
// @namespace    https://github.com/NicolasBizzozzero/dotfiles
// @version      1.1
// @description  Next and previous video from media keys and MPRIS (waybar custom/media), in a playlist or not
// @match        https://www.youtube.com/*
// @run-at       document-start
// @grant        unsafeWindow
// @inject-into  content
// @downloadURL  https://raw.githubusercontent.com/NicolasBizzozzero/dotfiles/master/userscripts/youtube-media-keys.user.js
// @updateURL    https://raw.githubusercontent.com/NicolasBizzozzero/dotfiles/master/userscripts/youtube-media-keys.user.js
// ==/UserScript==

// Requires the Violentmonkey extension in Firefox.
//
// Outside a playlist, YouTube registers no Media Session "next"/"previous", so
// Firefox reports CanGoNext/CanGoPrevious false over MPRIS and `playerctl next`
// does nothing. This registers both, for every video:
//   next      the player's Next button: next playlist item, or the suggested video
//   previous  the player's Previous button in a playlist; otherwise the video
//             watched before in this tab, or back to the start if there is none
// YouTube clears the handlers when a video loads: its own calls for these two
// actions are ignored, and ours are set again at each video.
//
// Content mode: YouTube's CSP blocks scripts injected into the page. Calls made
// from here go to Firefox's native methods, whatever the page changes.

(function () {
    "use strict";

    // Videos watched in this tab, oldest first, to find the previous one
    const HISTORY_KEY = "media-keys-watched";

    function watched() {
        try {
            return JSON.parse(sessionStorage.getItem(HISTORY_KEY)) || [];
        } catch (e) {
            return [];
        }
    }

    function save(ids) {
        try {
            sessionStorage.setItem(HISTORY_KEY, JSON.stringify(ids.slice(-50)));
        } catch (e) {}
    }

    function currentId() {
        return location.pathname === "/watch" ? new URLSearchParams(location.search).get("v") : null;
    }

    // Arriving on the previous video (Previous, or the browser's back) moves back
    // in the list instead of adding to it
    function track() {
        const id = currentId();
        if (!id) return;
        const ids = watched();
        if (ids[ids.length - 1] === id) return;
        if (ids[ids.length - 2] === id) ids.pop();
        else ids.push(id);
        save(ids);
    }

    function visibleButton(selector) {
        const button = document.querySelector(selector);
        if (!button || button.getAttribute("aria-disabled") === "true") return null;
        return getComputedStyle(button).display === "none" ? null : button;
    }

    function next() {
        const button = visibleButton(".ytp-next-button");
        if (button) {
            button.click();
            return;
        }
        // Same as YouTube's own Shift+N shortcut
        document.dispatchEvent(new KeyboardEvent("keydown", { key: "N", code: "KeyN", keyCode: 78, shiftKey: true, bubbles: true }));
    }

    function previous() {
        const button = visibleButton(".ytp-prev-button");
        if (button) {
            button.click();
            return;
        }
        const ids = watched();
        if (ids.length >= 2) {
            location.assign("/watch?v=" + encodeURIComponent(ids[ids.length - 2]));
            return;
        }
        const video = document.querySelector("video");
        if (video) video.currentTime = 0;
    }

    // Page-side setActionHandler ignores next/previous, so YouTube can't clear ours
    function guard() {
        const page = unsafeWindow.wrappedJSObject;
        if (!page || typeof exportFunction !== "function" || !page.MediaSession) return;
        const proto = page.MediaSession.prototype;
        const original = proto.setActionHandler;
        proto.setActionHandler = exportFunction(function (action, handler) {
            if (action === "nexttrack" || action === "previoustrack") return;
            return original.call(this, action, handler);
        }, page);
    }

    function register() {
        if (!("mediaSession" in navigator)) return;
        try {
            navigator.mediaSession.setActionHandler("nexttrack", next);
            navigator.mediaSession.setActionHandler("previoustrack", previous);
        } catch (e) {}
    }

    // yt-navigate-finish: YouTube changes page without reloading it
    document.addEventListener("yt-navigate-finish", () => {
        track();
        register();
    });
    // Capturing, as media events don't bubble: after YouTube's own setup of the video
    for (const type of ["loadedmetadata", "playing"]) {
        document.addEventListener(type, register, true);
    }
    try {
        guard();
    } catch (e) {}
    track();
    register();
})();
