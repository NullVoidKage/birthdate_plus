import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ad unit ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ad unit ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  Future<void> loadRewardedAd() async {
    if (_rewardedAd != null || _isRewardedAdLoading) return;

    _isRewardedAdLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdLoading = false;
            _rewardedAd = null;
            print('Failed to load rewarded ad: ${error.message}');
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoading = false;
      print('Error loading rewarded ad: $e');
    }
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
    }

    if (_rewardedAd == null) return false;

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        // Handle reward here
        print('User earned reward: ${reward.amount} ${reward.type}');
      },
    );

    return completer.future;
  }
} 