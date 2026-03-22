/// Cloudinary config for image uploads.
/// Set your values from: https://console.cloudinary.com
class CloudinaryConfig {
  CloudinaryConfig._();

  /// Your Cloud Name (Dashboard → Product Environment Credentials)
  static const String cloudName = 'dpovp433m';

  /// Unsigned upload preset name (Settings → Upload → Add upload preset → Unsigned)
  static const String uploadPreset = 'mdscents_products';

  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset.isNotEmpty &&
      uploadPreset != 'YOUR_UPLOAD_PRESET';
}
