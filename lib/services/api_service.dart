import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kltheguide/services/cache_service.dart';

const String kApiUrl = 'https://www.kltheguide.com.my/admin/functions.php';

String _encodeListCache(List<Map<String, dynamic>> value) => jsonEncode(value);
List<Map<String, dynamic>> _decodeListCache(String raw) =>
    (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

Future<List<Map<String, dynamic>>> fetchList(
  String action, {
  String? category,
}) {
  return CacheService.cached<List<Map<String, dynamic>>>(
    key: category != null ? '${action}_$category' : action,
    encode: _encodeListCache,
    decode: _decodeListCache,
    fetch: () async {
      final body = <String, String>{action: 'true'};
      if (category != null) body['category'] = category;
      final res = await http
          .post(Uri.parse(kApiUrl), body: body)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception('API $action failed: ${res.statusCode}');
      }
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return [];
      return decoded
          .cast<Map<String, dynamic>>()
          .where(_isValidEntry)
          .toList();
    },
  );
}

String field(Map<String, dynamic> item, String key) =>
    (item[key] ?? '').toString();

// Reads a sub-field out of a nested keyed object, e.g. tips['weather']['link'].
String nestedField(Map<String, dynamic> item, String key, String subkey) {
  final nested = item[key];
  if (nested is Map) return (nested[subkey] ?? '').toString();
  return '';
}

// Fetches a single settings-style object keyed by contentkey (as opposed to
// a list of listings) — used for appSiteInfo and the keyed image/link
// content actions (appHomeHighlights, appHighlightsTransport, etc).
Future<Map<String, dynamic>> fetchObject(String action) {
  return CacheService.cached<Map<String, dynamic>>(
    key: action,
    encode: jsonEncode,
    decode: (raw) => (jsonDecode(raw) as Map).cast<String, dynamic>(),
    fetch: () async {
      final res = await http
          .post(Uri.parse(kApiUrl), body: {action: 'true'})
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception('API $action failed: ${res.statusCode}');
      }
      final decoded = jsonDecode(res.body);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      if (decoded is List && decoded.isNotEmpty) {
        return (decoded.first as Map).cast<String, dynamic>();
      }
      throw Exception('API $action returned an unexpected shape');
    },
  );
}

// appSiteInfo's backing DB table doesn't exist on the live server (it was
// never migrated), so this is hardcoded from kltheguide.com.my's own About
// Us / Contact pages rather than fetched. Working hours weren't published
// anywhere on the site, so those three fields are left blank until someone
// supplies them.
Future<Map<String, dynamic>> fetchSiteInfo() => Future.value({
      'email': 'enquiry@bluedale.com.my',
      'phone': '+6012-220 0622',
      'whatsapp': '+6012-220 0622',
      'address':
          'No.31-2, Block F2, Level 2, Jalan PJU 1/42a, Dataran Prima, 47301 Petaling Jaya, Selangor',
      'address_map_url':
          'https://www.google.com/maps/search/?api=1&query=No.31-2,+Block+F2,+Level+2,+Jalan+PJU+1/42a,+Dataran+Prima,+47301+Petaling+Jaya,+Selangor',
      'hours_weekday': '',
      'hours_saturday': '',
      'hours_sunday': '',
      'tagline': "Your Gateway to Kuala Lumpur's Best Experiences",
      'facebook_url': 'https://www.facebook.com/kltheguide/',
      'instagram_url': 'https://www.instagram.com/kltheguide/',
      'tiktok_url': 'https://www.tiktok.com/@kltheguide',
      'website_url': 'https://www.kltheguide.com.my',
    });

// Fetches a raw list of objects with no title/image filtering — used for
// content that isn't a "listing" (e.g. Travel Buddy Q&A rows).
Future<List<Map<String, dynamic>>> fetchRawList(String action) {
  return CacheService.cached<List<Map<String, dynamic>>>(
    key: action,
    encode: _encodeListCache,
    decode: _decodeListCache,
    fetch: () async {
      final res = await http
          .post(Uri.parse(kApiUrl), body: {action: 'true'})
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception('API $action failed: ${res.statusCode}');
      }
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    },
  );
}

// Sends a Travel Buddy chat message (plus recent conversation history) to
// the Gemini-backed appTravelBuddyAI action and returns {answer, quickReplies}.
// history entries look like {'role': 'user'|'bot', 'text': '...'}.
Future<Map<String, dynamic>> fetchTravelBuddyAI(
  String message,
  List<Map<String, String>> history,
) async {
  final res = await http.post(Uri.parse(kApiUrl), body: {
    'appTravelBuddyAI': 'true',
    'message': message,
    'history': jsonEncode(history),
  }).timeout(const Duration(seconds: 25));
  if (res.statusCode != 200) {
    throw Exception('API appTravelBuddyAI failed: ${res.statusCode}');
  }
  final decoded = jsonDecode(res.body);
  if (decoded is! Map) {
    throw Exception('appTravelBuddyAI returned an unexpected shape');
  }
  final map = decoded.cast<String, dynamic>();
  if (map.containsKey('error')) {
    throw Exception('appTravelBuddyAI error: ${map['error']}');
  }
  return map;
}

// Strips a human-readable phone string (e.g. "+603-7886 9219") down to a
// dialable tel: URI.
String telUri(String phone) =>
    'tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}';

// Strips a human-readable phone string down to a wa.me-compatible number.
String whatsappUri(String phone) =>
    'https://api.whatsapp.com/send?phone=${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

// Filters out empty/placeholder CMS rows (e.g. a row whose image path has
// no filename), which the backend occasionally returns alongside real data.
bool _isValidEntry(Map<String, dynamic> item) {
  final title = field(item, 'title');
  final image = field(item, 'image');
  return title.isNotEmpty && image.isNotEmpty && !image.endsWith('/');
}
