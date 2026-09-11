import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/comment_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/api.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/request.dart';

class Comments {
  List<Comment> comments = [];
  late final String vid;
  get commentCount => comments.length;
  Comments({
    required this.vid,
  });

  add(Comment comment) {
    comments.add(comment);
  }

  Future<RequestStatus> loadComments() async {
    final res = await Request.getRequest(GET_VIDEO_COMMENT, {"vid": vid});
    if (res['response'] is List) {
      final data = res['response'];

      for (var item in data) {
        comments.add(Comment.fromJson(item));
      }
    }
    return RequestStatus.SUCCESS;
  }
}
