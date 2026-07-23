import 'dart:convert';
import 'package:http/http.dart' as http;

// open.er-api.com is a free, keyless currency-rate API (same "no signup"
// tier open-meteo already uses for weather in this app).
const String _kCurrencyApiUrl = 'https://open.er-api.com/v6/latest/MYR';

const List<String> commonCurrencyCodes = [
  'USD', 'EUR', 'GBP', 'SGD', 'AUD', 'CNY', 'JPY', 'THB', 'IDR', 'INR',
];

class CurrencyService {
  // Rate is "1 MYR = X of that currency".
  static Future<Map<String, double>> fetchRatesFromMYR() async {
    final res = await http.get(Uri.parse(_kCurrencyApiUrl)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Currency request failed: ${res.statusCode}');
    }
    return parseRates(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Map<String, double> parseRates(Map<String, dynamic> decoded) {
    if (decoded['result'] != 'success') {
      throw Exception('Currency API returned an error');
    }
    final rates = (decoded['rates'] as Map).cast<String, dynamic>();
    return rates.map((code, value) => MapEntry(code, (value as num).toDouble()));
  }
}
