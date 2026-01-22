import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String slug;
  final String name;
  final String shortName;
  final String description;
  final String? longDescription;
  final double price;
  final double? offerPrice;
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final List<String> images;
  final double rating;
  final int totalSold;
  final int? qty;
  final String? weight;
  final String? sku;
  final List<String>? colors;
  final String? storage;

  const ProductModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.shortName,
    required this.description,
    this.longDescription,
    required this.price,
    this.offerPrice,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    required this.images,
    this.rating = 0.0,
    this.totalSold = 0,
    this.qty,
    this.weight,
    this.sku,
    this.colors,
    this.storage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle image - can be thumb_image, image, or images array
    List<String> imageList = [];
    if (json['thumb_image'] != null) {
      imageList = [json['thumb_image'].toString()];
    } else if (json['image'] != null) {
      if (json['image'] is List) {
        imageList = List<String>.from(json['image']);
      } else {
        imageList = [json['image'].toString()];
      }
    } else if (json['images'] != null) {
      imageList = List<String>.from(json['images']);
    }

    // Handle rating - averageRating from API
    double rating = 0.0;
    if (json['averageRating'] != null) {
      rating = double.tryParse(json['averageRating'].toString()) ?? 0.0;
    } else if (json['rating'] != null) {
      rating = (json['rating'] as num).toDouble();
    }

    // Handle totalSold from API
    int totalSold = 0;
    if (json['totalSold'] != null) {
      totalSold = int.tryParse(json['totalSold'].toString()) ?? 0;
    } else if (json['sold_qty'] != null) {
      totalSold = json['sold_qty'] as int;
    }

    // Handle category - can be object or ID
    String? categoryId;
    String? categoryName;
    if (json['category'] != null && json['category'] is Map) {
      categoryId = json['category']['id']?.toString();
      categoryName = json['category']['name'];
    } else if (json['category_id'] != null) {
      categoryId = json['category_id'].toString();
    }

    // Handle brand - can be object or ID
    String? brandId;
    String? brandName;
    if (json['brand'] != null && json['brand'] is Map) {
      brandId = json['brand']['id']?.toString();
      brandName = json['brand']['name'];
    } else if (json['brand_id'] != null) {
      brandId = json['brand_id'].toString();
    }

    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? json['name'] ?? '',
      description: json['short_description'] ?? json['description'] ?? '',
      longDescription: json['long_description'],
      price: (json['price'] ?? 0).toDouble(),
      offerPrice:
          json['offer_price'] != null ? (json['offer_price']).toDouble() : null,
      categoryId: categoryId,
      categoryName: categoryName,
      brandId: brandId,
      brandName: brandName,
      images: imageList,
      rating: rating,
      totalSold: totalSold,
      qty: json['qty'],
      weight: json['weight']?.toString(),
      sku: json['sku'],
      colors: json['colors'] != null ? List<String>.from(json['colors']) : null,
      storage: json['storage'] ?? json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'short_name': shortName,
      'short_description': description,
      'long_description': longDescription,
      'price': price,
      'offer_price': offerPrice,
      'category_id': categoryId,
      'brand_id': brandId,
      'thumb_image': images.isNotEmpty ? images[0] : null,
      'averageRating': rating.toString(),
      'totalSold': totalSold.toString(),
      'qty': qty,
      'weight': weight,
      'sku': sku,
      'colors': colors,
      'storage': storage,
    };
  }

  @override
  List<Object?> get props => [
        id,
        slug,
        name,
        shortName,
        description,
        longDescription,
        price,
        offerPrice,
        categoryId,
        categoryName,
        brandId,
        brandName,
        images,
        rating,
        totalSold,
        qty,
        weight,
        sku,
        colors,
        storage,
      ];
}
