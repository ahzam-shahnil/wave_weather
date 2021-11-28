import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2072140483759075~4970514637";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_ADMOB_APP_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2072140483759075/6139577338";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2072140483759075/3468665048";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static BannerAd? _offerScreenBannerAd;
  static InterstitialAd? _interstitialAd;

  static BannerAd _getCityScreenBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.smartBanner,
      listener: (event) => print("BannerAd event is $event"),
    );
  }

  static InterstitialAd _getInterstitialAd() {
    return InterstitialAd(
      adUnitId: interstitialAdUnitId,
      listener: _onInterstitialAdEvent,
    );
  }

  static void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        print('loaded an interstitial ad');
        break;
      case MobileAdEvent.failedToLoad:
        print('Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        _interstitialAd?.dispose();
        break;
      default:
      // do nothing
    }
  }

  static void showInterstitaialAd() {
    if (_interstitialAd == null) _interstitialAd = _getInterstitialAd();

    _interstitialAd!
      ..load()
      ..show();
  }

  static void showCityBannerAd() {
    if (_offerScreenBannerAd == null)
      _offerScreenBannerAd = _getCityScreenBannerAd();
    _offerScreenBannerAd!
      ..load()
      ..show(
        // Banner Position
        anchorType: AnchorType.bottom,
      );
  }

  static void hideCityBannerAd() async {
    await _offerScreenBannerAd?.dispose();
    _offerScreenBannerAd = null;
  }
}
