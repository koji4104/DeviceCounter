import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skein_upnp/skein_upnp.dart' as upnplib;
import 'package:url_launcher/url_launcher.dart';

import 'device_model.dart';
import 'device_provider.dart';
import 'responsive.dart';

class DeviceCard extends ConsumerWidget {
  DeviceCard({DeviceData? data, bool? isDetail}) {
    if(data!=null) this.data = data;
    if(isDetail!=null) this.isDetail = isDetail;
  }

  DeviceData data = DeviceData();
  bool isDetail = false;
  Color panelFgColor = Color(0xFF888888);
  BuildContext? context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.context = context;
    ref.watch(deviceListProvider);
    final col = ref.watch(colorProvider);
    this.panelFgColor = col.panelFgColor;

    return Container(
      width: 400, height: this.isDetail ? Responsive.getSize(context).height-50 : 70,
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: col.panelBgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(4),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if(Responsive.isMobile(context)) {
            if (isDetail == false) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DeviceDetailScreen(data))
              );
            }
          } else {
            ref.read(deviceListProvider).select(data.deviceid);
          }
        },
        child: getWidget(context),
      ),
    );
  }

  Widget getWidget(BuildContext context) {
    return getWidget1();
  }

  Widget getWidget1() {
    if (isDetail == false) {
      return Stack(children: [
        Container(
          padding: EdgeInsets.only(top: 4, left: 2),
          child: getIcon(),
        ),
        Container(
          padding: EdgeInsets.only(top: 4, left: 36),
          child: getText()
        ),
      ]);
    } else {
      return 
        Container(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: getText()
        );
    }
  }

  Widget getIcon() {
    if(data.networkData!=null) {
      return Icon(Icons.info_outline, color: Colors.green);
    } else if(data.upnpData!=null) {
      return Icon(Icons.phone_android, color:Colors.blue);
    } else {
      return Icon(Icons.wifi, color:Colors.orange);
    }
  }

  Widget getText() {
    if(data.networkData!=null) {
      return getNetworkText();
    } else if(data.upnpData!=null) {
      return getUpnpDeviceText();
    } else {
      return getText1(data.name, 16);
    }
  }

  Widget getUpnpDeviceText() {
    UpnpData? d = data.upnpData;
    if(d==null)
      return getText1('Nodate',16);

    if(isDetail) {
      List<Widget> list = [];
      list.add(getText2('Name', d.friendlyName));
      list.add(getText2('Desc', d.modelDescription));
      list.add(getText2('deviceType', d.deviceType));
      list.add(getText2('urlBase', d.urlBase));
      list.add(getText2('Mfr', d.manufacturer));
      list.add(getText2('Model', d.modelName));
      list.add(getText2('udn', d.udn));
      list.add(getText2('uuid', d.uuid));
      list.add(getText2('url', d.url));
      list.add(getText2('modelType', d.modelType));
      list.add(getText2('manufacturerUrl', d.manufacturerUrl));
      list.add(getTextUrl(d.presentationUrl));

      for (upnplib.ServiceDescription svc in d.services) {
        list.add(getText2('service id', svc.id));
        list.add(getText2('type', svc.type));
        list.add(getText2('eventSubUrl', svc.eventSubUrl));
        list.add(getText2('scpdUrl', svc.scpdUrl!));
        list.add(getText2('controlUrl', svc.controlUrl));      
      }      
      return Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: list);
    } else {
      return Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
          getText1(d.friendlyName, 16),
          getText1(d.modelName, 14),
          getText1(d.manufacturer, 14),
      ]);
    }
  }

  Widget getNetworkText() {
    if(isDetail) {
      return Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
        getText2('wifiName', data.networkData!.wifiName),
        getText2('wifiBSSID', data.networkData!.wifiBSSID),
        getText2('wifiIPv4', data.networkData!.wifiIPv4),
        getText2('wifiIPv6', data.networkData!.wifiIPv6),
        getText2('wifiGatewayIP',data.networkData!.wifiGatewayIP),
        getText2('wifiBroadcast',data.networkData!.wifiBroadcast),
        getText2('wifiSubmask',data.networkData!.wifiSubmask),
      ]);
    } else {
      return Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
        getText1(data.networkData!.wifiIPv4, 14),
        getText1(data.networkData!.wifiName, 16),
      ]);
    }
  }

  Widget getText1(String t1, double size) {
    return Text(t1,style:TextStyle(fontSize: size, color: panelFgColor));
  }

  Widget getText2(String t1, String t2) {
    double size = 13;
    if(t2.length>30) 
      size=11;
    return Row(children: [
      Text(t1,style:TextStyle(fontSize: 11, color: panelFgColor)),
      Expanded(child: SizedBox(width: 1)),
      Text(t2,style:TextStyle(fontSize: size, color: panelFgColor)),
    ]);

  }
  Widget getTextUrl(String url) {
    return Row(children: [
      Expanded(child:Text(url,style:TextStyle(fontSize: 11, color: panelFgColor))),
      url.contains('http')==false ? Container() :
        IconButton(
          icon: Icon(Icons.arrow_forward_outlined),
          iconSize: 18.0,
          onPressed: (){
            _launchURL(url);
          }
        ),
    ]);
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
          margin: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
          child:DeviceCard(data: data, isDetail: true)
        )
    );
  }
}
