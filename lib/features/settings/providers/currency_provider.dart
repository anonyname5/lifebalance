import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/preferences_service.dart';
import '../../../core/utils/currency_helper.dart';

/// Currency provider
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super(CurrencyHelper.usd) {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await PreferencesService.getCurrency();
    state = currency;
  }

  Future<void> setCurrency(String currency) async {
    state = currency;
    await PreferencesService.setCurrency(currency);
  }
}
