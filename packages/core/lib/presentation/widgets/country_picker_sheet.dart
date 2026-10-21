import 'dart:async';
import 'dart:math';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/view_model/country_picker_view_model.dart';
import 'package:core/presentation/widgets/app_sheet.dart';
import 'package:core/presentation/widgets/app_text_field.dart';
import 'package:core/presentation/widgets/country_tile.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:country/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Chooses a mobile number's country: the current one, then all countries,
/// or the matches of a search by name or dial code. Picking a country
/// reports it and closes the sheet.
class CountryPickerSheet extends ConsumerStatefulWidget {
  const CountryPickerSheet({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final Country selected;
  final ValueChanged<Country> onSelected;

  /// How long typing pauses before the list is searched.
  static const Duration searchDelay = Duration(milliseconds: 300);

  /// Lets the new selection show before the sheet closes.
  static const Duration closeDelay = Duration(milliseconds: 150);

  static Future<void> show(
    BuildContext context, {
    required Country selected,
    required ValueChanged<Country> onSelected,
  }) => showAppSheet<void>(
    context,
    builder: (_) =>
        CountryPickerSheet(selected: selected, onSelected: onSelected),
  );

  @override
  ConsumerState<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends ConsumerState<CountryPickerSheet> {
  /// The design's sheet height on its 852 tall screen; a shorter screen or
  /// the keyboard caps it.
  static const double _height = 700;
  static const double _side = 16;
  static const double _handleWidth = 40;
  static const double _handleHeight = 5;
  static const double _closeSize = 40;
  static const double _searchHeight = 52;
  static const double _searchIcon = 22;
  static const double _listTop = 14;

  /// A section label's gap to its first row, and the gap between sections.
  static const double _labelGap = 12;
  static const double _sectionGap = 18;
  static const double _tipGap = 16;

  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchTimer;
  bool _closing = false;

  @override
  void dispose() {
    _searchTimer?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String get _language => Localizations.localeOf(context).languageCode;

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    final notifier = ref.read(
      countryPickerViewModelProvider(_language).notifier,
    );
    _searchTimer = Timer(
      CountryPickerSheet.searchDelay,
      () => notifier.search(query),
    );
  }

  Future<void> _select(Country country) async {
    if (_closing) return;
    _closing = true;
    ref.read(countryPickerViewModelProvider(_language).notifier).pick(country);
    widget.onSelected(country);
    await Future<void>.delayed(context.motion(CountryPickerSheet.closeDelay));
    // The sheet may already be closing; popping then would close the screen.
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(countryPickerViewModelProvider(_language));
    // The home indicator's strip, which the keyboard covers while it is up.
    final bottom = max(
      0,
      MediaQuery.viewPaddingOf(context).bottom -
          MediaQuery.viewInsetsOf(context).bottom,
    ).toDouble();
    return SizedBox(
      height: _height.h,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _handle(context),
            _header(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _side.w),
              child: _searchField(context),
            ),
            Expanded(child: _list(context, search)),
          ],
        ),
      ),
    );
  }

  Widget _handle(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 10.h, bottom: AppSpacing.s6.h),
    child: Center(
      child: Container(
        width: _handleWidth.w,
        height: _handleHeight.h,
        decoration: BoxDecoration(
          color: context.colors.outlineVariant,
          borderRadius: BorderRadius.circular(_handleHeight.h / 2),
        ),
      ),
    ),
  );

  Widget _header(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _side.w,
        AppSpacing.s6.h,
        _side.w,
        14.h,
      ),
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                context.coreL10n.countryPickerTitle,
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceContainerHigh,
              fixedSize: Size.square(_closeSize.r),
              minimumSize: Size.square(_closeSize.r),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: SvgPicture.asset(
              Assets.iconsClose,
              width: AppSizes.iconMd.r,
              height: AppSizes.iconMd.r,
              colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) => AppTextField(
    controller: _search,
    focusNode: _searchFocus,
    icon: Assets.iconsSearch,
    hint: context.coreL10n.countryPickerSearchHint,
    iconSize: _searchIcon,
    height: _searchHeight,
    endPadding: AppSpacing.s6,
    whiteWhenFocused: false,
    textInputAction: TextInputAction.search,
    onChanged: _onSearchChanged,
  );

  Widget _list(BuildContext context, CountrySearch search) {
    final countries = search.query.isNotEmpty
        ? search.countries
        : search.countries.where((c) => c != widget.selected).toList();
    final tip = search.query.isNotEmpty ? 1 : 0;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(_side.w, _listTop.h, _side.w, _side.h),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: 1 + countries.length + tip,
      itemBuilder: (context, index) {
        if (index == 0) return _lead(context, search, countries.length);
        if (index > countries.length) {
          return Padding(
            padding: EdgeInsets.only(top: _tipGap.h),
            child: Text(
              context.coreL10n.countryPickerTip,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(top: index == 1 ? 0 : AppSpacing.xs.h),
          child: _tile(countries[index - 1]),
        );
      },
    );
  }

  /// The section labels, and the current country, above the list.
  Widget _lead(BuildContext context, CountrySearch search, int count) {
    final l10n = context.coreL10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: search.query.isNotEmpty
          ? <Widget>[
              _label(context, l10n.countryPickerResults(count)),
              SizedBox(height: _labelGap.h),
            ]
          : <Widget>[
              _label(context, l10n.countryPickerCurrent),
              SizedBox(height: _labelGap.h),
              _tile(widget.selected),
              SizedBox(height: _sectionGap.h),
              _label(context, l10n.countryPickerAll),
              SizedBox(height: _labelGap.h),
            ],
    );
  }

  Widget _label(BuildContext context, String label) => Semantics(
    header: true,
    child: Text(
      label,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    ),
  );

  Widget _tile(Country country) => CountryTile(
    country: country,
    name: countryName(country, _language),
    selected:
        country ==
        (ref.watch(countryPickerViewModelProvider(_language)).picked ??
            widget.selected),
    onTap: () => unawaited(_select(country)),
  );
}
