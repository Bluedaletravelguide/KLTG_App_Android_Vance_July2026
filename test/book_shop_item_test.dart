import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/bookShop.dart';

void main() {
  test('uses a stable basket ID when the API omits the ebook ID', () {
    final response = {
      'title': 'A Kuala Lumpur Guide',
      'stock_quantity': 5,
      'image': 'https://example.com/ebook.jpg',
    };

    final item = ShopItem.fromApi(response, apiCategory: 'OtherBooks');
    final refreshedItem =
        ShopItem.fromApi(response, apiCategory: 'OtherBooks');

    expect(item.id, greaterThan(0));
    expect(refreshedItem.id, item.id);
    expect(item.stockQuantity, 5);
  });

  test('uses the API ID when it is provided', () {
    final item = ShopItem.fromApi(
      {'id': 42, 'title': 'A Kuala Lumpur Guide', 'stock_quantity': 5},
      apiCategory: 'OtherBooks',
    );

    expect(item.id, 42);
  });
}