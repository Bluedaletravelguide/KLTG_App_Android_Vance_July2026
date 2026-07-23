import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Kuala Lumpur city centre — this app is KL-specific, so the location is
// fixed rather than using geolocation (avoids a permission prompt for a
// value that's already implied by the app's purpose).
const double _klLatitude = 3.1390;
const double _klLongitude = 101.6869;

class WeatherInfo {
  final double temperatureC;
  final String description;
  final IconData icon;

  const WeatherInfo({
    required this.temperatureC,
    required this.description,
    required this.icon,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxC;
  final double minC;
  final String description;
  final IconData icon;

  const DailyForecast({
    required this.date,
    required this.maxC,
    required this.minC,
    required this.description,
    required this.icon,
  });
}

class WeatherService {
  static Future<WeatherInfo> fetchKLWeather() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$_klLatitude&longitude=$_klLongitude'
      '&current_weather=true',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Weather request failed: ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    final current = decoded['current_weather'];
    if (current is! Map) {
      throw Exception('Unexpected weather response shape');
    }
    final temp = (current['temperature'] as num).toDouble();
    final code = (current['weathercode'] as num).toInt();
    final described = _describeWeatherCode(code);
    return WeatherInfo(
      temperatureC: temp,
      description: described.$1,
      icon: described.$2,
    );
  }

  static Future<List<DailyForecast>> fetchKLForecast() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$_klLatitude&longitude=$_klLongitude'
      '&daily=weathercode,temperature_2m_max,temperature_2m_min'
      '&timezone=Asia%2FKuala_Lumpur'
      '&forecast_days=6',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Forecast request failed: ${res.statusCode}');
    }
    return parseForecast(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static List<DailyForecast> parseForecast(Map<String, dynamic> decoded) {
    final daily = decoded['daily'];
    if (daily is! Map) throw Exception('Unexpected forecast response shape');
    final dates = (daily['time'] as List).cast<String>();
    final codes = (daily['weathercode'] as List).cast<num>();
    final maxes = (daily['temperature_2m_max'] as List).cast<num>();
    final mins = (daily['temperature_2m_min'] as List).cast<num>();
    return [
      for (var i = 0; i < dates.length; i++)
        () {
          final described = _describeWeatherCode(codes[i].toInt());
          return DailyForecast(
            date: DateTime.parse(dates[i]),
            maxC: maxes[i].toDouble(),
            minC: mins[i].toDouble(),
            description: described.$1,
            icon: described.$2,
          );
        }(),
    ];
  }

  // Maps WMO weather codes (used by Open-Meteo) to a short label + icon.
  // https://open-meteo.com/en/docs#weathervariables
  static (String, IconData) _describeWeatherCode(int code) {
    if (code == 0) return ('Clear Sky', Icons.wb_sunny_rounded);
    if (code == 1) return ('Mostly Clear', Icons.wb_sunny_outlined);
    if (code == 2) return ('Partly Cloudy', Icons.wb_cloudy_outlined);
    if (code == 3) return ('Overcast', Icons.cloud_rounded);
    if (code == 45 || code == 48) return ('Foggy', Icons.foggy);
    if (code >= 51 && code <= 57) return ('Drizzle', Icons.water_drop_outlined);
    if (code >= 61 && code <= 67) return ('Rainy', Icons.water_drop_rounded);
    if (code >= 71 && code <= 77) return ('Snowy', Icons.ac_unit_rounded);
    if (code >= 80 && code <= 82) return ('Showers', Icons.umbrella_rounded);
    if (code >= 95) return ('Thunderstorm', Icons.thunderstorm_rounded);
    return ('Partly Cloudy', Icons.wb_cloudy_outlined);
  }
}
