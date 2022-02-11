import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skein_upnp/skein_upnp.dart' as upnplib;
import 'package:url_launcher/url_launcher.dart';

import 'device_model.dart';
import 'device_provider.dart';
import 'responsive.dart';

class DeviceCard extends ConsumerWidget {
  double FSIZE_SIMPLE = 14;
  double FSIZE_DETAIL = 14;

  DeviceCard({DeviceData? data, bool? isDetail}) {
    if(data!=null) this.data = data;
    if(isDetail!=null) this.isDetail = isDetail;
  }

  DeviceData data = DeviceData();
  bool isDetail = false;
  Color panelFgColor = Color(0xFF888888);
  Color detailKeyColor = Color(0xFF888888);
  BuildContext? context;

  double cardWidth = 400.0;
  double cardHeight = 40.0;
  double detailKeyWidth = 100.0;
  double detailValWidth = 200.0;

  calcSize(BuildContext context){
    cardHeight = this.isDetail ? Responsive.getSize(context).height-50 : 48;
    if (Responsive.isMobile(context)){
      detailValWidth = Responsive.getSize(context).width - detailKeyWidth - 50;
    }else {
      detailValWidth = Responsive.getSize(context).width/2 - detailKeyWidth - 50;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.context = context;
    ref.watch(deviceListProvider);
    final col = ref.watch(colorProvider);
    this.panelFgColor = col.panelFgColor;
    this.detailKeyColor = col.detailKeyColor;
    calcSize(context);

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: col.panelBgColor,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [BoxShadow(
          color:col.shadowColor,
          spreadRadius:1.0,
          blurRadius:5.0,
          offset: Offset(2,2),
        )]
      ),
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isDetail == false) {
            if (Responsive.isMobile(context)) {
              if (data.networkData != null || data.upnpData != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => DeviceDetailScreen(data))
                );
              }
            } else {
              if (data.networkData != null || data.upnpData != null) {
                ref.read(deviceListProvider).select(data.deviceid);
              } else {
                ref.read(deviceListProvider).select('');
              }
            }
          }
        },
        child: getWidget(context),
      ),
    );
  }

  Widget getWidget(BuildContext context) {
    if(data.networkData!=null) {
      return getWifiWidget();
    } else if(data.upnpData!=null) {
      return getUpnpWidget();
    } else {
      return getScanWidget();
    }
  }

  Widget getWifiWidget() {
    if(isDetail) {
      return Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
          textDetail('WifiName', data.networkData!.wifiName),
          textDetail('BSSID', data.networkData!.wifiBSSID),
          textDetail('IPv4', data.networkData!.wifiIPv4),
          textDetail('IPv6', data.networkData!.wifiIPv6),
          textDetail('GatewayIP',data.networkData!.wifiGatewayIP),
          textDetail('Broadcast',data.networkData!.wifiBroadcast),
          textDetail('Submask',data.networkData!.wifiSubmask),
        ]);
    } else {
      return textSimple(Icon(ICON_WIFI, color:Colors.blue), data.networkData!.wifiIPv4, data.networkData!.wifiName, true);
    }
  }

  Widget getUpnpWidget() {
    UpnpData? d = data.upnpData;
    if(d==null)
      return textSimple(Icon(ICON_UPNP), 'Nodate', '', false);

    if(isDetail) {
      List<Widget> list = [];
      list.add(textDetail('Name', d.friendlyName));
      list.add(textDetail('Desc', d.modelDescription));
      list.add(textDetail('DeviceType', d.deviceType));
      list.add(textDetail('Mfr', d.manufacturer));
      list.add(textDetail('Model', d.modelName));
      list.add(textDetail('Udn', d.udn));
      list.add(textDetail('Uuid', d.uuid));
      list.add(textDetail('ModelType', d.modelType));

      list.add(textDetail('',''));

      list.add(textDetail('Url', d.url));
      list.add(textDetail('Base', d.urlBase));
      list.add(textDetail('Manufacturer', d.manufacturerUrl));
      list.add(textDetail('Presentation', d.presentationUrl));

      list.add(launchButton(d.presentationUrl));

      for (upnplib.ServiceDescription svc in d.services) {
        list.add(textDetail('service id', svc.id));
        list.add(textDetail('type', svc.type));
        list.add(textDetail('event', svc.eventSubUrl));
        list.add(textDetail('scpd', svc.scpdUrl!));
        list.add(textDetail('control', svc.controlUrl));
      }
      return Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: list);
    } else {
      return textSimple(Icon(ICON_UPNP), d.friendlyName, d.manufacturer, true);
    }
  }

  Widget getScanWidget() {
    if(isDetail) {
      return textSimple(null, data.name, '', false);
    } else {
      return textSimple(Icon(ICON_SCAN, color:Colors.orange), data.name, '', false);
    }
  }

  Widget textSimple(Icon? icon, String s1, String s2, bool detail) {
    return Row(children: [
      if(icon!=null) icon,
      if(icon!=null) SizedBox(width: 8),
      Text(s1,style:TextStyle(fontSize: FSIZE_SIMPLE, color:panelFgColor)),
      Expanded(child: SizedBox(width: 1)),
      Text(s2,style:TextStyle(fontSize: FSIZE_SIMPLE, color:panelFgColor)),
      if(detail) SizedBox(width: 8),
      if(detail) Icon(Icons.arrow_forward_ios, size:14, color:Colors.grey),
    ]);
  }

  Widget textDetail(String s1, String s2) {
    return Container(
      padding: EdgeInsets.only(bottom:4),
      child: Row(children: [
      Container(
        width: detailKeyWidth,
        child: Text(s1,
          style:TextStyle(fontSize: FSIZE_DETAIL, color:detailKeyColor),
          textAlign: TextAlign.right,
        )
      ),
      SizedBox(width: 12),
      Container(
        width: detailValWidth,
        child: Text(s2,
        style:TextStyle(fontSize: FSIZE_DETAIL, color:panelFgColor),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      )),
    ]));
  }

  Widget launchButton(String url) {
    if(url.contains('http')==false)
      return Container();
    else
      return IconButton(
        icon: Icon(Icons.arrow_forward),
        iconSize: 14.0,
        onPressed: (){ _launchURL(url); }
      );
  }

  _launchURL(String url) async {
    if (await launch(url)==false) {
      showSnackBar('ERROR $url');
    }
  }

  showSnackBar(String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context!).showSnackBar(snackBar);
  }  
}

class DeviceDetailScreen extends ConsumerWidget {
  String title='Detail';
  DeviceData data = DeviceData();

  DeviceDetailScreen(DeviceData data) {
    this.data = data;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = ref.watch(colorProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: col.menuBgColor,
          foregroundColor: col.menuFgColor,
        ),
        body: Container(
          margin: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
            return DeviceCard(data: data, isDetail: true);
          })
        )
    );
  }
}
