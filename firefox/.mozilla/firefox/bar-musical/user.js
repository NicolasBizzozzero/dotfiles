// Firefox profile "Bar musical": music and ambient sounds (Qobuz, YouTube), on
// workspace 9. Started by Hyprland at login with
//   firefox --profile ~/.mozilla/firefox/bar-musical --name bar-musical
// --name gives its windows their own class (bar-musical), which Hyprland's
// window rule sends to workspace 9. Its logins and extensions are its own.

// Reopen the tabs of last time
user_pref("browser.startup.page", 3);
// The main profile is the default browser: don't ask
user_pref("browser.shell.checkDefaultBrowser", false);
// No welcome pages on its first start
user_pref("browser.aboutwelcome.enabled", false);
user_pref("trailhead.firstrun.didSeeAboutWelcome", true);
user_pref("datareporting.policy.firstRunURL", "");
