import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'device_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const IconData ICON_WIFI = Icons.wifi;
const IconData ICON_SCAN = Icons.search;
const IconData ICON_UPNP = Icons.scanner;

const isTestMode = false;

final deviceListProvider = ChangeNotifierProvider((ref) => deviceListNotifier(ref));
class deviceListNotifier extends ChangeNotifier {
  List<DeviceData> list = [];
  String selectid = "";

  deviceListNotifier(ref){
    if(kIsWeb || isTestMode){
      // Sample data
      WifiData wd = SampleWifiData();
      DeviceData d1 = DeviceData(ipv4:'10.0.2.16');
      d1.wifiData = wd;
      this.add(d1);

      UpnpData upnp = SampleUpnpData();
      DeviceData d2 = DeviceData(ipv4:'10.0.2.17');
      d2.upnpData = upnp;
      this.add(d2);

      DeviceData d3 = DeviceData(ipv4:'10.0.2.20');
      this.add(d3);
      DeviceData d4 = DeviceData(ipv4:'10.0.2.21');
      this.add(d4);
    }
  }

  /// Add.
  /// Do not add the same.
  add(DeviceData newdata){
    // Wifi
    if(newdata.wifiData!=null){
      if(list.length==0){
        list.add(newdata);
        this.notifyListeners();
      } else {
        if(list[0].ipv4 != newdata.ipv4){
          list[0].ipv4 = newdata.ipv4;
          list[0].wifiData = newdata.wifiData;
          this.notifyListeners();
        } else if (list[0].ipv4 == newdata.ipv4
          && list[0].wifiData!=null
          && list[0].wifiData!.wifiName != newdata.wifiData!.wifiName){
          list[0].wifiData = newdata.wifiData;
          this.notifyListeners();
        }
      }
    }
    // Upnp
    else if(newdata.upnpData!=null){
      bool find = false;
      for(DeviceData d in list){
        if (d.upnpData != null && d.upnpData!.uuid == newdata.upnpData!.uuid){
          find = true;
        }
      }
      if(find==false){
        if(list.length==0)
          list.add(newdata);
        else
          list.insert(1, newdata);
        this.notifyListeners();
      }
    }
    // Scan
    else if(newdata.ipv4!=''){
      bool find = false;
      for(DeviceData d in list){
        if(d.ipv4 == newdata.ipv4){
          find = true;
        }
      }
      if(find==false){
        list.add(newdata);
        this.notifyListeners();
      }
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

