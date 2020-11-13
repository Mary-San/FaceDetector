import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class ExportVideoFrame {
  static const MethodChannel _channel =
      const MethodChannel('export_video_frame');

   Future<bool> cleanImageCache() async {
    final String result = await _channel.invokeMethod('cleanImageCache');
    if (result == "success") {
      return true;
    }
    return false;
  }

   Future<bool> saveImage(File file, String albumName,{String waterMark,Alignment alignment,double scale}) async {
    Map<String,dynamic> para = {"filePath":file.path,"albumName":albumName};
    if (waterMark != null) {
      para.addAll({"waterMark":waterMark});
      if (alignment != null) {
        para.addAll({"alignment":{"x":alignment.x,"y":alignment.y}});
      } else {
        para.addAll({"alignment":{"x":1,"y":1}});
      }
      if (scale != null) {
        para.addAll({"scale":scale});
      } else {
        para.addAll({"scale":1.0});
      }
    }
    final bool result = await _channel.invokeMethod('saveImage', para);
    return result;
  }

   Future<List<File>> exportImage(String filePath, int number, double quality) async {
    var para = {"filePath":filePath,"number":number,"quality":quality};
    final List<dynamic> list = await _channel.invokeMethod('exportImage', para);
    var result = list.cast<String>().map((path) => File.fromUri(Uri.file(path))).toList();
    return result;
  }

   Future<File> exportImageBySeconds(File file, Duration duration,double radian) async {
    var milli = duration.inSeconds ;
    var para = {"filePath":file.path,"duration":milli,"radian":radian};
    final String path = await _channel.invokeMethod('exportImageBySeconds', para);
    try {
      var result = File.fromUri(Uri.file(path));
      return result;
    } catch (e) {
      throw e;
    }
  }
}