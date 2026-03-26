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
  final String? category;
  final double discountPercent;
  /// Optional long text from Firestore (admin).
  final String? description;

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
    this.category,
    this.discountPercent = 0,
    this.description,
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
      category: data['category'] as String?,
      discountPercent: (data['discountPercent'] as num?)?.toDouble() ?? 0,
      description: () {
        final d = data['description'];
        if (d is! String) return null;
        final t = d.trim();
        return t.isEmpty ? null : t;
      }(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'category': category,
      'discountPercent': discountPercent,
      'description': description ?? '',
    };
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
