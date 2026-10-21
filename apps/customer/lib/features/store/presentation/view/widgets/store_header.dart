import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/presentation/widgets/search_button.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The store page's pinned bar: back, search within the store and share.
class StoreHeader extends StatelessWidget {
  const StoreHeader({
    required this.brand,
    required this.onSearch,
    required this.onShare,
    super.key,
  });

  final String brand;
  final VoidCallback onSearch;
  final VoidCallback onShare;

  static const double _icon = 22;
  static const double _vertical = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: context.colors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm.w,
          context.viewPadding.top + _vertical.h,
          AppSpacing.sm.w,
          _vertical.h,
        ),
        child: Row(
          spacing: AppSpacing.xs.w,
          children: <Widget>[
            AppIconButton(
              icon: Assets.iconsChevronLeft,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
              variant: AppIconButtonVariant.plain,
              iconSize: _icon,
            ),
            Expanded(
              child: SearchButton(
                hint: l10n.storeSearchHint(brand),
                onTap: onSearch,
              ),
            ),
            AppIconButton(
              icon: Assets.iconsShare,
              tooltip: l10n.storeShare,
              onPressed: onShare,
              variant: AppIconButtonVariant.plain,
              iconSize: _icon,
            ),
          ],
        ),
      ),
    );
  }
}
