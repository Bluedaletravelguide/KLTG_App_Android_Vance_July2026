import 'package:flutter/material.dart';
import 'package:kltheguide/basket_page.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/services/book_basket_service.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';

class ShopItem {
  final int id;
  final String title;
  final String imageUrl;
  final int stockQuantity;
  final int? year;

  const ShopItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.stockQuantity,
    this.year,
  });

  factory ShopItem.fromApi(
    Map<String, dynamic> item, {
    required String apiCategory,
  }) {
    final rawStock = item['stock'] ??
        item['stock_quantity'] ??
        item['quantity'] ??
        item['qty'];
    final rawYear =
        item['year'] ?? item['ebook_year_published'] ?? item['year_published'];
    return ShopItem(
      id: int.tryParse((item['id'] ?? item['ebook_id'])?.toString() ?? '') ?? 0,
      title: field(item, 'title'),
      imageUrl: field(item, 'image'),
      stockQuantity: int.tryParse(rawStock?.toString() ?? '') ?? 0,
      year: int.tryParse(rawYear?.toString() ?? ''),
    );
  }
}

const double _kPeninsular = 17.90;
const double _kEast = 22.90;
const double _kOtherPeninsular = 159.90;
const double _kOtherEast = 179.90;

const List<String> _defaultShipping = ['INCLUDED SHIPPING'];
const List<String> _otherBooksShipping = ['INCLUDED SHIPPING + FREE DVD'];

class ShopCategory {
  final String name;
  final String apiCategory;
  final String desc;
  final double peninsularPrice;
  final double eastPrice;
  final List<String> shippingLines;
  final int? latestYears;

  const ShopCategory({
    required this.name,
    required this.apiCategory,
    required this.desc,
    this.peninsularPrice = _kPeninsular,
    this.eastPrice = _kEast,
    this.shippingLines = _defaultShipping,
    this.latestYears,
  });

  String get eyebrow => name.toUpperCase();
}

const List<ShopCategory> _categories = [
  ShopCategory(
    name: 'KL The Guide',
    apiCategory: 'kltg',
    desc: 'Browse the latest KL The Guide books and order your printed copy.',
  ),
  ShopCategory(
    name: 'Klang Valley 4 Locals',
    apiCategory: 'kv4l',
    desc:
        'Explore our guides created for discovering the best of Klang Valley.',
  ),
  ShopCategory(
    name: 'Melaka The Guide',
    apiCategory: 'mktg',
    desc:
        'Experience the enchanting city of Melaka like never before with Melaka The Guide eBooks! Our meticulously crafted guides offer the best recommendations and insights for those seeking to explore the rich history and cultural wonders of the beautiful historical city.',
  ),
  ShopCategory(
    name: 'Taiping The Guide',
    apiCategory: 'tptg',
    desc:
        'Discover the charming town of Taiping with Taiping The Guide eBooks. Let Taiping The Guide eBooks be your companion as you embark on a remarkable journey through Taiping’s storied past and vibrant present.',
  ),
  ShopCategory(
    name: 'Uzbekistan The Guide',
    apiCategory: 'uztg',
    desc:
        'Embark on a remarkable journey to the enchanting country of Uzbekistan with Uzbekistan The Guide eBook. With just a tap of your finger, our comprehensive eBook allows you to plan and explore this beautiful country with ease.',
  ),
  ShopCategory(
    name: 'Keningau The Guide',
    apiCategory: 'kntg',
    desc:
        'Discover the ultimate travel companion for your upcoming journey to Keningau! Check our Keningau The Guide eBook, a comprehensive travel guide to help you plan and make the most of your visit to this captivating destination.',
  ),
  ShopCategory(
    name: 'Tawau The Guide',
    apiCategory: 'twtg',
    desc:
        'With one click, unlock a treasure trove of invaluable information and expert recommendations with Tawau The Guide eBook! Whether you’re a first-time visitor or a seasoned traveler, let ‘Tawau The Guide’ be your trusted companion, providing you with all the tools you need to create unforgettable memories in the mesmerizing Tawau town.',
  ),
  ShopCategory(
    name: 'Tambunan The Guide',
    apiCategory: 'tbtg',
    desc:
        'Immerse yourself in the rich culture, vibrant traditions, and breathtaking landscapes that Tambunan has to offer. From must-see attractions and hidden gems to local dining spots and off-the-beaten-path adventures, Tambunan The Guide eBook has it all!',
  ),
  ShopCategory(
    name: 'Hulu Selangor The Guide',
    apiCategory: 'hstg',
    desc:
        'Immerse yourself in the natural beauty, historical landmarks, and cultural richness of this hidden gem. Our meticulously curated eBooks provide the best guides and recommendations for those looking to explore Hulu Selangor’s unique offerings.',
  ),
  ShopCategory(
    name: 'Perak The Guide',
    apiCategory: 'prtg',
    desc:
        'Embark on an extraordinary journey through Perak’s wonders with Perak The Guide eBooks, your ultimate companion for an unforgettable experience at this beautiful state.',
  ),
  ShopCategory(
    name: 'Seremban The Guide',
    apiCategory: 'sbtg',
    desc:
        'Unlock the wonders of Seremban with Seremban The Guide eBook. Discover this charming city and everything that Seremban has to offer, right at your fingertips. Experience Seremban like a local with Seremban The Guide eBook, your virtual companion to this captivating city.',
  ),
  ShopCategory(
    name: 'Negeri Sembilan The Guide',
    apiCategory: 'nstg',
    desc:
        'Explore Negeri Sembilan with a guide made for easy planning, local discoveries, and memorable trips. From Seremban to the state\'s quieter corners, this ebook helps you find the places, flavours, and experiences that make Negeri Sembilan worth the journey.',
  ),
  ShopCategory(
    name: 'Kuala Selangor The Guide',
    apiCategory: 'kstg',
    desc:
        'Discover Kuala Selangor like never before with our comprehensive Kuala Selangor The Guide eBook! Our eBook simplifies your trip planning process, making it a breeze to organize your next unforgettable journey with just a click away.',
  ),
  ShopCategory(
    name: 'Kuala Langat The Guide',
    apiCategory: 'klgt',
    desc:
        'Explore the enchanting town of Kuala Langat with Kuala Langat The Guide. Inside our eBook, you’ll find everything you need to know to make the most of your trip in Kuala Langat!',
  ),
  ShopCategory(
    name: 'Ebooks For You',
    apiCategory: 'OtherBooks',
    desc: 'Discover more helpful guides and ebooks for your next adventure.',
    peninsularPrice: _kOtherPeninsular,
    eastPrice: _kOtherEast,
    shippingLines: _otherBooksShipping,
  ),
];

const String _excludedTitle = 'Celebrating Small Towns of Seberang Perai';

class BookShop extends StatelessWidget {
  const BookShop({super.key});

  Future<void> _openBasket(BuildContext context) async {
    final message = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BasketPage()),
    );
    // Sama macam modal "Order Received" lepas checkout (PRG)
    if (message != null && context.mounted) {
      _showOrderReceived(context, message);
    }
  }

  Future<void> _addToBasket(
    BuildContext context,
    ShopCategory category,
    ShopItem item,
  ) async {
    if (item.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Book ID is missing. Update the appEbook API response.'),
        ),
      );
      return;
    }
    await BookBasketService.instance.add(BasketItem(
      id: item.id.toString(),
      title: item.title,
      imageUrl: item.imageUrl,
      category: category.apiCategory,
      stockQuantity: item.stockQuantity,
      unitPrice: category.peninsularPrice,
    ));
    if (context.mounted) await _openBasket(context);
  }

  void _showOrderReceived(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Order Received', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 56, color: Color(0xFF027A48)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'For any enquiries, please email us at enquiry@bluedale.com.my.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
          'Book Shop',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: BookBasketService.instance,
            builder: (context, _) {
              final count = BookBasketService.instance.itemCount;
              return IconButton(
                tooltip: 'Open basket',
                onPressed: () => _openBasket(context),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    color: palette.accent,
                  ),
                ),
              );
            },
          ),
          AppBarMore(iconColor: palette.accent),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final category in _categories)
            _CategorySection(
              key: ValueKey(category.apiCategory),
              category: category,
              palette: palette,
              onAdd: (item) => _addToBasket(context, category, item),
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final ShopCategory category;
  final HomePalette palette;
  final ValueChanged<ShopItem> onAdd;

  const _CategorySection({
    super.key,
    required this.category,
    required this.palette,
    required this.onAdd,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  late Future<List<ShopItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ShopItem>> _load() async {
    final data = await fetchList(
      'appEbook',
      category: widget.category.apiCategory,
    );
    var items = data
        .map(
          (item) => ShopItem.fromApi(
            item,
            apiCategory: widget.category.apiCategory,
          ),
        )
        .where(
          (item) =>
              item.title.isNotEmpty && item.title.trim() != _excludedTitle,
        )
        .toList();

    // latest_years: ambil N tahun terbaru je
    // final n = widget.category.latestYears;
    // if (n != null) {
    //   final years = items.map((i) => i.year).whereType<int>().toSet().toList()
    //     ..sort((a, b) => b.compareTo(a));
    //   final allowed = years.take(n).toSet();
    //   if (allowed.isNotEmpty) {
    //     items = items.where((i) => allowed.contains(i.year)).toList();
    //   }
    // }
    return items;
  }

  void _retry() => setState(() => _future = _load());

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.name,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: widget.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.category.desc,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: widget.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return FutureBuilder<List<ShopItem>>(
      future: _future,
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.connectionState != ConnectionState.done) {
          body = SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(color: palette.accent),
            ),
          );
        } else if (snapshot.hasError) {
          body = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  'Could not load books.',
                  style: TextStyle(color: palette.textSecondary),
                ),
                TextButton(
                  onPressed: _retry,
                  child: Text('Retry', style: TextStyle(color: palette.accent)),
                ),
              ],
            ),
          );
        } else {
          final items = snapshot.data ?? const <ShopItem>[];
          if (items.isEmpty) return const SizedBox.shrink(); // category kosong

          body = SizedBox(
            height: 410,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) => _ShopCard(
                item: items[index],
                category: widget.category,
                palette: palette,
                onAdd: () => widget.onAdd(items[index]),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_header(), body],
          ),
        );
      },
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopItem item;
  final ShopCategory category;
  final HomePalette palette;
  final VoidCallback onAdd;

  const _ShopCard({
    required this.item,
    required this.category,
    required this.palette,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final bool inStock = item.stockQuantity > 0;
    final priceLines = [
      'Peninsular - RM ${category.peninsularPrice.toStringAsFixed(2)}',
      'East Malaysia - RM ${category.eastPrice.toStringAsFixed(2)}',
    ];

    return SizedBox(
      width: 176,
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: palette.accent,
                          value: loadingProgress.expectedTotalBytes == null
                              ? null
                              : loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.menu_book_outlined,
                      size: 48,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              for (final line in priceLines)
                Text(
                  line,
                  style: TextStyle(
                    color: palette.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              const SizedBox(height: 4),
              for (final line in category.shippingLines)
                Text(
                  line,
                  style: const TextStyle(
                    color: Color(0xFF228B22),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                inStock ? '${item.stockQuantity} books left' : 'Sold out',
                style: TextStyle(
                  color: inStock ? palette.textSecondary : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                height: 30,
                child: FilledButton(
                  onPressed: inStock ? onAdd : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    inStock ? 'ADD TO BASKET' : 'SOLD OUT',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
