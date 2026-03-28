/// Google Sign-In / Firebase Auth (federated) configuration.
///
/// **Web client ID** (ends with `.apps.googleusercontent.com`) is required on
/// Android for Firebase to receive a valid ID token. Find it in:
/// Firebase Console → Authentication → Sign-in method → Google → *Web client ID*
/// (or Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 → Web client).
///
/// After enabling Google sign-in and adding your app’s **SHA-1** (and SHA-256 for
/// some setups), re-download `android/app/google-services.json` — it should list
/// `oauth_client` entries. You can still set [kGoogleOAuthWebClientId] explicitly
/// if needed.
///
/// Leave empty only while testing; Google sign-in will often fail with
/// `invalid-credential` until this is set or `google-services.json` includes OAuth clients.
const String kGoogleOAuthWebClientId = '';
