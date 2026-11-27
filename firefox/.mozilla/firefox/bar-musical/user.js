// Firefox profile "Bar musical": music and ambient sounds (Qobuz, YouTube), on
// workspace 9. Started by Hyprland at login with
//   firefox --profile ~/.mozilla/firefox/bar-musical --name bar-musical
// --name gives its windows their own class (bar-musical), which Hyprland's
// window rule sends to workspace 9. Made on 2026-11-27 as a copy of the main
// profile (extensions, theme, logins, cookies), then signed in to Sync on its
// own: two profiles must not share one Sync device.

// Reopen the tabs of last time
user_pref("browser.startup.page", 3);
// The main profile is the default browser: don't ask
user_pref("browser.shell.checkDefaultBrowser", false);
// Its name in the account's device list once signed in to Sync
user_pref("identity.fxaccounts.account.device.name", "Bar musical");
// No welcome pages on its first start
user_pref("browser.aboutwelcome.enabled", false);
user_pref("trailhead.firstrun.didSeeAboutWelcome", true);
user_pref("datareporting.policy.firstRunURL", "");
