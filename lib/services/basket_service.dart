import 'package:flutter/foundation.dart';

class BasketEntry {
  final int id;
  final String title;
  final String imageUrl;
  final String apiCategory;
  final double peninsularPrice;
  final double eastPrice;
  int stock;
  int qty;

  BasketEntry({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.apiCategory,
    required this.peninsularPrice,
    required this.eastPrice,
    required this.stock,
    required this.qty,
  });
}

class BasketService extends ChangeNotifier {
  BasketService._();
  static final BasketService instance = BasketService._();

  final Map<int, BasketEntry> _items = {};

  List<BasketEntry> get items => _items.values.toList();
  int get totalQty => _items.values.fold(0, (sum, e) => sum + e.qty);

  /// Sama macam add_to_basket: tambah 1 kalau stok masih cukup.
  bool add({
    required int id,
    required String title,
    required String imageUrl,
    required String apiCategory,
    required double peninsularPrice,
    required double eastPrice,
    required int stock,
  }) {
    final existing = _items[id];
    final current = existing?.qty ?? 0;
    if (id <= 0 || stock <= current) return false;

    if (existing != null) {
      existing
        ..stock = stock
        ..qty = current + 1;
    } else {
      _items[id] = BasketEntry(
        id: id,
        title: title,
        imageUrl: imageUrl,
        apiCategory: apiCategory,
        peninsularPrice: peninsularPrice,
        eastPrice: eastPrice,
        stock: stock,
        qty: 1,
      );
    }
    notifyListeners();
    return true;
  }

  void setQty(int id, int qty) {
    final e = _items[id];
    if (e == null || qty < 1) return;
    e.qty = qty > e.stock ? e.stock : qty;
    notifyListeners();
  }

  void remove(int id) {
    if (_items.remove(id) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// Stok terkini dari API: stok 0 dibuang, qty di-clamp.
  void updateStock(int id, int stock) {
    final e = _items[id];
    if (e == null) return;
    if (stock <= 0) {
      _items.remove(id);
    } else {
      e.stock = stock;
      if (e.qty > stock) e.qty = stock;
    }
    notifyListeners();
  }
}
