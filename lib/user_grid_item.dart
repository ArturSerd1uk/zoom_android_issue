import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';

class UserGridItem extends StatelessWidget {
  final ZoomVideoSdkUser user;
  final bool isTalking;
  final bool isCameraOff;

  const UserGridItem({super.key, required this.user, required this.isTalking, required this.isCameraOff});

  @override
  Widget build(BuildContext context) {
    /* As per flutter documentation “The stack paints its children in order with the first child being at the bottom”
    https://api.flutter.dev/flutter/widgets/Stack-class.html
   */

    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                child: View(creationParams: {
                  "userId": user.userId,
                  "sharing": false,
                  "preview": false,
                  "focused": false,
                  "hasMultiCamera": false,
                  "videoAspect": VideoAspect.FullFilled,
                  "fullScreen": false,
                }),
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(11.0),
            child: Text(
              'long user name',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
