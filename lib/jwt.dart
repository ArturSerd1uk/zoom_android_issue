import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:zoom_android_issue/zoom_config.dart';

String makeId(int length) {
  String result = "";
  String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  int charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result += characters[Random().nextInt(charactersLength)];
  }
  return result;
}

String generateJwt(String sessionName, String roleType) {
  try {
    var iat = DateTime.now();
    var exp = DateTime.now().add(const Duration(days: 2));
    final jwt = JWT(
      {
        'app_key': configs["ZOOM_SDK_KEY"],
        'version': 1,
        'user_identity': makeId(10),
        'iat': (iat.millisecondsSinceEpoch / 1000).round(),
        'exp': (exp.millisecondsSinceEpoch / 1000).round(),
        'tpc': sessionName,
        'role_type': int.parse(roleType),
        'cloud_recording_option': 1,
      },
    );

    return jwt.sign(SecretKey(configs["ZOOM_SDK_SECRET"]));
  } catch (e) {
    return '';
  }
}
