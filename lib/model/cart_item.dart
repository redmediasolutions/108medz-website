class CartItem {
  final String name;
  final String price;
  final String image;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'image': image,
        'quantity': quantity,
      };

  static CartItem fromJson(Map<String, dynamic> json) => CartItem(
        name: json['name'] as String? ?? '',
        price: json['price'] as String? ?? '',
        image: json['image'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}
