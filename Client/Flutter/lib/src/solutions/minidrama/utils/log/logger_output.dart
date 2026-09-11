import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
///日志输出到控制台和文件中
///log输出方法在异步方法中被调用，会造成方法调用无法回溯
///输出到文件需要初始化获取文件路径，获取文件路径是异步方法，这里移到内部初始化，避免影响到方法栈回溯
class MyLogOutput extends LogOutput {
  IOSink? _sink;
  //log文件父级目录
  Directory? _directory;
  //log文件后缀
  final fileSuffix = '.txt';
  @override
  void output(OutputEvent event) {
    // ignore: avoid_print
    event.lines.forEach(print);
    _logToFile(event);
  }

  void _logToFile(OutputEvent event) {
    //输出到文件的log，为避免部分颜色相关字符乱码，需要处理
    OutputEvent newEvent = event;
    switch(event.level) {
      case Level.info:
        var lines = event.lines.map((e) => e.substring(10, e.length -4)).toList();
        newEvent = OutputEvent(event.origin, lines);
        break;
      case Level.debug:
      //debug不含特殊编码字符，无需处理
        break;
      default:
        var lines = event.lines.map((e) => e.substring(11, e.length -4)).toList();
        newEvent = OutputEvent(event.origin, lines);
    }

    //错误级别以上log输出到文件显示方法栈回溯
    //一般性log输出到文件不显示方法栈回溯；
    OutputEvent lastEvent;
    switch(newEvent.level) {
      case Level.verbose:
      case Level.debug:
      case Level.info:
      case Level.warning:
        final length = newEvent.lines.length;
        final date = newEvent.lines.elementAt(length - 4);
        final content = newEvent.lines.elementAt(length - 2);
        lastEvent = OutputEvent(event.origin, ['$date$content']);
        break;
      default:
        {
          lastEvent = newEvent;
        }
    }
    //初始化输出文件路径
   if (_directory == null || !_directory!.existsSync()) {
     getExternalStorageDirectory().then((direct) {
       _directory = Directory('${direct!.path}/log');
       if (!_directory!.existsSync()) {
         _directory!.createSync(recursive: true);
       }
       _write(lastEvent);
     });
   } else {
     _write(lastEvent);
   }

  }

  ///此方法调用需保证[_directory]已初始化
  void _write(OutputEvent event) {
    //以日期作为log文件名
    var file = File(_getFileLogPath(DateTime.now()));
    if (!file.existsSync()) {
      //文件不存在后，重写获取指向新文件的句柄
      _sink = file.openWrite(
        mode: FileMode.writeOnlyAppend,
      );
    }

    //这里避免_sink未初始化
    _sink ??= file.openWrite(
      mode: FileMode.writeOnlyAppend,
    );
    _sink?.writeAll(event.lines, '\n');
    _sink?.writeln();
    _deleteLogFile(_directory!.path);
  }

  @override
  // 修改返回类型为 Future<void> 以符合父类方法的签名
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }

  ///输出log文件缓存，仅仅保留两天的log
  void _deleteLogFile(String directory) {

    //获取最近两天log文件名称
    final now = DateTime.now();
    final nowLogPath = _getFileLogPath(now);
    final yesterdayLogPath = _getFileLogPath(DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - 24 * 60 * 60 * 1000));

    final target = Directory(directory);
    //筛选log目录下所有文件
    if (target.existsSync()) {
      target.listSync().forEach((element) {
        //不是最近两天的文件都删除
        if (element.path != nowLogPath && element.path != yesterdayLogPath) {
          element.deleteSync();
        }
      });
    }
  }

  String _getFileLogPath(DateTime time) {
    final nowLogName = '${time.year}-${time.month}-${time.day}$fileSuffix';

    print('${_directory?.path}/$nowLogName');
    return '${_directory?.path}/$nowLogName';
  }
}
