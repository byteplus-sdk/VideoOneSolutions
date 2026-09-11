import 'package:collection/collection.dart';

class VideoMeta {
  String? vid; 
  int? order; 
  bool? vip; 
  String? caption; 
  double? duration; 
  String? coverUrl; 
  int? playTimes; 
  int? height; 
  int? width; 
  int? like; 
  int? comment; 
  String? playAuthToken; 
  String? subtitleAuthToken; 
  String? videoModel; 
  int? uid; 
  int? displayType; 
  String? name; 
  String? subtitle; 

  VideoMeta(
      {this.vid,
      this.order,
      this.vip,
      this.caption,
      this.duration,
      this.coverUrl,
      this.playTimes,
      this.height,
      this.width,
      this.like,
      this.comment,
      this.playAuthToken,
      this.subtitleAuthToken,
      this.videoModel,
      this.uid,
      this.displayType,
      this.name,
      this.subtitle});

  factory VideoMeta.fromJson(Map<String, dynamic> json) => VideoMeta(
        vid: json['vid'] as String?,
        order: json['order'] as int?,
        vip: json['vip'] as bool?,
        caption: json['caption'] as String?,
        duration: (json['duration'] as num?)?.toDouble(),
        coverUrl: json['cover_url'] as String?,
        playTimes: json['play_times'] as int?,
        height: json['height'] as int?,
        width: json['width'] as int?,
        like: json['like'] as int?,
        comment: json['comment'] as int?,
        playAuthToken: json['play_auth_token'] as String?,
        subtitleAuthToken: json['subtitle_auth_token'] as String?,
        videoModel: json['video_model'] as String?,
        uid: json['uid'] as int?,
        displayType: json['display_type'] as int?,
        name: json['name'] as String?,
        subtitle: json['subtitle'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'vid': vid,
        'order': order,
        'vip': vip,
        'caption': caption,
        'duration': duration,
        'cover_url': coverUrl,
        'play_times': playTimes,
        'height': height,
        'width': width,
        'like': like,
        'comment': comment,
        'play_auth_token': playAuthToken,
        'subtitle_auth_token': subtitleAuthToken,
        'video_model': videoModel,
        'uid': uid,
        'display_type': displayType,
        'name': name,
        'subtitle': subtitle,
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! VideoMeta) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      vid.hashCode ^
      order.hashCode ^
      vip.hashCode ^
      caption.hashCode ^
      duration.hashCode ^
      coverUrl.hashCode ^
      playTimes.hashCode ^
      height.hashCode ^
      width.hashCode ^
      like.hashCode ^
      comment.hashCode ^
      playAuthToken.hashCode ^
      subtitleAuthToken.hashCode ^
      videoModel.hashCode ^
      uid.hashCode ^
      displayType.hashCode ^
      name.hashCode;
}
