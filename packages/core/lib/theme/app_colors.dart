// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: packages/core/tokens/tekvo_tokens.json. Regenerate with `melos run tokens`.

import 'package:core/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Colour roles outside the Material scheme (status, commerce,
/// rider, map) in a light and a dark set. Read with
/// `context.appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.statusSuccess,
    required this.statusOnSuccess,
    required this.statusSuccessContainer,
    required this.statusOnSuccessContainer,
    required this.statusWarning,
    required this.statusOnWarning,
    required this.statusWarningContainer,
    required this.statusOnWarningContainer,
    required this.statusInfo,
    required this.statusOnInfo,
    required this.statusInfoContainer,
    required this.statusOnInfoContainer,
    required this.commerceRating,
    required this.commerceSale,
    required this.commerceOnSale,
    required this.commerceDeal,
    required this.commerceOnDeal,
    required this.commercePrice,
    required this.commercePriceStrike,
    required this.commerceProductBg,
    required this.riderPickup,
    required this.riderOnPickup,
    required this.riderPickupContainer,
    required this.riderDrop,
    required this.riderOnDrop,
    required this.riderDropContainer,
    required this.riderReturn,
    required this.riderOnReturn,
    required this.riderReturnContainer,
    required this.riderFailed,
    required this.riderOnFailed,
    required this.riderRoute,
    required this.riderRouteCasing,
    required this.riderRouteDone,
    required this.mapLand,
    required this.mapRoad,
    required this.mapRoadMajor,
    required this.mapRoadCasing,
    required this.mapWater,
    required this.mapPark,
    required this.mapBuilding,
    required this.mapLabel,
  });

  static const AppColors light = AppColors(
    statusSuccess: AppPalette.green700,
    statusOnSuccess: AppPalette.neutral0,
    statusSuccessContainer: AppPalette.green100,
    statusOnSuccessContainer: AppPalette.green900,
    statusWarning: AppPalette.amber700,
    statusOnWarning: AppPalette.neutral0,
    statusWarningContainer: AppPalette.amber100,
    statusOnWarningContainer: AppPalette.amber900,
    statusInfo: AppPalette.blue700,
    statusOnInfo: AppPalette.neutral0,
    statusInfoContainer: AppPalette.blue100,
    statusOnInfoContainer: AppPalette.blue900,
    commerceRating: AppPalette.amber500,
    commerceSale: AppPalette.red600,
    commerceOnSale: AppPalette.neutral0,
    commerceDeal: AppPalette.volt300,
    commerceOnDeal: AppPalette.volt950,
    commercePrice: AppPalette.neutral950,
    commercePriceStrike: AppPalette.neutral600,
    commerceProductBg: AppPalette.neutral75,
    riderPickup: Color(0xFF0061D2),
    riderOnPickup: Color(0xFFFFFFFF),
    riderPickupContainer: Color(0xFFE2EEFF),
    riderDrop: Color(0xFFC5F23A),
    riderOnDrop: Color(0xFF131F00),
    riderDropContainer: Color(0xFFEEFBCC),
    riderReturn: Color(0xFFE08A00),
    riderOnReturn: Color(0xFF1F1300),
    riderReturnContainer: Color(0xFFFDE9D3),
    riderFailed: Color(0xFFB9272C),
    riderOnFailed: Color(0xFFFFFFFF),
    riderRoute: Color(0xFF0061D2),
    riderRouteCasing: Color(0xFFFFFFFF),
    riderRouteDone: Color(0xFF9AA3AF),
    mapLand: Color(0xFFEEF0F3),
    mapRoad: Color(0xFFFFFFFF),
    mapRoadMajor: Color(0xFFFFF6DA),
    mapRoadCasing: Color(0xFFD5D9E0),
    mapWater: Color(0xFFB9D6EE),
    mapPark: Color(0xFFD3E8D1),
    mapBuilding: Color(0xFFE2E5EA),
    mapLabel: Color(0xFF6B7280),
  );

  static const AppColors dark = AppColors(
    statusSuccess: AppPalette.green300,
    statusOnSuccess: AppPalette.green900,
    statusSuccessContainer: AppPalette.green800,
    statusOnSuccessContainer: AppPalette.green100,
    statusWarning: AppPalette.amber300,
    statusOnWarning: AppPalette.amber900,
    statusWarningContainer: AppPalette.amber800,
    statusOnWarningContainer: AppPalette.amber100,
    statusInfo: AppPalette.blue300,
    statusOnInfo: AppPalette.blue900,
    statusInfoContainer: AppPalette.blue800,
    statusOnInfoContainer: AppPalette.blue100,
    commerceRating: AppPalette.amber300,
    commerceSale: AppPalette.red300,
    commerceOnSale: AppPalette.red900,
    commerceDeal: AppPalette.volt300,
    commerceOnDeal: AppPalette.volt950,
    commercePrice: AppPalette.neutral50,
    commercePriceStrike: AppPalette.neutral400,
    commerceProductBg: AppPalette.neutral925,
    riderPickup: Color(0xFF4C9BFF),
    riderOnPickup: Color(0xFF001A40),
    riderPickupContainer: Color(0xFF0A2E5C),
    riderDrop: Color(0xFFC5F23A),
    riderOnDrop: Color(0xFF131F00),
    riderDropContainer: Color(0xFF2A3608),
    riderReturn: Color(0xFFF2A93B),
    riderOnReturn: Color(0xFF1F1300),
    riderReturnContainer: Color(0xFF4A2E00),
    riderFailed: Color(0xFFFF6B63),
    riderOnFailed: Color(0xFF2A0000),
    riderRoute: Color(0xFF4C9BFF),
    riderRouteCasing: Color(0xFF0E1115),
    riderRouteDone: Color(0xFF4B525C),
    mapLand: Color(0xFF15181D),
    mapRoad: Color(0xFF2A2F37),
    mapRoadMajor: Color(0xFF3A414C),
    mapRoadCasing: Color(0xFF0B0D10),
    mapWater: Color(0xFF0E2338),
    mapPark: Color(0xFF13261A),
    mapBuilding: Color(0xFF1D2128),
    mapLabel: Color(0xFF8B93A1),
  );

  final Color statusSuccess;
  final Color statusOnSuccess;
  final Color statusSuccessContainer;
  final Color statusOnSuccessContainer;
  final Color statusWarning;
  final Color statusOnWarning;
  final Color statusWarningContainer;
  final Color statusOnWarningContainer;
  final Color statusInfo;
  final Color statusOnInfo;
  final Color statusInfoContainer;
  final Color statusOnInfoContainer;
  final Color commerceRating;
  final Color commerceSale;
  final Color commerceOnSale;
  final Color commerceDeal;
  final Color commerceOnDeal;
  final Color commercePrice;
  final Color commercePriceStrike;
  final Color commerceProductBg;
  final Color riderPickup;
  final Color riderOnPickup;
  final Color riderPickupContainer;
  final Color riderDrop;
  final Color riderOnDrop;
  final Color riderDropContainer;
  final Color riderReturn;
  final Color riderOnReturn;
  final Color riderReturnContainer;
  final Color riderFailed;
  final Color riderOnFailed;
  final Color riderRoute;
  final Color riderRouteCasing;
  final Color riderRouteDone;
  final Color mapLand;
  final Color mapRoad;
  final Color mapRoadMajor;
  final Color mapRoadCasing;
  final Color mapWater;
  final Color mapPark;
  final Color mapBuilding;
  final Color mapLabel;

  @override
  AppColors copyWith({
    Color? statusSuccess,
    Color? statusOnSuccess,
    Color? statusSuccessContainer,
    Color? statusOnSuccessContainer,
    Color? statusWarning,
    Color? statusOnWarning,
    Color? statusWarningContainer,
    Color? statusOnWarningContainer,
    Color? statusInfo,
    Color? statusOnInfo,
    Color? statusInfoContainer,
    Color? statusOnInfoContainer,
    Color? commerceRating,
    Color? commerceSale,
    Color? commerceOnSale,
    Color? commerceDeal,
    Color? commerceOnDeal,
    Color? commercePrice,
    Color? commercePriceStrike,
    Color? commerceProductBg,
    Color? riderPickup,
    Color? riderOnPickup,
    Color? riderPickupContainer,
    Color? riderDrop,
    Color? riderOnDrop,
    Color? riderDropContainer,
    Color? riderReturn,
    Color? riderOnReturn,
    Color? riderReturnContainer,
    Color? riderFailed,
    Color? riderOnFailed,
    Color? riderRoute,
    Color? riderRouteCasing,
    Color? riderRouteDone,
    Color? mapLand,
    Color? mapRoad,
    Color? mapRoadMajor,
    Color? mapRoadCasing,
    Color? mapWater,
    Color? mapPark,
    Color? mapBuilding,
    Color? mapLabel,
  }) => AppColors(
    statusSuccess: statusSuccess ?? this.statusSuccess,
    statusOnSuccess: statusOnSuccess ?? this.statusOnSuccess,
    statusSuccessContainer:
        statusSuccessContainer ?? this.statusSuccessContainer,
    statusOnSuccessContainer:
        statusOnSuccessContainer ?? this.statusOnSuccessContainer,
    statusWarning: statusWarning ?? this.statusWarning,
    statusOnWarning: statusOnWarning ?? this.statusOnWarning,
    statusWarningContainer:
        statusWarningContainer ?? this.statusWarningContainer,
    statusOnWarningContainer:
        statusOnWarningContainer ?? this.statusOnWarningContainer,
    statusInfo: statusInfo ?? this.statusInfo,
    statusOnInfo: statusOnInfo ?? this.statusOnInfo,
    statusInfoContainer: statusInfoContainer ?? this.statusInfoContainer,
    statusOnInfoContainer: statusOnInfoContainer ?? this.statusOnInfoContainer,
    commerceRating: commerceRating ?? this.commerceRating,
    commerceSale: commerceSale ?? this.commerceSale,
    commerceOnSale: commerceOnSale ?? this.commerceOnSale,
    commerceDeal: commerceDeal ?? this.commerceDeal,
    commerceOnDeal: commerceOnDeal ?? this.commerceOnDeal,
    commercePrice: commercePrice ?? this.commercePrice,
    commercePriceStrike: commercePriceStrike ?? this.commercePriceStrike,
    commerceProductBg: commerceProductBg ?? this.commerceProductBg,
    riderPickup: riderPickup ?? this.riderPickup,
    riderOnPickup: riderOnPickup ?? this.riderOnPickup,
    riderPickupContainer: riderPickupContainer ?? this.riderPickupContainer,
    riderDrop: riderDrop ?? this.riderDrop,
    riderOnDrop: riderOnDrop ?? this.riderOnDrop,
    riderDropContainer: riderDropContainer ?? this.riderDropContainer,
    riderReturn: riderReturn ?? this.riderReturn,
    riderOnReturn: riderOnReturn ?? this.riderOnReturn,
    riderReturnContainer: riderReturnContainer ?? this.riderReturnContainer,
    riderFailed: riderFailed ?? this.riderFailed,
    riderOnFailed: riderOnFailed ?? this.riderOnFailed,
    riderRoute: riderRoute ?? this.riderRoute,
    riderRouteCasing: riderRouteCasing ?? this.riderRouteCasing,
    riderRouteDone: riderRouteDone ?? this.riderRouteDone,
    mapLand: mapLand ?? this.mapLand,
    mapRoad: mapRoad ?? this.mapRoad,
    mapRoadMajor: mapRoadMajor ?? this.mapRoadMajor,
    mapRoadCasing: mapRoadCasing ?? this.mapRoadCasing,
    mapWater: mapWater ?? this.mapWater,
    mapPark: mapPark ?? this.mapPark,
    mapBuilding: mapBuilding ?? this.mapBuilding,
    mapLabel: mapLabel ?? this.mapLabel,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusOnSuccess: Color.lerp(statusOnSuccess, other.statusOnSuccess, t)!,
      statusSuccessContainer: Color.lerp(
        statusSuccessContainer,
        other.statusSuccessContainer,
        t,
      )!,
      statusOnSuccessContainer: Color.lerp(
        statusOnSuccessContainer,
        other.statusOnSuccessContainer,
        t,
      )!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusOnWarning: Color.lerp(statusOnWarning, other.statusOnWarning, t)!,
      statusWarningContainer: Color.lerp(
        statusWarningContainer,
        other.statusWarningContainer,
        t,
      )!,
      statusOnWarningContainer: Color.lerp(
        statusOnWarningContainer,
        other.statusOnWarningContainer,
        t,
      )!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusOnInfo: Color.lerp(statusOnInfo, other.statusOnInfo, t)!,
      statusInfoContainer: Color.lerp(
        statusInfoContainer,
        other.statusInfoContainer,
        t,
      )!,
      statusOnInfoContainer: Color.lerp(
        statusOnInfoContainer,
        other.statusOnInfoContainer,
        t,
      )!,
      commerceRating: Color.lerp(commerceRating, other.commerceRating, t)!,
      commerceSale: Color.lerp(commerceSale, other.commerceSale, t)!,
      commerceOnSale: Color.lerp(commerceOnSale, other.commerceOnSale, t)!,
      commerceDeal: Color.lerp(commerceDeal, other.commerceDeal, t)!,
      commerceOnDeal: Color.lerp(commerceOnDeal, other.commerceOnDeal, t)!,
      commercePrice: Color.lerp(commercePrice, other.commercePrice, t)!,
      commercePriceStrike: Color.lerp(
        commercePriceStrike,
        other.commercePriceStrike,
        t,
      )!,
      commerceProductBg: Color.lerp(
        commerceProductBg,
        other.commerceProductBg,
        t,
      )!,
      riderPickup: Color.lerp(riderPickup, other.riderPickup, t)!,
      riderOnPickup: Color.lerp(riderOnPickup, other.riderOnPickup, t)!,
      riderPickupContainer: Color.lerp(
        riderPickupContainer,
        other.riderPickupContainer,
        t,
      )!,
      riderDrop: Color.lerp(riderDrop, other.riderDrop, t)!,
      riderOnDrop: Color.lerp(riderOnDrop, other.riderOnDrop, t)!,
      riderDropContainer: Color.lerp(
        riderDropContainer,
        other.riderDropContainer,
        t,
      )!,
      riderReturn: Color.lerp(riderReturn, other.riderReturn, t)!,
      riderOnReturn: Color.lerp(riderOnReturn, other.riderOnReturn, t)!,
      riderReturnContainer: Color.lerp(
        riderReturnContainer,
        other.riderReturnContainer,
        t,
      )!,
      riderFailed: Color.lerp(riderFailed, other.riderFailed, t)!,
      riderOnFailed: Color.lerp(riderOnFailed, other.riderOnFailed, t)!,
      riderRoute: Color.lerp(riderRoute, other.riderRoute, t)!,
      riderRouteCasing: Color.lerp(
        riderRouteCasing,
        other.riderRouteCasing,
        t,
      )!,
      riderRouteDone: Color.lerp(riderRouteDone, other.riderRouteDone, t)!,
      mapLand: Color.lerp(mapLand, other.mapLand, t)!,
      mapRoad: Color.lerp(mapRoad, other.mapRoad, t)!,
      mapRoadMajor: Color.lerp(mapRoadMajor, other.mapRoadMajor, t)!,
      mapRoadCasing: Color.lerp(mapRoadCasing, other.mapRoadCasing, t)!,
      mapWater: Color.lerp(mapWater, other.mapWater, t)!,
      mapPark: Color.lerp(mapPark, other.mapPark, t)!,
      mapBuilding: Color.lerp(mapBuilding, other.mapBuilding, t)!,
      mapLabel: Color.lerp(mapLabel, other.mapLabel, t)!,
    );
  }
}
