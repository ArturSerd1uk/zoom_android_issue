import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zoom_android_issue/session_call_page.dart';
import 'package:zoom_android_issue/zoom_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zoom video sdk demo',
      routes: {
        '/': (context) => const MyHomePage(),
        '/call': (context) => const SessionCallPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ZoomVideoSdk zoom = ZoomVideoSdk();

  @override
  void initState() {
    InitConfig initConfig = InitConfig(domain: ZoomConfig.domain, enableLog: ZoomConfig.enableLog);

    zoom.initSdk(initConfig);

    requestFilePermissions();

    super.initState();
  }

  Future<bool> requestFilePermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    bool blocked = false;
    List<Permission> notGranted = [];

    List<Permission> permissions = ZoomConfig.permissionsList;

    Map<Permission, PermissionStatus>? statuses = await permissions.request();

    statuses.forEach((key, status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        blocked = true;
      } else if (!status.isGranted) {
        notGranted.add(key);
      }
    });

    if (notGranted.isNotEmpty) {
      notGranted.request();
    }

    if (blocked) {
      return await openAppSettings();
    }

    return true;
  }

  void _onJoinSessionHandler() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SessionCallPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _onJoinSessionHandler, child: const Text('join session')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    zoom.cleanup();

    super.dispose();
  }
}
