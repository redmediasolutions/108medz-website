import 'cart_persistence_stub.dart'
    if (dart.library.html) 'cart_persistence_web.dart';

abstract class CartPersistence {
  static Future<String?> readCartJson() =>
      CartPersistenceImpl.readCartJson();
  static Future<void> writeCartJson(String json) =>
      CartPersistenceImpl.writeCartJson(json);
}
