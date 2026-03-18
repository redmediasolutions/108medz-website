import 'dart:convert';

import 'package:medzsite/model/cart_item.dart';
import 'package:medzsite/store/cart_persistence.dart';

class CartStore {
  static final List<CartItem> items = [];
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    await _loadFromPersistence();
  }

  static Future<void> persist() async {
    await ensureLoaded();
    final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await CartPersistence.writeCartJson(jsonString);
  }

  static Future<void> reloadFromRemote() async {
    _loaded = true;
    await _loadFromPersistence();
  }

  static Future<void> _loadFromPersistence() async {
    final jsonString = await CartPersistence.readCartJson();
    if (jsonString == null || jsonString.isEmpty) return;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        items
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e))),
          );
      }
    } catch (_) {
      // Ignore malformed storage data.
    }
  }

  static void addItem(CartItem item) {
    ensureLoaded();
    final index = items.indexWhere((p) => p.name == item.name);
    if (index != -1) {
      items[index].quantity += item.quantity;
    } else {
      items.add(item);
    }
    persist();
  }

  static void clear() {
    ensureLoaded();
    items.clear();
    persist();
  }

  static void removeItem(CartItem item) {
    ensureLoaded();
    items.remove(item);
    persist();
  }
}
