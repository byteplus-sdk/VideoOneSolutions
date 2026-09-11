import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_item_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/video_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/api.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/request.dart';

class DramaService {
  DramaService({required this.dramaId});
  final String dramaId;
  final List<DramaItem> _dramaList = [];

  get dramaList => _dramaList;
  get dramaNeedPay => _dramaList.any((x) => x.videoMeta.vip == true);

  List<String> getAllUnlockVid() {
    final allUnlockList = _dramaList
        .where((element) => element.videoMeta.vip == true)
        .map((e) => e.videoMeta.vid as String)
        .toList();
    return allUnlockList;
  }

  List<String> getNext10UnlockVid() {
    final allUnlockList = getAllUnlockVid();
    return allUnlockList.sublist(
        0, allUnlockList.length < 10 ? allUnlockList.length : 10);
  }

  DramaItem? getDramaItemByIndex(int index) {
    if (index >= 0 && index < _dramaList.length) {
      return _dramaList[index];
    }
    return null;
  }

  dispose() {
    _dramaList.clear();
  }

  Future<void> loadDramaList() async {
    final res = await Request.postRequest(GET_DRAMA_LIST, {
      'user_id': USER_ID,
      'drama_id': dramaId,
      'play_info_type': DEFAULT_PLAY_INFO_TYPE
    });
    if (res['response'] is List) {
      _dramaList.clear();
      final data = res['response'];
      if (data.length > 0) {
        for (var item in data) {
          _dramaList.add(DramaItem(VideoMeta.fromJson(item)));
        }
      }
    }
  }

  Future<void> unlockDrama(List<String> vidList) async {
    final res = await Request.postRequest(UNLOCK_DRAMA, {
      'user_id': USER_ID,
      'drama_id': dramaId,
      'vid_list': vidList,
      'play_info_type': DEFAULT_PLAY_INFO_TYPE
    });
    if (res['response'] is List) {
      final data = res['response'];
      if (data.length > 0) {
        await loadDramaList();
      }
    }
  }
}
