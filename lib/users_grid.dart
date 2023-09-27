import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:zoom_android_issue/user_grid_item.dart';

class UsersGrid extends StatelessWidget {
  final List<ZoomVideoSdkUser> users;
  final List<String> talkingUsers;
  final List<String> usersWithCameraOff;

  const UsersGrid({
    super.key,
    required this.users,
    required this.talkingUsers,
    required this.usersWithCameraOff,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: size.width / 3),
      itemCount: users.length,
      itemBuilder: (BuildContext context, int i) {
        final currentUser = users[i];

        return UserGridItem(
          user: currentUser,
          isTalking: talkingUsers.contains(currentUser.userId),
          isCameraOff: usersWithCameraOff.contains(currentUser.userId),
        );
      },
    );
  }
}
