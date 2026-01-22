import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String? slug;
  final String? image;
  final int? status;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.slug,
    this.image,
    this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      slug: json['slug'],
      image: json['image'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'slug': slug,
      'image': image,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, name, icon, slug, image, status];
}
