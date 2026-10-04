// Applied by Thunderbird at every start (overrides prefs.js).
// Mail lives outside the profile, in the XDG data dir, one file per message.

// Where new accounts store their mail: IMAP accounts under imap/<server>,
// Local Folders under local/
user_pref("mail.root.imap", "/home/johnlocke/.local/share/mail/imap");
user_pref("mail.root.none", "/home/johnlocke/.local/share/mail/local");

// Maildir instead of mbox for new accounts
user_pref("mail.serverDefaultStoreContractID", "@mozilla.org/msgstore/maildirstore;1");

// New accounts keep no offline copy by default: Gmail exposes each label as a
// folder plus [Gmail]/All Mail, so syncing every folder stores a mail several
// times. Per Gmail account, only [Gmail]/All Mail is set for offline use
// (Synchronization & Storage > Advanced...). Other accounts can turn it back on.
user_pref("mail.server.default.offline_download", false);
