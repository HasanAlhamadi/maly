// Tests for how money is displayed and read back.

import 'package:flutter_test/flutter_test.dart';
import 'package:maly/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('adds thousand separators and the currency code', () {
      expect(CurrencyFormatter.format(12500), '12,500 YER');
    });

    test('shows the size only, never the sign', () {
      expect(CurrencyFormatter.format(-800), '800 YER');
    });

    test('keeps at most two decimals', () {
      expect(CurrencyFormatter.format(10.5), '10.5 YER');
    });
  });

  group('CurrencyFormatter.formatSigned', () {
    test('marks money coming in with a plus', () {
      expect(CurrencyFormatter.formatSigned(500), '+500 YER');
    });

    test('marks money going out with a minus', () {
      expect(CurrencyFormatter.formatSigned(-500), '-500 YER');
    });

    test('leaves zero unsigned', () {
      expect(CurrencyFormatter.formatSigned(0), '0 YER');
    });
  });

  group('CurrencyFormatter.parse', () {
    test('reads a plain number', () {
      expect(CurrencyFormatter.parse('1200'), 1200);
    });

    test('ignores separators and spaces the user typed', () {
      expect(CurrencyFormatter.parse(' 1,200.50 '), 1200.5);
    });

    test('returns null when the text is not a number', () {
      expect(CurrencyFormatter.parse('abc'), isNull);
      expect(CurrencyFormatter.parse(''), isNull);
    });
  });
}
