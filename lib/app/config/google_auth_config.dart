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
/// Web client (`client_type: 3`) from `android/app/google-services.json` — required on
/// Android so the ID token is minted for Firebase. Empty ⇒ `invalid-credential` / stale token.
const String kGoogleOAuthWebClientId =
    '206439401804-8385v6h910puk3p2j8rp7vj80m7fr994.apps.googleusercontent.com';
