import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/video_meta.dart';

class DramaItem {
  DramaMeta? dramaMeta;
  final VideoMeta videoMeta;
  DramaItem(this.videoMeta, [this.dramaMeta]);

  setDramaMeta(DramaMeta meta) {
    dramaMeta = meta;
  }

  factory DramaItem.fromJson(Map<String, dynamic> json) {
    final dramaMeta = json['drama_meta'] == null
        ? null
        : DramaMeta.fromJson(json['drama_meta']);
    final videoMeta = VideoMeta.fromJson(json['video_meta']);
    return DramaItem(videoMeta, dramaMeta);
  }

  Map<String, dynamic> toJson() {
    return {
      'drama_meta': dramaMeta?.toJson(),
      'video_meta': videoMeta.toJson(),
    };
  }
}
