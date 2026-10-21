import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/utils/format_cache.dart';
import 'package:core/utils/money.dart';
import 'package:flutter/widgets.dart';

extension MoneyFormatX on BuildContext {
  /// [money] with its currency and grouping: `AED 1,099`, or `AED 12.50`
  /// when it has fils.
  String money(Money money) {
    final locale = Localizations.localeOf(this).toLanguageTag();
    final amount = FormatCache.number(
      money.isWhole ? '#,##0' : '#,##0.00',
      locale,
    ).format(money.minor / Money.minorPerUnit);
    return coreL10n.moneyAmount(money.currency, amount);
  }
}
