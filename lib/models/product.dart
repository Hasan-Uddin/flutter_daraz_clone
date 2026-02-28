class Product {
  final int id;
  final String title;
  final double price;
  final String category;
  final String image;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      image:
          json['image'] ??
          'https://img.icons8.com/?size=500&id=j1UxMbqzPi7n&format=png&color=000000',
      rating: (json['rating']?['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
