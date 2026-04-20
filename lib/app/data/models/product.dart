import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItem {
  final String id;
  final String name;
  final double price;
  final double? oldPrice;
  /// All product images (first = thumbnail / primary).
  final List<String> imageUrls;
  final double rating;
  final bool isNew;
  /// Shown in home "Featured Picks" when true (set from admin upload).
  final bool isFeatured;
  final int stock;
  final bool isActive;
  final bool isVipOnly;
  final String? category;
  final double discountPercent;
  /// Optional long text from Firestore (admin).
  final String? description;

  /// Perfume volume in ml (30 | 50 | 100 | 200). Nullable for old products.
  final int? size;

  /// Brand name (e.g. "Creed"). Nullable for old products without a brand.
  final String? brandName;

  /// Actual size shown to users (e.g. "80ml", "125ml"). Captures manual input.
  final String? unitSize;

  /// Set by Firestore on create/update (admin inventory).
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// First image for grids, cart, wishlist (legacy single-field compat).
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  const ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    this.oldPrice,
    this.rating = 4.5,
    this.isNew = false,
    this.isFeatured = false,
    this.stock = 0,
    this.isActive = true,
    this.isVipOnly = false,
    this.category,
    this.discountPercent = 0,
    this.description,
    this.size,
    this.brandName,
    this.unitSize,
    this.createdAt,
    this.updatedAt,
  });

  static List<String> _parseImageUrls(Map<String, dynamic> data) {
    final raw = data['imageUrls'];
    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    final legacy = data['imageUrl'] as String?;
    if (legacy != null && legacy.trim().isNotEmpty) {
      return [legacy.trim()];
    }
    return [];
  }

  factory ProductItem.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductItem(
      id: id,
      name: data['name'] as String? ?? 'Unnamed',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (data['oldPrice'] as num?)?.toDouble(),
      imageUrls: _parseImageUrls(data),
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
      isNew: data['isNew'] as bool? ?? false,
      isFeatured: data['isFeatured'] as bool? ?? false,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isVipOnly: data['isVipOnly'] as bool? ?? false,
      category: data['category'] as String?,
      discountPercent: (data['discountPercent'] as num?)?.toDouble() ?? 0,
      description: () {
        final d = data['description'];
        if (d is! String) return null;
        final t = d.trim();
        return t.isEmpty ? null : t;
      }(),
      size: (data['size'] as num?)?.toInt(),
      brandName: () {
        final b = data['brandName'] as String?;
        return (b == null || b.trim().isEmpty) ? null : b.trim();
      }(),
      unitSize: () {
        final u = data['unitSize'] as String?;
        return (u == null || u.trim().isEmpty) ? null : u.trim();
      }(),
      createdAt: _tsToDate(data['createdAt']),
      updatedAt: _tsToDate(data['updatedAt']),
    );
  }

  static DateTime? _tsToDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrls': imageUrls,
      // Keep first URL for any old code / exports that read only imageUrl
      'imageUrl': imageUrl,
      'rating': rating,
      'isNew': isNew,
      'isFeatured': isFeatured,
      'stock': stock,
      'isActive': isActive,
      'isVipOnly': isVipOnly,
      'category': category,
      'discountPercent': discountPercent,
      'description': description ?? '',
    };
    if (size != null) map['size'] = size;
    if (brandName != null && brandName!.isNotEmpty) map['brandName'] = brandName;
    if (unitSize != null && unitSize!.isNotEmpty) map['unitSize'] = unitSize;
    return map;
  }
}

class CategoryItem {
  final String id;
  final String label;
  final String emoji;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

class BannerData {
  final String title;
  final String subtitle;
  final String tag;

  const BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
  });
}
