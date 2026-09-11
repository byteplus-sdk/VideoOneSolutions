// ignore_for_file: constant_identifier_names, non_constant_identifier_names
// length of the username
const USERNAME_LENGTH = 6;

// Request status enum
enum RequestStatus {
  SUCCESS,
  FAILED,
}

// feed page size
const DEFAULT_FEED_PAGE_SIZE = 10;

// use 0 as play_info_type for video sdk
const DEFAULT_PLAY_INFO_TYPE = 0;

enum LoadStatus {
  LOADING,
  SUCCESS,
  FAILED,
  NET_FAIL,
}

const USERNAME = 'admin';
const USER_ID = '123456';

// App id for license
const APP_ID = "698142";
const OPEN_DEBUG_LOG = true;
const LICENSE_PATH = 'assets/minidrama/licenses/l-1301-ch-vod-a-698142.lic';
const ANDROID_CHANNEL = 'Google play store';
const IOS_CHANNEL = 'App Store';
const CACHE_MAX_SIZE = 300 * 1024 * 1024;

// config for video sdk
class GlobalSdkConfiguration {
  static bool useSurfaceView = false;
  static bool closeTextureRender = false;
  static bool isHDRSource = false;
  static bool isTrackVolume = false;
  static bool isHardwareDecode = true;
  static bool testVidSource = false;
  static String vidResoluytionBFS = '720P';
  static bool isClip = false;
  static String scaleMode = 'None';
  static bool enableCacheEncrypt = true;
  static bool enableHLSProxy = true;
  static bool enableStrategyPreload = true;
  static bool enableStrategyPreRender = true;
}

// 播放速度
enum PlaySpeed {
  EXTREMELY_FAST(3.0),
  VERY_FAST(2.0),
  FAST(1.5),
  NORMAL(1.0),
  SLOW(0.5);

  final double speed;
  const PlaySpeed(this.speed);
}

enum VideoResolution {
  TTVideoEngineResolutionTypeSD('360P'),
  TTVideoEngineResolutionTypeHD(
    '480P',
  ),
  TTVideoEngineResolutionTypeHD_H('540P'),
  TTVideoEngineResolutionTypeFullHD('720P'),
  TTVideoEngineResolutionType1080P('1080P'),
  TTVideoEngineResolutionType2K('2K'),
  TTVideoEngineResolutionType4K('4K');

  final String displayName;
  const VideoResolution(this.displayName);

  static getVideoResolutionByName(String name) {
    for (var resolution in VideoResolution.values) {
      if (resolution.name == name) {
        return resolution.displayName;
      }
    }
    return '360P';
  }
}
