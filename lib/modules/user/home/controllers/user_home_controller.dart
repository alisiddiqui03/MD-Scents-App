import 'package:get/get.dart';

class ProductItem {
  final String id;
  final String name;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final double rating;
  final bool isNew;

  const ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.oldPrice,
    this.rating = 4.5,
    this.isNew = false,
  });
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

class UserHomeController extends GetxController {
  final currentBannerIndex = 0.obs;
  final discountPercent = 5.0.obs;
  final selectedCategoryIndex = 0.obs;

  final banners = const [
    BannerData(
      title: 'New Collection',
      subtitle: 'Luxury Fragrances',
      tag: 'Up to 30% OFF',
    ),
    BannerData(
      title: 'Exclusive Oud',
      subtitle: 'Arabian Nights',
      tag: 'Shop Now',
    ),
    BannerData(
      title: 'Summer Bloom',
      subtitle: 'Fresh & Floral',
      tag: 'Explore',
    ),
  ];

  final categories = const [
    CategoryItem(id: '0', label: 'All', emoji: '✨'),
    CategoryItem(id: '1', label: 'Floral', emoji: '🌸'),
    CategoryItem(id: '2', label: 'Woody', emoji: '🪵'),
    CategoryItem(id: '3', label: 'Oud', emoji: '🕌'),
    CategoryItem(id: '4', label: 'Fresh', emoji: '🌊'),
    CategoryItem(id: '5', label: 'Oriental', emoji: '🌙'),
  ];

  final latestProducts = const [
    ProductItem(
      id: '1',
      name: 'Rose Elixir',
      price: 2200,
      oldPrice: 2800,
      imageUrl: 'https://picsum.photos/seed/perfume1/400/400',
      rating: 4.8,
      isNew: true,
    ),
    ProductItem(
      id: '2',
      name: 'Oud Royale',
      price: 3500,
      imageUrl: 'https://picsum.photos/seed/perfume2/400/400',
      rating: 4.9,
    ),
    ProductItem(
      id: '3',
      name: 'Aqua Marine',
      price: 1800,
      oldPrice: 2200,
      imageUrl: 'https://picsum.photos/seed/perfume3/400/400',
      rating: 4.5,
    ),
    ProductItem(
      id: '4',
      name: 'Velvet Noir',
      price: 2900,
      imageUrl: 'https://picsum.photos/seed/perfume4/400/400',
      rating: 4.7,
      isNew: true,
    ),
    ProductItem(
      id: '5',
      name: 'Jasmine Dew',
      price: 1600,
      imageUrl: 'https://picsum.photos/seed/perfume5/400/400',
      rating: 4.4,
    ),
    ProductItem(
      id: '6',
      name: 'Cedar Wood',
      price: 2100,
      oldPrice: 2500,
      imageUrl: 'https://picsum.photos/seed/perfume6/400/400',
      rating: 4.6,
    ),
  ];

  final featuredProducts = const [
    ProductItem(
      id: '7',
      name: 'Black Orchid',
      price: 4200,
      imageUrl: 'https://picsum.photos/seed/perfume7/400/400',
      rating: 5.0,
      isNew: true,
    ),
    ProductItem(
      id: '8',
      name: 'Amber Musk',
      price: 3100,
      oldPrice: 3800,
      imageUrl: 'https://picsum.photos/seed/perfume8/400/400',
      rating: 4.8,
    ),
    ProductItem(
      id: '9',
      name: 'Citrus Bloom',
      price: 1900,
      imageUrl: 'https://picsum.photos/seed/perfume9/400/400',
      rating: 4.3,
    ),
  ];

  void onBannerChanged(int index) => currentBannerIndex.value = index;
  void onCategorySelected(int index) => selectedCategoryIndex.value = index;
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
