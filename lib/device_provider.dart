import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'device_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const IconData ICON_WIFI = Icons.wifi;
const IconData ICON_SCAN = Icons.search;
const IconData ICON_UPNP = Icons.scanner;

final deviceListProvider = ChangeNotifierProvider((ref) => deviceListNotifier(ref));
class deviceListNotifier extends ChangeNotifier {
  List<DeviceData> list = [];
  String selectid = "";

  deviceListNotifier(ref){
    if(kIsWeb){
      UpnpData upnp = SampleUpnpData();
      DeviceData d1 = DeviceData(name:upnp.friendlyName);
      d1.upnpData = upnp;
      this.add(d1);

      NetworkData nw = SampleNetworkData();
      DeviceData d2 = DeviceData(name:nw.wifiIPv4);
      d2.networkData = nw;
      this.add(d2);

      DeviceData d3 = DeviceData(name:'10.0.2.25');
      d3.ipv4 = '10.0.2.25';
      this.add(d3);
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
      if(d.ipv4!='' && newdata.ipv4!=''){
        if(d.ipv4 == newdata.ipv4){
          find = true;
        }
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
  Color get shadowColor => isDark ? Color(0xFF222222) : Color(0xFFCCCCCC);

  Color get detailKeyColor => isDark ? Color(0xFFCCCCCC) : Color(0xFF555555);
}

