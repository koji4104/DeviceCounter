import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'device_model.dart';
import 'dart:convert';

/// sample data
String testData = '''[
{"name":"AAA-100000"}
,{"name":"BBB-100000"}
,{"name":"CCC-100000"}
]''';

class SampleUpnpData extends UpnpData {
  String deviceType='Test';
  String urlBase='Test';
  String friendlyName='Test';
  String manufacturer='Test';
  String modelName='Test';
  String udn='Test';
  String uuid='Test';
  String url='Test';
  String presentationUrl='http://192.168.103.31/test';
  String modelType='Test';
  String modelDescription='Test';
  String modelNumber='Test';
  String manufacturerUrl='Test';
  SampleDevice(){}
}

final deviceListProvider = ChangeNotifierProvider((ref) => deviceListNotifier(ref));
class deviceListNotifier extends ChangeNotifier {
  List<DeviceData> list = [];
  String selectid = "";
  bool isTest = false;

  deviceListNotifier(ref){
    if(isTest){
      var json = jsonDecode(testData);
      for(var j in json){
        DeviceData data = DeviceData(name:j['name']);
        data.upnpData = SampleUpnpData();
        data.upnpData!.friendlyName = j['name'];
        list.add(data);
      }
    }
  }

  /// Add.
  /// Do not add the same.
  add(DeviceData newdata){
    bool find = false;
    for(DeviceData d in list) {
      if(d.deviceid == newdata.deviceid){
        find = true;
      }
      if(d.ipv4 == newdata.ipv4){
        find = true;
      }
      if(d.upnpData!=null && newdata.upnpData!=null){
        if(d.upnpData!.uuid == newdata.upnpData!.uuid){
          find = true;
        }
      }
      if(d.networkData!=null && newdata.networkData!=null){
        if(d.networkData!.wifiIPv4 == newdata.networkData!.wifiIPv4){
          find = true;
        }
      }      
    }
    if(find == false){
      if(newdata.networkData!=null){
        list.insert(0, newdata);
      } else {
        list.add(newdata);
      }
      this.notifyListeners();
    }
  }

  /// select device (one)
  select(String deviceid){
    this.selectid = deviceid;
    this.notifyListeners();
  }

  /// selected device (one)
  DeviceData? getSelected() {
    for(DeviceData d in list) {
      if(d.deviceid == selectid) {
        return d;
      }
    }
    return null;
  }
}

/// for Progress (0.0-1.0)
final scanProgressProvider = StateProvider<double>((ref) {
  return 0.0;
});

/// true=ThemeData.dark(), false=ThemeData.light()
final isDarkProvider = StateProvider<bool>((ref) {
  return true;
});

/// Color data (dark or light)
final colorProvider = ChangeNotifierProvider((ref) => colorNotifier(ref));
class colorNotifier extends ChangeNotifier {
  colorNotifier(ref) {
    this.isDark = ref.watch(isDarkProvider);
  }
  bool isDark = true;
  Color get panelBgColor => isDark ? Color(0xFF444444) : Color(0xFFFFFFFF);
  Color get panelFgColor => isDark ? Color(0xFFFFFFFF) : Color(0xFF222222);
  Color get menuBgColor => isDark ? Color(0xFF223355) : Color(0xFF223355);
  Color get menuFgColor => isDark ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF);
}

