import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/api/api_urls.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/services/session_manager.dart';
import '../model/promo_status_model.dart';

class PromoCodeController extends GetxController {
  // ─────────────── Route Arguments ───────────────
  late final String email;
  late final String videoId;

  // ─────────────── UI States ───────────────
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // ─────────────── Claim & Cooldown States ───────────────
  final RxBool isCooldownActive = false.obs;
  final RxInt daysRemaining = 0.obs;
  final RxString nextAvailableDate = ''.obs;
  final RxString lastClaimedAt = ''.obs;
  final Rx<PromoStatusModel?> promoStatus = Rx<PromoStatusModel?>(null);

  // ─────────────── Coupon Data ───────────────
  final RxString promoCode = ''.obs;
  final RxString source = ''.obs;
  final RxString discountValue = ''.obs;
  final RxString discountType = ''.obs;
  final RxString expiredAt = ''.obs;
  final RxString formattedExpiry = ''.obs;
  final RxInt remainingDays = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    email = args['email']?.toString() ?? '';
    videoId = args['videoId']?.toString() ?? '';
    processPromoFlow();
  }

  // ═══════════════════════════════════════════════
  //  Main Flow: Check Status & Claim
  // ═══════════════════════════════════════════════

  Future<void> processPromoFlow() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final networkCaller = Get.find<NetworkCaller>();

      // 1. Fetch Claim Status
      final statusResponse = await networkCaller.request(
        url: ApiUrls.couponClaimStatus,
        method: HttpMethod.get,
      );

      if (!statusResponse.success || statusResponse.data == null) {
        debugPrint('❌ Claim Status API failed: ${statusResponse.message}');
        // Fallback to legacy random coupon if claim-status endpoint is unavailable
        await _fallbackLegacyCoupon();
        return;
      }

      final statusJson = (statusResponse.data as Map<String, dynamic>)['data'] ?? statusResponse.data;
      final status = PromoStatusModel.fromJson(statusJson is Map<String, dynamic> ? statusJson : {});
      promoStatus.value = status;

      daysRemaining.value = status.daysRemaining;
      nextAvailableDate.value = status.nextAvailableDate ?? '';
      lastClaimedAt.value = status.lastClaimedAt ?? '';

      if (status.canClaim) {
        // User is eligible to claim! If video was watched (videoId present), claim it now
        if (videoId.isNotEmpty) {
          await _claimCoupon(videoId);
        } else {
          // If no videoId provided but user can claim, prompt or load fallback
          isCooldownActive.value = false;
          isLoading.value = false;
        }
      } else {
        // Cooldown is active (cannot claim yet)
        isCooldownActive.value = true;
        if (status.lastCoupon != null) {
          _populateCouponData(status.lastCoupon!);
        }
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint('💥 Error in promo flow: $e');
      _setError('An unexpected error occurred: $e');
    }
  }

  Future<void> _claimCoupon(String vId) async {
    try {
      final networkCaller = Get.find<NetworkCaller>();
      final response = await networkCaller.request(
        url: ApiUrls.couponClaim,
        method: HttpMethod.post,
        body: {'videoId': vId},
      );

      if (response.success && response.data != null) {
        final data = (response.data as Map<String, dynamic>)['data'] ?? response.data;
        debugPrint('🎉 Promo claimed successfully: $data');

        final couponData = data['coupon'] ?? data;
        if (couponData is Map<String, dynamic>) {
          _populateCouponData(couponData);
        }

        isCooldownActive.value = false;
        isLoading.value = false;
      } else {
        debugPrint('❌ Claim API error: ${response.message}');
        _setError(response.message ?? 'Failed to claim promo code.');
      }
    } catch (e) {
      debugPrint('💥 Claim API exception: $e');
      _setError('An unexpected error occurred while claiming: $e');
    }
  }

  Future<void> _fallbackLegacyCoupon() async {
    try {
      final networkCaller = Get.find<NetworkCaller>();
      final response = await networkCaller.request(
        url: ApiUrls.generateCoupon,
        method: HttpMethod.post,
        body: {'email': email, 'videoId': videoId},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final couponData = data['data'] ?? data;
        _populateCouponData(couponData is Map<String, dynamic> ? couponData : data);
        isCooldownActive.value = false;
      } else {
        _setError(response.message ?? 'Failed to generate coupon.');
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    }
  }

  void _populateCouponData(Map<String, dynamic> data) {
    promoCode.value = data['promoCode']?.toString() ?? '';
    source.value = data['source']?.toString() ?? '';
    discountValue.value = data['discountValue']?.toString() ?? '';
    discountType.value = data['discountType']?.toString() ?? '';
    expiredAt.value = data['expiredAt']?.toString() ?? '';

    // Format expiry date
    if (expiredAt.value.isNotEmpty) {
      try {
        final date = DateTime.parse(expiredAt.value);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        formattedExpiry.value =
            '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';

        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final expiryDate = DateTime(date.year, date.month, date.day);
        final diff = expiryDate.difference(todayDate).inDays;
        remainingDays.value = diff < 0 ? 0 : diff;
      } catch (_) {
        formattedExpiry.value = expiredAt.value;
      }
    }

    // Persist coupon data locally for Profile screen
    try {
      final session = Get.find<SessionManager>();
      session.setCouponData({
        'promoCode': promoCode.value,
        'source': source.value,
        'discountType': discountType.value,
        'discountValue': discountValue.value,
        'expiredAt': expiredAt.value,
      });
    } catch (_) {}
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    isLoading.value = false;
  }

  /// Retry the claim status / claim flow.
  void retry() {
    processPromoFlow();
  }

  /// Build the discount info string, e.g. "Get 25% OFF on UBER"
  String get discountInfo {
    if (discountValue.value.isEmpty) return '';
    return 'Get ${discountValue.value}${discountType.value.toLowerCase().contains("percent") ? "%" : " ${discountType.value}"} OFF on ${source.value}';
  }

  /// Format next available date nicely
  String get formattedNextAvailableDate {
    if (nextAvailableDate.value.isEmpty) return '';
    try {
      final date = DateTime.parse(nextAvailableDate.value);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return nextAvailableDate.value;
    }
  }

  void copyToClipboard() {
    if (promoCode.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: promoCode.value));
    Get.snackbar(
      "Success",
      "Promo code copied to clipboard!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
