import 'storable.dart';

class Category implements Storable {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] as String? ?? 'Без категорії');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  @override
  String toString() => name;
}
