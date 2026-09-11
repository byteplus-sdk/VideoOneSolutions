import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/drama_item_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/api.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/request.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

class FeedService {
  int _offset = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  int get feedCount => _feedList.length;

  final List<DramaItem> _feedList = [];

  List<DramaItem> getFeedList() {
    return _feedList;
  }

  void addFeed(DramaItem feed) {
    _feedList.add(feed);
  }

  void removeFeed(int index) {
    if (index >= 0 && index < _feedList.length) {
      _feedList.removeAt(index);
    }
  }

  void dispose() {
    _offset = 0;
    _hasMore = true;
    _feedList.clear();
  }

  Future<RequestStatus> loadFeed() async {
    try {
      final res = await Request.postRequest(GET_DRAMA_FEED, {
        'offset': _offset,
        'page_size': DEFAULT_FEED_PAGE_SIZE,
        'play_info_type': DEFAULT_PLAY_INFO_TYPE
      });
      if (res['response'] is List) {
        final data = res['response'];
        if (data.length > 0) {
          for (var item in data) {
            _feedList.add(DramaItem.fromJson(item));
          }
          _offset += data.length as int;
        }
        if (data.length == DEFAULT_FEED_PAGE_SIZE) {
          _hasMore = true;
        } else {
          _hasMore = false;
        }
        return RequestStatus.SUCCESS;
      }
      return RequestStatus.FAILED;
    } catch (e) {
      _logger.e('fetch feed fail', error: e);
      return RequestStatus.FAILED;
    }
  }
}
