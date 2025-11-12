import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// TODO: Add supabase_flutter to pubspec.yaml when ready to integrate push notifications
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PushTokenSimple {
  PushTokenSimple._();

  static final instance = PushTokenSimple._();

  static const _prefsInstallIdKey = 'installation_id';
  static const _prefsLastTokenKey = 'last_fcm_token';
  static const _prefsLastMetaKey = 'last_fcm_meta_json';

  // TODO: Uncomment when supabase_flutter is added to pubspec.yaml
  // final _sb = Supabase.instance.client;
  final _fcm = FirebaseMessaging.instance;
  bool _isTokenRefreshListenerActive = false;

  /// Call this after the user grants notification permission.
  /// It handles the initial token upload and sets up the listener for future refreshes.
  Future<void> registerDeviceForCurrentUser() async {
    debugPrint('🚀 [PushToken] registerDeviceForCurrentUser() called');

    final token = await _fcm.getToken();
    debugPrint('🎟️ [PushToken] Got token: $token');

    if (token != null) {
      await _upsertIfChanged(token);
    }

    // Set up the listener for when the token is automatically refreshed by FCM.
    if (!_isTokenRefreshListenerActive) {
      _isTokenRefreshListenerActive = true;
      _fcm.onTokenRefresh.listen((refreshedToken) async {
        debugPrint('♻️ [PushToken] Token refresh received');
        await _upsertIfChanged(refreshedToken);
      });
    }
  }

  /// This is still useful for existing users who re-open the app.
  /// It ensures their token is up-to-date if it expired or the app version changed.
  Future<void> onAppOpen() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _upsertIfChanged(token);
    }
  }

  Future<void> _upsertIfChanged(String token) async {
    debugPrint('🔍 [PushToken] Checking token changes...');

    final prefs = await SharedPreferences.getInstance();
    final lastToken = prefs.getString(_prefsLastTokenKey);
    
    // TODO: Uncomment when supabase_flutter is added
    // final uid = _sb.auth.currentUser?.id;
    // if (uid == null) {
    //   debugPrint('⚠️ [PushToken] No user logged in.');
    //   return;
    // }

    // TODO: Uncomment when supabase_flutter is added
    // final deviceId = await _getOrCreateInstallationId();
    // final platform = Platform.isIOS
    //     ? 'ios'
    //     : (Platform.isAndroid ? 'android' : 'web');
    final meta = await _collectMeta();
    final metaJson = jsonEncode(meta);
    final lastMetaJson = prefs.getString(_prefsLastMetaKey);
    final needsUpdate = (lastToken != token) || (lastMetaJson != metaJson);

    if (!needsUpdate) {
      debugPrint('✅ [PushToken] No changes, skipping upsert.');
      return;
    }

    debugPrint('📡 [PushToken] Uploading token via upsert_fcm_token...');

    // TODO: Uncomment when supabase_flutter is added to pubspec.yaml
    // try {
    //   final deviceId = await _getOrCreateInstallationId();
    //   final platform = Platform.isIOS
    //       ? 'ios'
    //       : (Platform.isAndroid ? 'android' : 'web');
    //   final response = await _sb.rpc(
    //     'upsert_fcm_token',
    //     params: {
    //       'p_auth_id': uid,
    //       'p_device_id': deviceId,
    //       'p_fcm_token': token,
    //       'p_platform': platform,
    //       'p_app_version': meta['app_version'],
    //       'p_build_number': meta['build_number'],
    //       'p_os_version': meta['os_version'],
    //       'p_device_model': meta['device_model'],
    //     },
    //   );
    //
    //   debugPrint('✅ [PushToken] RPC success: $response');
    //   await prefs.setString(_prefsLastTokenKey, token);
    //   await prefs.setString(_prefsLastMetaKey, metaJson);
    // } catch (e) {
    //   debugPrint('❌ [PushToken] Error upserting FCM token via RPC: $e');
    // }
    
    // For now, just save the token locally
    await prefs.setString(_prefsLastTokenKey, token);
    await prefs.setString(_prefsLastMetaKey, metaJson);
    debugPrint('💾 [PushToken] Token saved locally (Supabase integration pending)');
  }

  Future<Map<String, String?>> _collectMeta() async {
    final pkg = await PackageInfo.fromPlatform();
    final dev = DeviceInfoPlugin();

    String? osVersion;
    String? deviceModel;

    if (Platform.isAndroid) {
      final a = await dev.androidInfo;
      osVersion = 'Android ${a.version.release} (SDK ${a.version.sdkInt})';
      deviceModel = '${a.manufacturer} ${a.model}'.trim();
    } else if (Platform.isIOS) {
      final i = await dev.iosInfo;
      osVersion = '${i.systemName} ${i.systemVersion}';
      deviceModel = i.utsname.machine;
    } else {
      osVersion = null;
      deviceModel = null;
    }

    return {
      'app_version': pkg.version,
      'build_number': pkg.buildNumber,
      'os_version': osVersion,
      'device_model': deviceModel,
    };
  }

  Future<String> _getOrCreateInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsInstallIdKey);

    if (existing != null && existing.isNotEmpty) {
      debugPrint('🆔 [PushToken] Using existing install ID: $existing');
      return existing;
    }

    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    final id = base64Url.encode(bytes).replaceAll('=', '');

    await prefs.setString(_prefsInstallIdKey, id);
    debugPrint('🆕 [PushToken] Generated new install ID: $id');

    return id;
  }

  /// Public method to get the device ID (for the dialog)
  Future<String> getDeviceId() async {
    return await _getOrCreateInstallationId();
  }
}

extension PushTokenSignOut on PushTokenSimple {
  Future<void> revokeForCurrentDevice() async {
    // TODO: Uncomment when supabase_flutter is added
    // final uid = Supabase.instance.client.auth.currentUser?.id;
    // if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString(PushTokenSimple._prefsInstallIdKey);
    if (deviceId == null) return;

    debugPrint('🧹 [PushToken] Revoking token for device $deviceId');

    // TODO: Uncomment when supabase_flutter is added to pubspec.yaml
    // try {
    //   await Supabase.instance.client.rpc(
    //     'revoke_fcm_token',
    //     params: {'p_auth_id': uid, 'p_device_id': deviceId},
    //   );
    //
    //   await prefs.remove(PushTokenSimple._prefsLastTokenKey);
    //   await prefs.remove(PushTokenSimple._prefsLastMetaKey);
    //   debugPrint('✅ [PushToken] Token revoked successfully');
    // } catch (e) {
    //   debugPrint('❌ [PushToken] Error revoking FCM token: $e');
    // }
    
    // For now, just remove local token
    await prefs.remove(PushTokenSimple._prefsLastTokenKey);
    await prefs.remove(PushTokenSimple._prefsLastMetaKey);
    debugPrint('💾 [PushToken] Local token removed (Supabase integration pending)');
  }
}

