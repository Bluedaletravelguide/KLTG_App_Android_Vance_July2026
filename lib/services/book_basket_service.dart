import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketItem {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final int stockQuantity;
  final double unitPrice;
  final int quantity;

  const BasketItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.stockQuantity,
    required this.unitPrice,
    this.quantity = 1,
  });

  BasketItem copyWith({int? quantity, int? stockQuantity}) => BasketItem(
        id: id,
        title: title,
        imageUrl: imageUrl,
        category: category,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'category': category,
        'stockQuantity': stockQuantity,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory BasketItem.fromJson(Map<String, dynamic> json) => BasketItem(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['imageUrl'] as String,
        category: json['category'] as String,
        stockQuantity: (json['stockQuantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: (json['quantity'] as num).toInt(),
      );
}

class BookBasketService extends ChangeNotifier {
  BookBasketService._();

  static final BookBasketService instance = BookBasketService._();
  static const _storageKey = 'book_basket_v1';

  final Map<String, BasketItem> _items = {};
  bool _loaded = false;

  List<BasketItem> get items => List.unmodifiable(_items.values);
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        for (final row in rows) {
          final item = BasketItem.fromJson(row);
          if (item.stockQuantity > 0) {
            _items[item.id] = item.copyWith(
              quantity: item.quantity.clamp(1, item.stockQuantity),
            );
          }
        }
      } catch (_) {
        _items.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(BasketItem item) async {
    await load();
    if (item.stockQuantity < 1) return;
    final existing = _items[item.id];
    final quantity =
        ((existing?.quantity ?? 0) + 1).clamp(1, item.stockQuantity);
    _items[item.id] = item.copyWith(quantity: quantity);
    await _save();
    notifyListeners();
  }

  Future<void> setQuantity(String id, int quantity) async {
    final item = _items[id];
    if (item == null) return;
    if (quantity < 1) {
      await remove(id);
      return;
    }
    _items[id] = item.copyWith(
      quantity: quantity.clamp(1, item.stockQuantity),
    );
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    if (_items.remove(id) == null) return;
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    if (_items.isEmpty) return;
    _items.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_items.values.map((item) => item.toJson()).toList()),
    );
  }
}
