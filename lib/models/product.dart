class Product {
  const Product({
    required this.id,
    required this.name,
    this.price,
    this.imageUrl,
    this.description,
    this.stock,
    this.category,
    this.quantity,
    this.status,
  });
  final String id;
  final String name;
  final num? price;
  final String? imageUrl;
  final String? description;
  final int? stock;
  final String? category;
  final int? quantity;
  final String? status;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? '',
    price: _num(json['price']),
    imageUrl: json['image_url']?.toString(),
    description: json['description']?.toString(),
    stock: _int(json['stock']),
    category: json['category']?.toString(),
    quantity: _int(json['quantity']),
    status: json['status']?.toString(),
  );

  /// Payload contains only editable fields observed in the API response.
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'description': description,
    'stock': stock,
    'category': category,
    'quantity': quantity,
    'status': status,
  }..removeWhere((_, value) => value == null);
  static num? _num(dynamic value) =>
      value is num ? value : num.tryParse('$value');
  static int? _int(dynamic value) =>
      value is int ? value : int.tryParse('$value');
}
