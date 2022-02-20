import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skein_upnp/skein_upnp.dart' as upnplib;
import 'package:flutter/services.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'device_model.dart';
import 'device_provider.dart';
import 'device_card.dart';
import 'responsive.dart';
import 'localizations.dart';

const double ICON_SIZE = 32;
const double POPUP_ICON_SIZE = 24;
const double POPUP_FONT_SIZE = 14;

class DeviceScreen extends ConsumerWidget {
  DeviceScreen() {}

  final NetworkInfo _networkInfo = NetworkInfo();
  final LanScanner scanner = LanScanner(debugLogging: false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isInitWifi = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DeviceData> deviceList = ref.watch(deviceListProvider).list;
    final col = ref.watch(colorProvider);
    final progress = ref.watch(scanProgressProvider);
    ref.watch(deviceListProvider).selectid;
    Future.delayed(Duration.zero, () => wifiInfo(context,ref));

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: col.menuBgColor,
        foregroundColor: col.menuFgColor,
        title: Text('Device Counter'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(ICON_UPNP),
            iconSize: ICON_SIZE,
            onPressed: () => discoverUpnp(context,ref),
          ),
          if(progress==0.0)
            IconButton(
              icon: Icon(ICON_SCAN),
              iconSize: ICON_SIZE,
              onPressed: () => icmpScan(context,ref),
            ),
          if(progress!=0.0)
            Center(child: Container(
              margin: EdgeInsets.only(left:4, top:4, right:4, bottom:4),
              width:ICON_SIZE-6, height:ICON_SIZE-6,
              child: CircularProgressIndicator(value:progress, color:Colors.orange, strokeWidth:2.0)
            )),
          PopupMenuButton (
            enableFeedback: ref.watch(isDarkProvider),
            offset: Offset(0,50),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(ICON_UPNP),
                  title: Text(Localized.of(context).text("guide_upnp"), style:TextStyle(fontSize:POPUP_FONT_SIZE)),
                  onTap:(){ discoverUpnp(context,ref); }
                )
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(ICON_SCAN, size:POPUP_ICON_SIZE),
                  title: Text(Localized.of(context).text("guide_scan"), style:TextStyle(fontSize:POPUP_FONT_SIZE)),
                  onTap:(){ icmpScan(context,ref); }
                )
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(ICON_WIFI, size:POPUP_ICON_SIZE),
                  title: Text(Localized.of(context).text("guide_wifi"), style:TextStyle(fontSize:POPUP_FONT_SIZE)),
                  onTap:(){ isInitWifi = false; wifiInfo(context,ref); }
                )
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.dark_mode_outlined, size:POPUP_ICON_SIZE),
                  title: Text(Localized.of(context).text("guide_dark"), style:TextStyle(fontSize:POPUP_FONT_SIZE)),
                  onTap:(){
                    bool isDark = ref.read(isDarkProvider);
                    ref.read(isDarkProvider.state).state = !isDark;
                  },
                )
              ),
            ],
          )
        ]
      ),
      body: getListView(context,ref,deviceList),
    );
  }

  /// List
  /// 1 row for mobile, 2 rows for others
  Widget getListView(
      BuildContext context,
      WidgetRef ref,
      List<DeviceData> deviceList) {
    if(Responsive.isMobile(context)) {
      return
        Container(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: deviceList.length,
            itemBuilder: (BuildContext context, int index) {
              return DeviceCard(data: deviceList[index]);
            })
        );
    } else {
      DeviceData? select = ref.read(deviceListProvider).getSelected();
      return
        Container(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            Expanded(flex: 1,
              child:ListView.builder(
                itemCount: deviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  return DeviceCard(data: deviceList[index]);
                })),
            SizedBox(width: 8),
            Expanded(flex: 1,
              child: select==null ? Container() : ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return DeviceCard(data: select, isDetail: true);
                })
            )
      ]));
    }
  }

  /// Wifi information
  /// use network_info_plus.dart
  wifiInfo(BuildContext context, WidgetRef ref) async {
    if (kIsWeb){
      print('-- kIsWeb');
      return;
    }
    if(isInitWifi){
      return;
    }

    print('-- network_info_plus');
    String? wifiName,
        wifiBSSID,
        wifiIPv4,
        wifiIPv6,
        wifiGatewayIP,
        wifiBroadcast,
        wifiSubmask;
    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      wifiIPv6 = await _networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      wifiBroadcast = await _networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      wifiSubmask = 'Failed to get Wifi submask';
    }

    WifiData wd = WifiData(
        wifiName:wifiName,
        wifiBSSID:wifiBSSID,
        wifiIPv4:wifiIPv4,
        wifiIPv6:wifiIPv6,
        wifiGatewayIP:wifiGatewayIP,
        wifiBroadcast:wifiBroadcast,
        wifiSubmask:wifiSubmask);

    DeviceData data = DeviceData(ipv4:wifiIPv4);
    data.wifiData = wd;
    ref.read(deviceListProvider).add(data);

    isInitWifi = true;
  }

  /// Scan
  /// IP address list in the same network
  /// use lan_scanner.dart
  icmpScan(BuildContext context, WidgetRef ref) async {
    if (kIsWeb){
      print('-- kIsWeb');
      return;
    }
    var wifiIP = await (NetworkInfo().getWifiIP());
    if (wifiIP == null){
      print('wifiIP != null');
      return;
    }
    String subnet = ipToSubnet(wifiIP);

    try {
      var stream = scanner.icmpScan(
        subnet,
        scanSpeeed: 20,
        timeout: const Duration(milliseconds: 100),
        firstIP: 1,
        lastIP: 255,
        progressCallback: (String prog) {
          print('Progress: $prog %');
          double dprog = double.parse(prog);
          if(dprog > 0.95) {
            ref.read(scanProgressProvider.state).state = 0.0;
          } else {
            if(ref.read(scanProgressProvider)-dprog < -0.1)
              ref.read(scanProgressProvider.state).state = dprog;
          }
        },
      );
      ref.read(scanProgressProvider.state).state = 0.1;

      stream.listen((HostModel device) async {
        print("-- scan found ${device.ip}");
        //String name = await ip2host(device.ip);
        DeviceData data = DeviceData(ipv4:device.ip);
        ref.read(deviceListProvider).add(data);
      });

    } catch (e, stack) {
      showSnackBar(context, "ERROR ${e}");
    }
  }

  /// ipaddress to hostname
  Future<String> ip2host(String ip) async {
    String host = ip;
    try {
      await InternetAddress(ip)
          .reverse()
          .then((value) {
        if(value.host!=null && value.host.length>0) {
          print('ip2host ${value.host}');
          host = value.host;
        }
      });
    } catch (e, stack) {
      //print("-- ip2host ERROR ${e}");
    }
    return host;
  }

  /// Upnp
  /// use skein_upnp.dart
  discoverUpnp(BuildContext context, WidgetRef ref) async {
    if (kIsWeb){
      print('-- kIsWeb');
      return;
    }

    print('-- UPnP');
    try {
      var discoverer = new upnplib.DeviceDiscoverer();
      await discoverer.start(ipv6: false);
      discoverer.quickDiscoverClients().listen((client) async {
        try {
          var d = await (client.getDevice() as Future<upnplib.Device?>);
          UpnpData ud = UpnpData.fromDevice(d);

          String ipv4='';
          if(ud.url.contains('://')){
            ipv4 = ud.url.substring(ud.url.indexOf('://')+3, ud.url.indexOf(':',10));
          }

          DeviceData data = DeviceData(ipv4:ipv4);
          data.upnpData = ud;
          ref.read(deviceListProvider).add(data);
          print('-- UPnP found ${ud.friendlyName}');
        } catch (e, stack) {
          print("-- UPnP ERROR ${e} - ${client.location}");
        }
      });
    } catch (e, stack) {
      showSnackBar(context, "ERROR ${e}");
      print("-- UPnP ERROR ${e}");
    }
  }

  showSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
