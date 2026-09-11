import 'package:collection/collection.dart';

class DramaMeta {
  String? dramaId; 
  String? dramaTitle; 
  int? dramaPlayTimes; 
  String? dramaCoverUrl;
  bool? newRelease; 
  int? dramaLength; 
  int? dramaVideoOrientation; 

  DramaMeta({
    this.dramaId,
    this.dramaTitle,
    this.dramaPlayTimes,
    this.dramaCoverUrl,
    this.newRelease,
    this.dramaLength,
    this.dramaVideoOrientation,
  });


  factory DramaMeta.fromJson(Map<String, dynamic> json) => DramaMeta(
        dramaId: json['drama_id'] as String?,
        dramaTitle: json['drama_title'] as String?,
        dramaPlayTimes: json['drama_play_times'] as int?,
        dramaCoverUrl: json['drama_cover_url'] as String?,
        newRelease: json['new_release'] as bool?,
        dramaLength: json['drama_length'] as int?,
        dramaVideoOrientation: json['drama_video_orientation'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'drama_id': dramaId,
        'drama_title': dramaTitle,
        'drama_play_times': dramaPlayTimes,
        'drama_cover_url': dramaCoverUrl,
        'new_release': newRelease,
        'drama_length': dramaLength,
        'drama_video_orientation': dramaVideoOrientation,
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! DramaMeta) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      dramaId.hashCode ^
      dramaTitle.hashCode ^
      dramaPlayTimes.hashCode ^
      dramaCoverUrl.hashCode ^
      newRelease.hashCode ^
      dramaLength.hashCode ^
      dramaVideoOrientation.hashCode;
}
