import 'package:flutter/material.dart';
import 'package:kltheguide/basket_checkout_page.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/book_basket_service.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final _basket = BookBasketService.instance;

  @override
  void initState() {
    super.initState();
    _basket.load();
  }

  Future<void> _checkout(List<BasketItem> items) async {
    final message = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => BasketCheckoutPage(items: items),
      ),
    );
    if (message != null && mounted) {
      await _basket.clear();
      if (mounted) Navigator.pop(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          'Your Basket',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _basket,
        builder: (context, _) {
          if (!_basket.isLoaded) {
            return Center(
                child: CircularProgressIndicator(color: palette.accent));
          }
          final items = _basket.items;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_basket_outlined,
                        size: 56, color: palette.textSecondary),
                    const SizedBox(height: 14),
                    Text('Your basket is empty.',
                        style: TextStyle(color: palette.textSecondary)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('Browse books'),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              for (final item in items)
                _BasketRow(
                  item: item,
                  palette: palette,
                  onQuantityChanged: (value) =>
                      _basket.setQuantity(item.id, value),
                  onRemove: () => _basket.remove(item.id),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _checkout(items),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Proceed to checkout'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Continue shopping'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.accent,
                  side: BorderSide(color: palette.accent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BasketRow extends StatelessWidget {
  final BasketItem item;
  final HomePalette palette;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _BasketRow({
    required this.item,
    required this.palette,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.imageUrl,
                  width: 66,
                  height: 94,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 66,
                    height: 94,
                    color: palette.background,
                    child: Icon(Icons.menu_book_outlined,
                        color: palette.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 4),
                    Text('${item.category} · ${item.stockQuantity} in stock',
                        style: TextStyle(
                            color: palette.textSecondary, fontSize: 11)),
                    const SizedBox(height: 10),
                    Text(
                        'Peninsular RM ${item.category == 'OtherBooks' ? '159.90' : '17.90'}',
                        style: TextStyle(
                            color: palette.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    Text(
                      'East Malaysia RM ${item.category == 'OtherBooks' ? '179.90' : '22.90'}',
                      style: TextStyle(
                          color: palette.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove from basket',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade700,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Quantity'),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Decrease quantity',
                onPressed: item.quantity > 1
                    ? () => onQuantityChanged(item.quantity - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 32,
                child: Text('${item.quantity}', textAlign: TextAlign.center),
              ),
              IconButton(
                tooltip: 'Increase quantity',
                onPressed: item.quantity < item.stockQuantity
                    ? () => onQuantityChanged(item.quantity + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
