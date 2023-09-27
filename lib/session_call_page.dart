import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:zoom_android_issue/call_controls.dart';
import 'package:zoom_android_issue/jwt.dart';
import 'package:zoom_android_issue/users_grid.dart';
import 'package:zoom_android_issue/zoom_config.dart';

class SessionCallPage extends StatefulWidget {
  const SessionCallPage({Key? key}) : super(key: key);

  @override
  State<SessionCallPage> createState() => _SessionCallPageState();
}

class _SessionCallPageState extends State<SessionCallPage> {
  ZoomVideoSdk zoom = ZoomVideoSdk();
  ZoomVideoSdkEventListener eventListener = ZoomVideoSdkEventListener();

  late final dynamic _sessionJoinListener;
  late final dynamic _userJoinListener;
  late final dynamic _userLeaveListener;
  late final dynamic _sessionLeaveListener;
  late final dynamic _userAudioStatusChangedListener;
  late final dynamic _userActiveAudioChangedListener;

  List<ZoomVideoSdkUser> _sessionParticipants = [];
  List<String> _talkingUsers = [];
  List<String> _usersWithCameraOff = [];
  String sessionName = '';
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isVideoOn = false;
  bool isInSession = false;

  @override
  void initState() {
    _initSessionListeners();
    _joinSession();

    super.initState();
  }

  void _joinSession() {
    Future<void>.microtask(() async {
      final String token = generateJwt(ZoomConfig.defaultSessionName, ZoomConfig.defaultSessionRole);

      log('session token = $token', name: 'zoomSessionLog');

      JoinSessionConfig joinSession = JoinSessionConfig(
        sessionName: ZoomConfig.defaultSessionName,
        sessionPassword: ZoomConfig.defaultSessionPwd,
        token: token,
        userName: ZoomConfig.defaultUserName,
        audioOptions: ZoomConfig.sdkAudioOptions,
        videoOptions: ZoomConfig.sdkVideoOptions,
        sessionIdleTimeoutMins: ZoomConfig.sessionIdleTimeoutMins,
      );

      try {
        await zoom.joinSession(joinSession);
      } catch (e) {
        log('Error while join session $e', name: 'zoomSessionLog');
        const AlertDialog(title: Text("Error"), content: Text("Failed to join the session"));
      }
    });
  }

  _initSessionListeners() {
    eventListener.addEventListener();

    var emitter = eventListener.eventEmitter;

    _sessionJoinListener = emitter.on(EventType.onSessionJoin, (sessionUser) async {
      isInSession = true;

      log('_sessionJoinListener', name: 'zoomSessionLog');

      ZoomVideoSdkUser mySelf = ZoomVideoSdkUser.fromJson(jsonDecode(sessionUser.toString()));
      List<ZoomVideoSdkUser>? remoteUsers = await zoom.session.getRemoteUsers();
      var muted = await mySelf.audioStatus?.isMuted();
      var videoOn = await mySelf.videoStatus?.isOn();
      var speakerOn = await zoom.audioHelper.getSpeakerStatus();

      await zoom.audioHelper.setSpeaker(true);

      _sessionParticipants = [mySelf, ...?remoteUsers];
      isMuted = muted!;
      isSpeakerOn = speakerOn;
      isVideoOn = videoOn!;

      setState(() {});
    });

    _sessionLeaveListener = emitter.on(EventType.onSessionLeave, (data) async {
      isInSession = false;

      log('_sessionLeaveListener $data', name: 'zoomSessionLog');

      _sessionParticipants = <ZoomVideoSdkUser>[];

      setState(() {});
    });

    _userJoinListener = emitter.on(EventType.onUserJoin, (Map data) async {
      log('_userJoinListener $data', name: 'zoomSessionLog');

      ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
      var userListJson = jsonDecode(data['remoteUsers']) as List;

      setState(() {
        _sessionParticipants = [
          mySelf!,
          ...userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
        ];
      });
    });

    _userLeaveListener = emitter.on(EventType.onUserLeave, (Map data) async {
      if (!context.mounted) return;

      log('_userLeaveListener $data', name: 'zoomSessionLog');

      ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
      var remoteUserListJson = jsonDecode(data['remoteUsers']) as List;

      setState(() {
        _sessionParticipants = [
          mySelf!,
          ...remoteUserListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList()
        ];
      });
    });

    _userAudioStatusChangedListener = emitter.on(EventType.onUserAudioStatusChanged, (Map data) async {
      log('_userAudioStatusChangedListener $data', name: 'zoomSessionLog');

      final ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();

      final List<ZoomVideoSdkUser> userList = _getSessionChangedUsers(data);

      for (var user in userList) {
        if (user.userId != mySelf?.userId) return;
        mySelf?.audioStatus?.isMuted().then((muted) => isMuted = muted);
      }

      setState(() {});
    });
  }

  List<ZoomVideoSdkUser> _getSessionChangedUsers(Map data) {
    final List userListJson = jsonDecode(data['changedUsers']) as List;

    return userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
  }

  void onPressAudio() async {
    ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
    if (mySelf == null) return;

    final audioStatus = mySelf.audioStatus;

    if (audioStatus == null) return;

    final bool muted = await audioStatus.isMuted();

    if (muted) {
      await zoom.audioHelper.unMuteAudio(mySelf.userId);
    } else {
      await zoom.audioHelper.muteAudio(mySelf.userId);
    }
  }

  void onPressVideo() async {
    ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
    if (mySelf == null) return;

    final videoStatus = mySelf.videoStatus;

    if (videoStatus == null) return;

    final bool videoOn = await videoStatus.isOn();

    if (videoOn) {
      await zoom.videoHelper.stopVideo();
    } else {
      await zoom.videoHelper.startVideo();
    }
  }

  void onToggleSpeaker() async {
    ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();

    if (mySelf == null) return;

    await zoom.audioHelper.setSpeaker(!isSpeakerOn);

    final isOn = await zoom.audioHelper.getSpeakerStatus();

    setState(() {
      isSpeakerOn = isOn;
    });
  }

  bool get userJoinedToSession => isInSession && _sessionParticipants.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              if (userJoinedToSession)
                CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    UsersGrid(
                      users: _sessionParticipants,
                      talkingUsers: _talkingUsers,
                      usersWithCameraOff: _usersWithCameraOff,
                    ),
                  ],
                ),
            ],
          ),
        ),
        bottomNavigationBar: userJoinedToSession
            ? SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Expanded(
                      child: CallControls(
                        onMuteHandler: onPressAudio,
                        onStopVideoHandler: onPressVideo,
                        isMuted: isMuted,
                        isCameraOn: isVideoOn,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }

  @override
  void dispose() {
    zoom.leaveSession(false);

    eventListener.eventEmitter.listeners.map((e) => e.cancel());

    eventListener.eventEmitter.removeEventListener(_sessionJoinListener);
    eventListener.eventEmitter.removeEventListener(_userJoinListener);
    eventListener.eventEmitter.removeEventListener(_userLeaveListener);
    eventListener.eventEmitter.removeEventListener(_sessionLeaveListener);
    eventListener.eventEmitter.removeEventListener(_userAudioStatusChangedListener);
    eventListener.eventEmitter.removeEventListener(_userActiveAudioChangedListener);

    super.dispose();
  }
}
