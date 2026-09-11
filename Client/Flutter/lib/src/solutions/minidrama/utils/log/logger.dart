import 'package:logger/logger.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/log/logger_output.dart';
///log输出：输出到控制台和本地缓存文件
///输出形式如下：
/// ┌──────────────────────────
/// │ Error info
/// ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
/// │ Method stack history
/// ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
/// │ Log message
/// └──────────────────────────
class LoggerUtil {
  final String defaultTag = 'daemon_li';
  ///栈方法追溯数量
  final int _methodCount = 5;
  ///显示的日志级别
  final Level _level = Level.verbose;

  LoggerUtil._internal();

  factory LoggerUtil() => _instance;

  static late final LoggerUtil _instance = LoggerUtil._internal();

  Logger? logger;

  ///初始化log输出设置
  void _init() {
    logger ??= Logger(
        //输出该级别以上的日志
        level: _level,
        filter: _MyLogFilter(),
        //log输出到控制台和本地缓存文件,
        output: MyLogOutput(),
        printer: PrettyPrinter(
          methodCount: _methodCount, //方法调用追溯数量
          printTime: true,
        ));
  }

  ///最低级log：1
  void v(message, {String? tag}) {
    _init();
    tag = tag == null ? defaultTag: '${defaultTag}_$tag';
    logger!.v('$tag: $message');
  }
  ///debug级：2
  void d(message, {String? tag}) {
    _init();
    tag = tag == null ? defaultTag: '${defaultTag}_$tag';
    logger!.d('$tag: $message');
  }
  ///普通级信息输出：3
  void i(message, {String? tag}) {
    _init();
    tag = tag == null ? defaultTag: '${defaultTag}_$tag';
    logger!.i('$tag: $message');
  }
  ///警告级：3
  void w(message, {String? tag}) {
    _init();
    tag = tag == null ? defaultTag: '${defaultTag}_$tag';
    logger!.w('$tag: $message');
  }
  ///严重级：5
  void e(message, {String? tag}) {
    _init();
    tag = tag == null ? defaultTag: '${defaultTag}_$tag';
    logger!.e('$tag: $message');
  }

  ///超级严重级：6
  void wtf(message, {String? tag}) {
    _init();
    tag = tag == null ? defaultTag: '${defaultTag}_$tag';
    logger!.wtf('$tag: $message');
  }
}

///日志输出过滤器，可用于控制输出仅仅符合指定级别条件的log
class _MyLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    //仅仅输出某一级别日志
    // if (event.level == Level.debug) {
    //   return true;
    // } else {
    //   return false;
    // }
    //默认输出所有级别log
    return true;
  }
}

