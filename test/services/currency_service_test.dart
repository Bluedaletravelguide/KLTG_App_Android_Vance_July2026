import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/services/currency_service.dart';

void main() {
  test('parseRates extracts the rates map on a successful response', () {
    final decoded = {
      'result': 'success',
      'base_code': 'MYR',
      'rates': {'USD': 0.21, 'EUR': 0.19, 'SGD': 0.29},
    };

    final rates = CurrencyService.parseRates(decoded);

    expect(rates['USD'], 0.21);
    expect(rates['EUR'], 0.19);
    expect(rates['SGD'], 0.29);
  });

  test('parseRates throws when the API reports a non-success result', () {
    final decoded = {'result': 'error', 'error-type': 'invalid-key'};

    expect(() => CurrencyService.parseRates(decoded), throwsException);
  });
}
