import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/presentation/widgets/search_button.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';

/// Home's search: the hint and a filter button, both opening search.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({required this.onTap, super.key});

  final VoidCallback onTap;

  static const double _filter = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SearchButton(
      hint: l10n.homeSearchHint,
      onTap: onTap,
      trailing: AppIconButton(
        icon: Assets.iconsFilter,
        tooltip: l10n.homeFilters,
        variant: AppIconButtonVariant.filled,
        size: _filter,
        onPressed: onTap,
      ),
    );
  }
}
