// import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final String path;
  const VideoThumbnail({super.key, required this.path});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail>
    with AutomaticKeepAliveClientMixin {
  String thumb = '';
  bool loading = true;
  

  @override


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Image.asset(
      'assets/images/video-placeholder.png',
      height: 40,
      width: 40,
      fit: BoxFit.cover,
    );
 
  }

  @override
  bool get wantKeepAlive => true;
}
