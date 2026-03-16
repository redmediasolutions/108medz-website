import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medzsite/model/products.dart';
import 'package:medzsite/util/server_origin.dart';
import 'config.dart';

class WooCommerceService {

  /// Fixes URL for SSR / Browser
  Uri _resolveUri(String url) {
    final base = Uri.parse(url);

    if (base.hasScheme && base.host.isNotEmpty) {
      return base;
    }

    final serverOrigin = getServerOrigin();
    if (serverOrigin != null) {
      return Uri.parse(serverOrigin).resolveUri(base);
    }

    final browserBase = Uri.base;
    if (browserBase.host.isNotEmpty) {
      return browserBase.resolveUri(base);
    }

    return base;
  }

  /// Common request builder
  Uri _buildUri(String endpoint, Map<String, String> params) {
    final base = _resolveUri("${WCConfig.baseUrl}$endpoint");

    return base.replace(
      queryParameters: {
        "consumer_key": WCConfig.consumerKey,
        "consumer_secret": WCConfig.consumerSecret,
        ...params
      },
    );
  }

  /// Fetch Categories
  Future<List<dynamic>> fetchCategories() async {
    try {
      final uri = _buildUri("products/categories", {
        "per_page": "100",
        "hide_empty": "true"
      });

      print("Fetch Categories -> $uri");

      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      print("Category Fetch failed ${response.statusCode}");
    } catch (e) {
      print("Category Fetch error: $e");
    }

    return [];
  }

  /// Fetch All Products (Pagination)
  Future<List<Product>> fetchAllProducts() async {

    List<Product> allProducts = [];
    int page = 1;
    bool hasMore = true;

    try {
      while (hasMore) {

        final uri = _buildUri("products", {
          "per_page": "100",
          "page": "$page",
          "status": "publish"
        });

        print("Fetching Products Page $page -> $uri");

        final response =
            await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {

          final List data = json.decode(response.body);

          if (data.isEmpty) {
            hasMore = false;
          } else {
            allProducts.addAll(
              data.map((e) => Product.fromJson(e)).toList(),
            );

            page++;
          }

        } else {
          print("Product Fetch failed ${response.statusCode}");
          hasMore = false;
        }
      }

    } catch (e) {
      print("Product API Error: $e");
    }

    return allProducts;
  }

  /// Fetch a single products page (useful for quicker initial renders)
  Future<List<Product>> fetchProductsPage(int page, {int perPage = 100}) async {
    try {
      final uri = _buildUri("products", {
        "per_page": "$perPage",
        "page": "$page",
        "status": "publish"
      });

      print("Fetch Products Page $page -> $uri");

      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      }

      print("Product Page Fetch failed ${response.statusCode}");
    } catch (e) {
      print("Product Page Fetch error: $e");
    }

    return [];
  }

  /// Fetch Products By Category
  Future<List<Product>> fetchProductsByCategory(int categoryId) async {

    try {

      final uri = _buildUri("products", {
        "category": "$categoryId",
        "per_page": "100",
        "status": "publish"
      });

      print("Fetch Category Products -> $uri");

      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {

        final List data = json.decode(response.body);

        return data
            .map((e) => Product.fromJson(e))
            .toList();
      }

      print("Category Product Fetch failed ${response.statusCode}");

    } catch (e) {
      print("Category Product Error: $e");
    }

    return [];
  }

  /// Fetch Single Product
  Future<Product?> fetchProduct(int productId) async {

    try {

      final uri = _buildUri("products/$productId", {});

      print("Fetch Product -> $uri");

      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {

        final data = json.decode(response.body);

        return Product.fromJson(data);
      }

      print("Single Product Fetch failed ${response.statusCode}");

    } catch (e) {
      print("Single Product Error: $e");
    }

    return null;
  }
}
