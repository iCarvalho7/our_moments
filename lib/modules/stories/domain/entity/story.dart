import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';

class Story {
  final String url;

  Story({required this.url});

  StoryType get type => url.isVideo
      ? StoryType.video
      : url.isImage
          ? StoryType.image
          : StoryType.undefined;

  bool get isNetwork => url.isHttpUrl;
}

enum StoryType { video, image, undefined }
