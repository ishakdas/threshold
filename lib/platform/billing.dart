import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../data/plus.dart';

/// Satın alma ekranının durumu.
enum BuyState { idle, pending, error }

/// Eşik Plus'ı Google Play'den satın alma ve geri yükleme. Satın alma
/// imzası lisans anahtarıyla doğrulanıp onaylanınca (acknowledge)
/// [plusOwnedProvider] güncellenir; imzası tutmayan kayıt yok sayılır. Play, onaylanmayan
/// satın almayı üç gün içinde iade ettiği için onay her açılışta yeniden denenir.
class PlusBilling extends Notifier<BuyState> {
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  InAppPurchase get _iap => InAppPurchase.instance;

  @override
  BuyState build() {
    ref.onDispose(() => _sub?.cancel());
    return BuyState.idle;
  }

  /// Uygulama açılınca: satın alma akışını dinle, Play'deki kayda göre
  /// sahipliği eşitle (iade edilen satın alma da düşer).
  Future<void> start() async {
    if (_sub != null) return;
    try {
      _sub = _iap.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) => debugPrint('PlusBilling: $e'),
      );
      if (!await _iap.isAvailable()) return;
      // iOS'ta geri yükleme Apple hesabı şifresi isteyebilir; yalnızca
      // kullanıcı "Satın alımı geri yükle"ye basınca yapılır.
      if (defaultTargetPlatform == TargetPlatform.android) await _sync();
    } on Object catch (e) {
      // Play Store yok (emülatör, test): uygulama yine çalışır.
      debugPrint('PlusBilling.start: $e');
    }
  }

  Future<void> _sync() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      await _iap.restorePurchases();
      return;
    }
    final android = _iap
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final past = await android.queryPastPurchases();
    if (past.error != null) return;
    final plus = [
      for (final p in past.pastPurchases)
        if (p.productID == plusProductId &&
            p.status == PurchaseStatus.purchased &&
            await _verified(p))
          p,
    ];
    ref.read(plusOwnedProvider.notifier).set(plus.isNotEmpty);
    for (final p in plus.where((p) => p.pendingCompletePurchase)) {
      await _iap.completePurchase(p);
    }
  }

  /// Mağazadaki fiyatıyla ürün; Play'e ulaşılamazsa null.
  Future<ProductDetails?> product() async {
    if (_product != null) return _product;
    try {
      if (!await _iap.isAvailable()) return null;
      final r = await _iap.queryProductDetails({plusProductId});
      _product = r.productDetails.firstOrNull;
    } on Object catch (e) {
      debugPrint('PlusBilling.product: $e');
    }
    return _product;
  }

  Future<void> buy() async {
    final p = await product();
    if (p == null) {
      state = BuyState.error;
      return;
    }
    state = BuyState.pending;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: p),
      );
    } on Object catch (e) {
      debugPrint('PlusBilling.buy: $e');
      state = BuyState.error;
    }
  }

  Future<void> restore() async {
    state = BuyState.pending;
    try {
      await _sync();
      state = BuyState.idle;
    } on Object catch (e) {
      debugPrint('PlusBilling.restore: $e');
      state = BuyState.error;
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases.where((p) => p.productID == plusProductId)) {
      switch (p.status) {
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          if (!await _verified(p)) {
            state = BuyState.error;
            continue;
          }
          ref.read(plusOwnedProvider.notifier).set(true);
          state = BuyState.idle;
        case PurchaseStatus.pending:
          state = BuyState.pending;
        case PurchaseStatus.error:
          state = BuyState.error;
        case PurchaseStatus.canceled:
          state = BuyState.idle;
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }
}

/// Play kaydının imzası Android tarafında (PurchaseVerifier.kt) doğrulanır.
/// App Store işlemlerini StoreKit kendisi doğrulayıp cihaza imzalı verir.
Future<bool> _verified(PurchaseDetails p) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return true;
  if (p is! GooglePlayPurchaseDetails) return false;
  try {
    return await const MethodChannel('esik/native')
            .invokeMethod<bool>('verifyPurchase', {
              'json': p.billingClientPurchase.originalJson,
              'signature': p.billingClientPurchase.signature,
              'productId': plusProductId,
            }) ??
        false;
  } on PlatformException catch (e) {
    debugPrint('PlusBilling.verify: $e');
    return false;
  }
}

final plusBillingProvider = NotifierProvider<PlusBilling, BuyState>(
  PlusBilling.new,
);
