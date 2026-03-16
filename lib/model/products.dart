class Product {
  final int id;
  final String name;
  final String category;
  final String price;
  final String regularPrice;
  final bool onSale;
  final String imageUrl;

  final String salt;
  final String packSize;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.regularPrice,
    required this.onSale,
    required this.imageUrl,
    required this.salt,
    required this.packSize,
  });

  factory Product.fromJson(Map<String, dynamic> json) {

    String salt = '';
    String packSize = '';

    /// FETCH ATTRIBUTES FROM WOOCOMMERCE
    if (json['attributes'] != null) {
      for (var attr in json['attributes']) {

        if (attr['name'] == 'Salt Composition') {
          salt = (attr['options'] as List).join(', ');
        }

        if (attr['name'] == 'Pack Size') {
          packSize = (attr['options'] as List).join(', ');
        }
      }
    }

    /// IMAGE
    String image = '';
    if (json['images'] != null && json['images'].length > 0) {
      image = json['images'][0]['src'] ?? '';
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      regularPrice: json['regular_price'] ?? '0',
      onSale: json['on_sale'] ?? false,
      category: (json['categories'] as List).isNotEmpty
          ? json['categories'][0]['name']
          : 'General',
      imageUrl: image,
      salt: salt,
      packSize: packSize,
    );
  }
}