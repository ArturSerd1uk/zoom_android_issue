import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum AppPlatforms { android, ios }

class ZoomConfig {
  ZoomConfig();

  static const String defaultSessionName = 'test';
  static const String defaultSessionPwd = '123456';
  static const String defaultUserName = 'test';
  static const String defaultSessionRole = '1'; // 1 - admin 0 - user
  static const int sessionIdleTimeoutMins = 60;
  static const String domain = 'zoom.us';
  static const bool enableLog = true;

  static const Map<String, bool> sdkAudioOptions = {
    "connect": true,
    "mute": false,
    "autoAdjustSpeakerVolume": true
  };
  static const Map<String, bool> sdkVideoOptions = {"localVideoOn": true};

  static Map<String, List<Permission>> platformPermissions = {
    AppPlatforms.ios.name: [
      Permission.camera,
      Permission.microphone,
    ],
    AppPlatforms.android.name: [
      Permission.camera,
      Permission.microphone,
      Permission.bluetoothConnect,
      Permission.phone,
      Permission.storage,
    ],
  };

  static get permissionsList => Platform.isAndroid
      ? platformPermissions[AppPlatforms.android.name]
      : platformPermissions[AppPlatforms.ios.name];
}

const Map configs = {
  'ZOOM_SDK_KEY': '', // TODO place your key
  'ZOOM_SDK_SECRET': '', // TODO place your secret
};
