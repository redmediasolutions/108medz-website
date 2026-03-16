import 'package:medzsite/model/cart_item.dart';

class CartStore {
  static final List<CartItem> items = [];

  static void addItem(CartItem item) {
    final index = items.indexWhere((p) => p.name == item.name);
    if (index != -1) {
      items[index].quantity += item.quantity;
    } else {
      items.add(item);
    }
  }

  static void clear() {
    items.clear();
  }
}
