import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:kltheguide/services/cache_service.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:kltheguide/bookmarks_page.dart';
import 'package:kltheguide/widgets/state_views.dart';

// Cached by post id so re-opening an article — even after leaving and
// returning to the Blog tab — skips the DOM walk entirely instead of
// re-sanitizing. Module-level (not State-scoped) so it survives
// BlogListScreen being disposed/recreated on every tab switch.
final Map<String, String> _sanitizedContentCache = {};

// Top-level (not a class method) so it can run on a background isolate via
// compute() — sanitizing is a synchronous full-DOM parse/walk that would
// otherwise block the UI thread for the duration of the parse.
String sanitizeHtml(String html) {
  final document = html_parser.parse(html);

  // Remove all script tags
  document.querySelectorAll('script').forEach((element) => element.remove());

  // Remove all on* event handlers (e.g., onclick, onerror)
  document.querySelectorAll('*').forEach((element) {
    final attributes = element.attributes.keys.toList();
    for (final attribute in attributes) {
      if (attribute.toString().startsWith('on')) {
        element.attributes.remove(attribute);
      }
    }

    // Also remove javascript: pseudo-protocol in href or src
    if (element.attributes.containsKey('href')) {
      final href = element.attributes['href']!.toLowerCase();
      if (href.startsWith('javascript:')) {
        element.attributes['href'] = '#';
      }
    }
    if (element.attributes.containsKey('src')) {
      final src = element.attributes['src']!.toLowerCase();
      if (src.startsWith('javascript:')) {
        element.attributes.remove('src');
      }
    }
  });

  return document.body?.innerHtml ?? '';
}

// Cheap regex strip instead of a full DOM parse (unlike sanitizeHtml above)
// so this can run synchronously on the main thread without needing compute().
int _estimateReadMinutes(String rawHtml) {
  final text = rawHtml.replaceAll(RegExp(r'<[^>]*>'), ' ');
  final wordCount =
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  return (wordCount / 200).ceil().clamp(1, 60);
}

String? _authorDisplayName(dynamic article) {
  final author = article['author'];
  if (author is Map) {
    final name = author['displayName'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
  }
  return null;
}

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<dynamic> blogPosts = [];
  String? nextPageToken;
  int maxResults = 10;
  bool isLoading = false;
  bool hasError = false;
  bool loadMoreError = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _fetchInitialBlogPosts();
    initPrefs();
  }

  String formatDate(String rawDate) {
    final parsedDate = DateTime.parse(rawDate);
    final formattedDate = DateFormat('d MMMM y').format(parsedDate);
    return formattedDate;
  }

  // Routes through the app's shared offline/stale-while-revalidate cache
  // (instead of a one-off flutter_cache_manager instance) so a poor
  // connection falls back to the last-seen page instead of failing outright.
  Future<Map<String, dynamic>> _fetchBlogPage({String? pageToken}) {
    return CacheService.cached<Map<String, dynamic>>(
      key: pageToken == null ? 'blog_page1' : 'blog_page_$pageToken',
      encode: json.encode,
      decode: (raw) => (json.decode(raw) as Map).cast<String, dynamic>(),
      fetch: () async {
        const apiKey = String.fromEnvironment('BLOGGER_API_KEY');
        const blogId = '1732826187557117921';
        final apiUrl = 'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?'
            'key=$apiKey'
            '&maxResults=$maxResults'
            '${pageToken != null ? '&pageToken=$pageToken' : ''}'
            '&fetchImages=true';

        final response =
            await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception(
            'Blogger API failed: ${response.statusCode} '
            '(key ${apiKey.isEmpty ? "MISSING" : "present, ${apiKey.length} chars"}) '
            '${response.body}',
          );
        }
        return (json.decode(response.body) as Map).cast<String, dynamic>();
      },
    );
  }

  Future<void> _fetchInitialBlogPosts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await _fetchBlogPage();
      if (!mounted) return;
      setState(() {
        blogPosts = data['items'] ?? [];
        nextPageToken = data['nextPageToken'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('BLOG LOAD FAILED >>> $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _fetchMoreBlogPosts() async {
    if (isLoading || nextPageToken == null) return;

    setState(() {
      isLoading = true;
      loadMoreError = false;
    });

    try {
      final data = await _fetchBlogPage(pageToken: nextPageToken);
      if (!mounted) return;
      setState(() {
        blogPosts.addAll(data['items'] ?? []);
        nextPageToken = data['nextPageToken'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadMoreError = true;
      });
    }
  }

  void showSnackBar(BuildContext context, String message, HomePalette palette) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            message.contains('added') ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
      backgroundColor: palette.accent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool isBookmarked(dynamic post) {
    final postId = post['id'].toString();
    return prefs.getBool(postId) ?? false;
  }

  void toggleBookmark(dynamic post, HomePalette palette) {
    final postId = post['id'].toString();
    final isBookmarked = prefs.getBool(postId) ?? false;
    Vibration.vibrate(duration: 100);
    setState(() {
      if (isBookmarked) {
        removeBookmark(post);
        prefs.setBool(postId, false);
        showSnackBar(context, 'Bookmark removed', palette);
      } else {
        addBookmark(post);
        prefs.setBool(postId, true);
        showSnackBar(context, 'Bookmark added', palette);
      }
    });
  }

  void addBookmark(dynamic post) async {
    final postId = post['id']?.toString();
    if (postId == null) return;

    final bookmarkStrings = prefs.getStringList('bookmarks') ?? <String>[];
    // Parse once and check for existing id
    final parsed = bookmarkStrings.map((s) => json.decode(s)).toList();
    final already = parsed.any((p) => (p['id']?.toString() ?? '') == postId);
    if (already) return;

    bookmarkStrings.add(json.encode(post));
    await prefs.setStringList('bookmarks', bookmarkStrings);
  }

  void removeBookmark(dynamic post) async {
    List<String>? bookmarkStrings = prefs.getStringList('bookmarks') ?? [];
    String bookmarkJson = json.encode(post);

    if (bookmarkStrings.contains(bookmarkJson)) {
      bookmarkStrings.remove(bookmarkJson);
      await prefs.setStringList('bookmarks', bookmarkStrings);
    }
  }

  void _navigateToArticlePage(dynamic article) {
    // Sanitizing is a synchronous full-DOM walk — it's done inside
    // ArticlePage on a background isolate instead of here, so tapping an
    // article never blocks the tap/transition on that work.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlePage(article: article),
      ),
    );
  }

  Widget _buildNewHeader(HomePalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blog',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Stories, tips and guides from Kuala Lumpur',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              color: palette.textSecondary,
            ),
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
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Saved Blogs',
        backgroundColor: palette.accent,
        child: const Icon(Icons.bookmarks_outlined, color: Colors.white),
        onPressed: () async {
          // Open Saved (BookmarkPage)
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookmarkPage()),
          );
          // Refresh UI on return (updates bookmark icons/count, etc.)
          if (mounted) setState(() {});
        },
      ),
      body: Column(
        children: [
          _buildNewHeader(palette),
          Expanded(
            child: blogPosts.isEmpty && hasError
                ? ErrorStateView(
                    message: 'Could not load articles.\nCheck your connection and try again.',
                    onRetry: _fetchInitialBlogPosts,
                  )
                : blogPosts.isEmpty && isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: palette.accent),
                        const SizedBox(height: 16),
                        Text(
                          'Loading articles...',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchInitialBlogPosts,
                    color: palette.accent,
                    child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: blogPosts.length + 1,
              itemBuilder: (context, index) {
                if (index == blogPosts.length) {
                  if (isLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(color: palette.accent),
                      ),
                    );
                  } else if (loadMoreError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Material(
                          color: palette.card,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: _fetchMoreBlogPosts,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: palette.card,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Couldn't load more — tap to retry",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: palette.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.refresh,
                                    color: palette.accent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (nextPageToken != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Material(
                          color: palette.card,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: _fetchMoreBlogPosts,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: palette.card,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Load More',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: palette.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.expand_circle_down_outlined,
                                    color: palette.accent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                final post = blogPosts[index];
                final imageUrl = post['images'][0]['url'];
                final formattedPublishedDate = formatDate(post['published']);
                final bookmarked = isBookmarked(post);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: () => _navigateToArticlePage(post),
                    onLongPress: () => toggleBookmark(post, palette),
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  height: 220,
                                  width: double.infinity,
                                  memCacheHeight: 660,
                                  placeholder: (context, url) => Container(
                                    height: 220,
                                    color: palette.card,
                                    child: Center(
                                      child: CircularProgressIndicator(color: palette.accent),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
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
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Material(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(25),
                                  elevation: 4,
                                  child: InkWell(
                                    onTap: () => toggleBookmark(post, palette),
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        bookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: bookmarked
                                            ? palette.accent
                                            : Colors.grey[600],
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: palette.textPrimary,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: palette.accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: palette.accent,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            formattedPublishedDate,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: palette.accent,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
            ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ArticlePage extends StatefulWidget {
  final dynamic article;

  const ArticlePage({super.key, required this.article});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // Sanitizing is a synchronous full-DOM parse/walk — running it via compute()
  // keeps it off the UI thread so the page (title + cover image) appears
  // immediately, with the article body popping in a moment later instead of
  // the whole app freezing at the tap that opened this page.
  late final Future<String> _sanitizedContent;
  late final int _readMinutes;

  SharedPreferences? _prefs;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    final postId = widget.article['id'].toString();
    final rawContent = (widget.article['content'] ?? '') as String;
    final cached = _sanitizedContentCache[postId];
    _sanitizedContent = cached != null
        ? Future.value(cached)
        : compute(sanitizeHtml, rawContent).then((sanitized) {
            _sanitizedContentCache[postId] = sanitized;
            return sanitized;
          });
    _readMinutes = _estimateReadMinutes(rawContent);
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final postId = widget.article['id'].toString();
    setState(() {
      _prefs = prefs;
      _bookmarked = prefs.getBool(postId) ?? false;
    });
  }

  // Mirrors the persistence shape BlogListScreen/BookmarkPage already use
  // (a per-id bool flag plus a JSON-encoded 'bookmarks' list) so a save here
  // shows up correctly in both places.
  Future<void> _toggleBookmark(HomePalette palette) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final post = widget.article;
    final postId = post['id'].toString();
    final nowBookmarked = !_bookmarked;

    Vibration.vibrate(duration: 100);
    setState(() => _bookmarked = nowBookmarked);
    await prefs.setBool(postId, nowBookmarked);

    final bookmarkStrings = prefs.getStringList('bookmarks') ?? <String>[];
    if (nowBookmarked) {
      final already = bookmarkStrings
          .map((s) => json.decode(s))
          .any((p) => (p['id']?.toString() ?? '') == postId);
      if (!already) {
        bookmarkStrings.add(json.encode(post));
        await prefs.setStringList('bookmarks', bookmarkStrings);
      }
    } else {
      bookmarkStrings.remove(json.encode(post));
      await prefs.setStringList('bookmarks', bookmarkStrings);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              nowBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(nowBookmarked ? 'Bookmark added' : 'Bookmark removed'),
          ],
        ),
        backgroundColor: palette.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _shareArticle() {
    final article = widget.article;
    final title = (article['title'] ?? '') as String;
    final url = (article['url'] ?? '') as String;
    SharePlus.instance.share(
      ShareParams(text: url.isEmpty ? title : '$title\n$url'),
    );
  }

  Widget _heroChromeButton({required Color background, required Widget child}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final article = widget.article;
    final images = article['images'];
    final imageUrl =
        (images is List && images.isNotEmpty) ? images[0]['url'] as String? : null;
    final title = (article['title'] ?? '') as String;
    final author = _authorDisplayName(article);

    String? publishedDate;
    try {
      publishedDate = DateFormat('d MMMM y').format(DateTime.parse(article['published']));
    } catch (_) {
      publishedDate = null;
    }

    final byline = [
      if (publishedDate != null) publishedDate,
      '$_readMinutes min read',
      if (author != null) 'By $author',
    ].join('   •   ');

    final hasImage = imageUrl != null;
    final heroIconColor = hasImage ? Colors.white : palette.accent;
    final heroChromeBg = hasImage ? Colors.black.withValues(alpha: 0.35) : palette.card;

    return Scaffold(
      backgroundColor: palette.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: palette.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: hasImage ? 440 : kToolbarHeight,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Material(
                color: Colors.transparent,
                child: _heroChromeButton(
                  background: heroChromeBg,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(Icons.arrow_back, color: heroIconColor, size: 20),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _heroChromeButton(
                  background: heroChromeBg,
                  child: AppBarMore(
                    iconColor: heroIconColor,
                    padding: EdgeInsets.zero,
                    extraItems: [
                      PopupMenuItem<String>(
                        value: 'open_in_browser',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_browser, color: palette.accent, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Open in Browser',
                              style: TextStyle(fontSize: 15, color: palette.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onExtraSelected: (value) {
                      if (value == 'open_in_browser') {
                        UrlService.launchURL(article['url']);
                      }
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: imageUrl == null
                ? null
                : FlexibleSpaceBar(
                    // No collapsed `title:` here — Material 3's FlexibleSpaceBar
                    // keeps it partially visible even at full expansion (not a
                    // clean fade-in-on-collapse like Material 2), which made it
                    // ghost behind the byline in the hero overlay below.
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          memCacheHeight: 1320,
                          placeholder: (context, url) => Container(color: palette.card),
                          errorWidget: (context, url, error) => Container(color: palette.card),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.25, 0.55, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.55),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'KL THE GUIDE',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 25,
                                  height: 1.25,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                byline,
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KL THE GUIDE',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 2,
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          byline,
                          style: TextStyle(fontSize: 13, color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: FutureBuilder<String>(
                    future: _sanitizedContent,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(color: palette.accent),
                          ),
                        );
                      }
                      final content = snapshot.data!;
                      return Html(
                        data: content.isNotEmpty ? content : '<p>No content available.</p>',
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontFamily: 'Raleway',
                            color: palette.textPrimary,
                            fontSize: FontSize(16),
                            lineHeight: const LineHeight(1.6),
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 18),
                          ),
                          "h1": Style(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            fontSize: FontSize(22),
                            color: palette.textPrimary,
                            lineHeight: const LineHeight(1.3),
                            margin: Margins.only(top: 8, bottom: 12),
                          ),
                          "h2": Style(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            fontSize: FontSize(20),
                            color: palette.textPrimary,
                            lineHeight: const LineHeight(1.3),
                            margin: Margins.only(top: 8, bottom: 12),
                          ),
                          "h3": Style(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w700,
                            fontSize: FontSize(18),
                            color: palette.textPrimary,
                            lineHeight: const LineHeight(1.3),
                            margin: Margins.only(top: 8, bottom: 10),
                          ),
                          "a": Style(
                            color: palette.accent,
                            textDecoration: TextDecoration.underline,
                            textDecorationColor: palette.accent,
                          ),
                          "strong": Style(fontWeight: FontWeight.w800),
                          "blockquote": Style(
                            margin: Margins.only(top: 8, bottom: 18),
                            padding: HtmlPaddings.only(left: 16, top: 4, bottom: 4),
                            border: Border(left: BorderSide(color: palette.accent, width: 3)),
                            fontStyle: FontStyle.italic,
                            color: palette.textSecondary,
                          ),
                          "li": Style(margin: Margins.only(bottom: 8)),
                          "figcaption": Style(
                            fontSize: FontSize(12.5),
                            fontStyle: FontStyle.italic,
                            color: palette.textSecondary,
                            textAlign: TextAlign.center,
                            margin: Margins.only(top: 6, bottom: 18),
                          ),
                        },
                        extensions: [
                          // Inline post images default to a bare Image.network (no
                          // disk cache, full-resolution decode) — route them through
                          // CachedNetworkImage instead, same as every other image in
                          // the app. Asset/data-uri images are left to the built-in
                          // handling since this only targets network sources.
                          ImageExtension(
                            handleAssetImages: false,
                            handleDataImages: false,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: context.attributes['src'] ?? '',
                                  fit: BoxFit.cover,
                                  memCacheWidth: 800,
                                  placeholder: (context, url) => Container(
                                    height: 180,
                                    color: palette.card,
                                  ),
                                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: palette.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _shareArticle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ios_share_outlined, color: palette.textPrimary, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 32, color: palette.background),
              Expanded(
                child: InkWell(
                  onTap: () => _toggleBookmark(palette),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: _bookmarked ? palette.accent : palette.textPrimary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bookmarked ? 'Saved' : 'Save',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _bookmarked ? palette.accent : palette.textPrimary,
                          ),
                        ),
                      ],
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
