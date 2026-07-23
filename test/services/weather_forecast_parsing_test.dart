import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/services/weather_service.dart';

void main() {
  test('parseForecast turns the Open-Meteo daily block into DailyForecast entries', () {
    final decoded = {
      'daily': {
        'time': ['2026-07-14', '2026-07-15'],
        'weathercode': [0, 61],
        'temperature_2m_max': [33.2, 29.5],
        'temperature_2m_min': [24.1, 23.0],
      },
    };

    final forecast = WeatherService.parseForecast(decoded);

    expect(forecast, hasLength(2));
    expect(forecast[0].date, DateTime(2026, 7, 14));
    expect(forecast[0].maxC, 33.2);
    expect(forecast[0].minC, 24.1);
    expect(forecast[0].description, 'Clear Sky');
    expect(forecast[1].description, 'Rainy');
  });

  test('parseForecast throws when the response has no daily block', () {
    expect(() => WeatherService.parseForecast({'current_weather': {}}), throwsException);
  });
}
