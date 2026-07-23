import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'blog_page.dart'; // for ArticlePage

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late SharedPreferences _prefs;
  List<dynamic> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    final list = _prefs.getStringList('bookmarks') ?? <String>[];
    setState(() {
      _bookmarks = list.map((s) => json.decode(s)).toList();
    });
  }

  String _formatDate(dynamic raw) {
    try {
      final parsed = DateTime.parse(raw.toString());
      return DateFormat('d MMMM y').format(parsed);
    } catch (_) {
      return '';
    }
  }

  Future<void> _remove(dynamic post, HomePalette palette) async {
    final raw = _prefs.getStringList('bookmarks') ?? <String>[];
    final encoded = json.encode(post);
    raw.remove(encoded);
    await _prefs.setStringList('bookmarks', raw);

    // also clear the quick flag so the icon matches everywhere
    final postId = post['id']?.toString();
    if (postId != null) {
      await _prefs.setBool(postId, false);
    }

    _loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from Saved'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: palette.accent,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _open(dynamic post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticlePage(article: post)),
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
          'Saved Blogs',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: _bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 72, color: palette.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      'No saved blogs yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap the bookmark icon on any blog to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final post = _bookmarks[i];
                final title = (post['title'] ?? '').toString();
                final imageUrl = (post['images'] != null &&
                        post['images'] is List &&
                        post['images'].isNotEmpty)
                    ? post['images'][0]['url']
                    : null;
                final date = _formatDate(post['published']);

                return Material(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _open(post),
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: imageUrl == null
                              ? Container(
                                  width: 110,
                                  height: 90,
                                  color: palette.background,
                                  child: const Icon(
                                      Icons.image_not_supported_outlined),
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 110,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 330,
                                  memCacheHeight: 270,
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 14, color: palette.textSecondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: palette.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: () => _remove(post, palette),
                          icon: Icon(Icons.bookmark_remove_outlined,
                              color: palette.accent),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
