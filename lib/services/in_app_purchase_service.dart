import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:flutter/foundation.dart';
import 'premium_service.dart';

class InAppPurchaseService {
  static const String _premiumId = 'premium_upgrade';
  static const String _androidPremiumId = 'premium_upgrade_android';
  static const String _iosPremiumId = 'premium_upgrade_ios';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  
  Future<void> initialize() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      _isAvailable = false;
      return;
    }
    
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(null);
    }
    
    const Set<String> kIds = <String>{_androidPremiumId, _iosPremiumId};
    final ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails(kIds);
    
    if (productDetailsResponse.error != null) {
      print('Error loading products: ${productDetailsResponse.error}');
      return;
    }
    
    if (productDetailsResponse.productDetails.isEmpty) {
      print('No products found');
      return;
    }
    
    _products = productDetailsResponse.productDetails;
    _isAvailable = true;
    
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Error: $error'),
    );
  }
  
  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await PremiumService.activatePremium();
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }
  
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Add your purchase verification logic here
    // For testing, we'll return true
    return true;
  }
  
  Future<void> buyPremium() async {
    if (!_isAvailable) {
      print('Store not available');
      return;
    }
    
    ProductDetails? product;
    try {
      product = _products.firstWhere(
        (product) => product.id == (Platform.isIOS ? _iosPremiumId : _androidPremiumId),
      );
    } catch (e) {
      product = null;
    }

    if (product == null) {
      print('Product not found');
      return;
    }
    
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );
    
    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error making purchase: $e');
    }
  }
  
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      print('Store not available');
      return;
    }
    
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }
  
  void dispose() {
    _subscription?.cancel();
  }
} 