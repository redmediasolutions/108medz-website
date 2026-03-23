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
  final String brand;

  final bool manageStock;
  final String stockStatus;
  final int? stockQuantity;
  final bool isOutOfStock;
  final List<int> categoryIds;
  final bool isNotForSale;
  final bool canAddToCart;

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
    required this.brand,
    required this.manageStock,
    required this.stockStatus,
    required this.stockQuantity,
    required this.isOutOfStock,
    required this.categoryIds,
    required this.isNotForSale,
    required this.canAddToCart,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String salt = '';
    String packSize = '';
    String brandValue = '';

    /// 🔹 ATTRIBUTES (Salt + Pack Size)
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

    /// 🔹 META DATA (fallback like in Productsmodel)
    if (json['meta_data'] is List) {
      for (final item in json['meta_data']) {
        if (item is Map<String, dynamic>) {
          if (item['key'] == 'salt_composition' && salt.isEmpty) {
            salt = item['value']?.toString() ?? '';
          } else if (item['key'] == 'product_content' && packSize.isEmpty) {
            packSize = item['value']?.toString() ?? '';
          } else if (item['key'] == 'manufacturer') {
            brandValue = item['value']?.toString() ?? '';
          }
        }
      }
    }

    /// 🔹 BRAND
    if (json['brands'] is List && json['brands'].isNotEmpty) {
      brandValue = json['brands'][0]['name']?.toString() ?? brandValue;
    }

    /// 🔹 IMAGE
    String image = '';
    if (json['images'] != null && json['images'].isNotEmpty) {
      image = json['images'][0]['src'] ?? '';
    }

    /// 🔹 CATEGORY IDS
    final List<int> categoryIds =
        (json['categories'] as List?)
                ?.map((e) => e['id'])
                .whereType<int>()
                .toList() ??
            [];

    /// 🔹 MAIN CATEGORY NAME
    String categoryName = 'General';
    if (json['categories'] != null && json['categories'].isNotEmpty) {
      categoryName = json['categories'][0]['name'] ?? 'General';
    }

    /// 🔹 STOCK LOGIC
    final bool manageStock = json['manage_stock'] == true;

    final int? stockQuantity = json['stock_quantity'] != null
        ? int.tryParse(json['stock_quantity'].toString())
        : null;

    final String stockStatus = json['stock_status']?.toString() ?? 'instock';

    final bool isOutOfStock = manageStock
        ? (stockQuantity == null || stockQuantity < 1)
        : stockStatus != 'instock';

    /// 🔹 BUSINESS LOGIC
    final bool isNotForSale = categoryIds.contains(94);

    final bool canAddToCart =
        !(manageStock && (stockQuantity ?? 0) < 1) && !isNotForSale;

    return Product(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      regularPrice: json['regular_price'] ?? '0',
      onSale: json['on_sale'] ?? false,
      category: categoryName,
      imageUrl: image,
      salt: salt,
      packSize: packSize,
      brand: brandValue,
      manageStock: manageStock,
      stockStatus: stockStatus,
      stockQuantity: stockQuantity,
      isOutOfStock: isOutOfStock,
      categoryIds: categoryIds,
      isNotForSale: isNotForSale,
      canAddToCart: canAddToCart,
    );
  }
}