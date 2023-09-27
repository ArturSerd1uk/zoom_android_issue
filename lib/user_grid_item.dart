import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';

class UserGridItem extends StatelessWidget {
  final ZoomVideoSdkUser user;
  final bool isTalking;
  final bool isCameraOff;

  const UserGridItem({super.key, required this.user, required this.isTalking, required this.isCameraOff});

  // TODO leads to android app crush
  // @override
  // Widget build(BuildContext context) {
  //   final size = MediaQuery.of(context).size;
  //
  //   return Stack(
  //     children: [
  //       Container(
  //         decoration: BoxDecoration(
  //           border: Border.all(width: 2.5, color: isTalking ? Colors.orange : Colors.transparent),
  //           color: Colors.black,
  //         ),
  //         child: ClipRect(
  //           child: OverflowBox(
  //             maxWidth: double.infinity,
  //             maxHeight: double.infinity,
  //             alignment: Alignment.center,
  //             child: FittedBox(
  //               fit: BoxFit.cover,
  //               alignment: Alignment.center,
  //               child: SizedBox(
  //                 width: size.width / 3,
  //                 height: size.height / 3,
  //                 child: View(creationParams: {
  //                   "userId": user.userId,
  //                   "sharing": false,
  //                   "preview": false,
  //                   "focused": false,
  //                   "hasMultiCamera": false,
  //                   "videoAspect": VideoAspect.FullFilled,
  //                   "fullScreen": false,
  //                 }),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Align(
  //         alignment: Alignment.bottomLeft,
  //         child: Padding(
  //           padding: const EdgeInsets.all(11.0),
  //           child: Text(
  //             user.userName,
  //             style: const TextStyle(
  //               fontSize: 14.0,
  //               fontWeight: FontWeight.w400,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return View(creationParams: {
      "userId": user.userId,
      "sharing": false,
      "preview": false,
      "focused": false,
      "hasMultiCamera": false,
      "videoAspect": VideoAspect.FullFilled,
      "fullScreen": false,
    });
  }
}
