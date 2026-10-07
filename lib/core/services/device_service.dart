import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Returns a unique, persistent hardware/OS identifier for the device.
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        // androidInfo.id represents the unique hardware build ID / ANDROID_ID
        return androidInfo.id.isNotEmpty ? androidInfo.id : 'unknown_android_device';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        // identifierForVendor is unique per vendor per iOS device
        return iosInfo.identifierForVendor ?? 'ios_unknown_device';
      } else {
        return 'unknown_platform_device';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'fallback_device_id';
    }
  }
}
