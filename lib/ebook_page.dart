// ignore_for_file: camel_case_types

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/models/content_item.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import 'package:kltheguide/services/ad_config.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _showBuyBookDialog(BuildContext context, String bookName) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _BuyBookDialog(bookName: bookName),
  );
}

class _BuyBookDialog extends StatefulWidget {
  final String bookName;
  const _BuyBookDialog({required this.bookName});

  @override
  State<_BuyBookDialog> createState() => _BuyBookDialogState();
}

class _BuyBookDialogState extends State<_BuyBookDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration fieldDecoration(String hint, IconData icon) =>
        InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF73B5FF), size: 20),
          hintStyle: const TextStyle(color: Color(0xFF858B9B)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5B9CFF)),
          ),
          errorStyle: const TextStyle(color: Color(0xFFFF9B9B)),
        );

    return AlertDialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 360,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF101A30).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4C8AD8).withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF08101F).withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF4D91F7).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF73B5FF),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Buy Book',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 44),
                      child: Text(
                        'Fill In The Details To Order This Book',
                        style: TextStyle(
                          color: Color(0xFF858B9B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFF293B5D), height: 1),
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: fieldDecoration('Name', Icons.person_outline),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Name is required'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          fieldDecoration('Email', Icons.email_outlined),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Email is needed';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: fieldDecoration(
                          'Address', Icons.location_on_outlined),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Address is required'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: fieldDecoration(
                          'Quantity', Icons.format_list_numbered),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Quantity is required'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9BA1B0),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 4),
                        FilledButton.icon(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            FocusScope.of(context).unfocus();

                            final subject = Uri.encodeComponent(
                              'Book Order - ${widget.bookName}',
                            );
                            final body = Uri.encodeComponent([
                              'Name: ${nameController.text.trim()}',
                              'Email: ${emailController.text.trim()}',
                              'Address: ${addressController.text.trim()}',
                              'Quantity: ${quantityController.text.trim()}',
                              'Book Name: ${widget.bookName}',
                            ].join('\n'));

                            final emailUri = Uri.parse(
                              'mailto:marliantimufpiarlis@gmail.com?subject=$subject&body=$body',
                            );

                            if (!await canLaunchUrl(emailUri)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to open email app'),
                                  ),
                                );
                              }
                              return;
                            }

                            final launched = await launchUrl(emailUri);
                            if (!launched) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to open email app'),
                                  ),
                                );
                              }
                              return;
                            }

                            if (context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.send_outlined, size: 16),
                          label: const Text('Submit'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF5798F8),
                            foregroundColor: const Color(0xFF09244A),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardListWidget extends StatelessWidget {
  final List<ContentItem> data;
  final HomePalette palette;

  const CardListWidget({super.key, required this.data, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () {
              if (item.description != '') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(
                      pdfUrl: item.description,
                      pdfTitle: item.title,
                      freePages: 15,
                    ),
                  ),
                );
              } else {
                final snackBar = SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined,
                          color: Colors.white),
                      const SizedBox(width: 12),
                      const Text('PDF not available'),
                    ],
                  ),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  action: SnackBarAction(
                    label: 'Close',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          height: 220,
                          width: double.infinity,
                          memCacheHeight: 660,
                          placeholder: (context, url) => Container(
                            height: 220,
                            color: palette.card,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: palette.accent),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 220,
                            color: palette.card,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (item.description != '')
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: palette.accent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showBuyBookDialog(context, item.title),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: palette.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              size: 25,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: palette.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 25,
                            color: palette.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Ebook extends StatelessWidget {
  final List<Map<String, dynamic>> dataList = [
    {
      "name": "KL The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/kltg/KLTG44.jpg"
    },
    {
      "name": "Klang Valley 4 Locals",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/kv4l/35.jpg"
    },
    {
      "name": "Melaka The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/mktg/4.jpg"
    },
    {
      "name": "Taiping The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/tptg/1.jpg"
    },
    {
      "name": "Uzbekistan The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/uztg/3.jpg"
    },
    {
      "name": "Keningau The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/kntg/1.jpg"
    },
    {
      "name": "Tawau The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/twtg/1.jpg"
    },
    {
      "name": "Tambunan The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/tbtg/1.jpg"
    },
    {
      "name": "Hulu Selangor The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/hstg/1.jpg"
    },
    {
      "name": "Perak The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/prtg/1.jpg"
    },
    {
      "name": "Seremban The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/sbtg/1.jpg"
    },
    {
      "name": "Kuala Selangor The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/kstg/1.jpg"
    },
    {
      "name": "Kuala Langat The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/klgt/1.jpg"
    },
    {
      "name": "Kazakhstan The Guide",
      "image": "https://www.kltheguide.com.my/assets/img/ebook/kztg/1.jpg"
    },
  ];

  Ebook({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-Book',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Digital travel guides for KL and beyond',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return CardItem(
                  name: item["name"],
                  image: item["image"],
                  index: index,
                  palette: palette,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String name;
  final String image;
  final int index;
  final HomePalette palette;

  const CardItem({
    super.key,
    required this.name,
    required this.image,
    required this.index,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/ebook-$index', arguments: {
          'index': {index}
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                memCacheWidth: 540,
                memCacheHeight: 830,
                placeholder: (context, url) => Container(
                  color: palette.card,
                  child: Center(
                    child: CircularProgressIndicator(color: palette.accent),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: palette.card,
                  child: const Icon(
                    Icons.book_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 170;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: 'Read Now',
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 8 : 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.auto_stories,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      if (!compact) ...[
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Read Now',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Buy a printed copy',
                                child: Material(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        color: Colors.orangeAccent,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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

class Ebook_view extends StatefulWidget {
  final String category;
  final String name;
  const Ebook_view({super.key, required this.category, required this.name});

  @override
  State<Ebook_view> createState() => _Ebook_viewState();
}

class _Ebook_viewState extends State<Ebook_view> {
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
          widget.name,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: ApiFutureView<List<Map<String, dynamic>>>(
        load: () => fetchList('appEbook', category: widget.category),
        isEmpty: (data) => data.isEmpty,
        builder: (context, data) {
          final items = data
              .map((e) => ContentItem(
                    title: field(e, 'title'),
                    description: field(e, 'content'),
                    imageUrl: field(e, 'image'),
                  ))
              .toList();
          return CardListWidget(data: items, palette: palette);
        },
      ),
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String pdfTitle;
  final int freePages;
  const PdfViewerPage(
      {super.key,
      required this.pdfUrl,
      required this.pdfTitle,
      this.freePages = 15});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PDFViewController? _controller;
  bool _locked = false;
  int _lastAllowedPage = 0;

  void _showLockedDialog() {
    if (_locked) return; // elak dialog pop berkali-kali
    _locked = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Preview Ends Here'),
        content: Text(
          'You\'ve reached the free preview limit (${widget.freePages} pages). '
          'Buy the full book to continue reading.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // keluar dari PDF viewer
            },
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              _showBuyBookDialog(context, widget.pdfTitle);
            },
            child: const Text('Buy Book'),
          ),
        ],
      ),
    ).then((_) => _locked = false);
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
          widget.pdfTitle,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: PDF(
          swipeHorizontal: true,
          onViewCreated: (controller) {
            _controller = controller;
          },
          onPageChanged: (page, total) async {
            if (page == null) return;

            if (page >= widget.freePages) {
              await _controller?.setPage(_lastAllowedPage);
              _showLockedDialog();
            } else {
              _lastAllowedPage = page;
            }
          }).cachedFromUrl(
        widget.pdfUrl,
        placeholder: (double progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / 100,
                valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
              ),
              const SizedBox(height: 16),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: palette.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading PDF...',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        errorWidget: (dynamic error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAdBanner extends StatefulWidget {
  final dynamic index;

  const MyAdBanner({super.key, this.index});

  @override
  _MyAdBannerState createState() => _MyAdBannerState();
}

class _MyAdBannerState extends State<MyAdBanner> {
  late BannerAd _bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    MobileAds.instance.initialize();

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return AlertDialog(
      backgroundColor: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        height: _bannerAd.size.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        child: AdWidget(
          ad: _bannerAd,
        ),
      ),
      actions: [
        if (isAdLoaded)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: palette.accent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/ebook-${widget.index}',
                  arguments: {
                    'index': {widget.index}
                  });
            },
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
