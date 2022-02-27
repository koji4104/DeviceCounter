import 'package:skein_upnp/skein_upnp.dart' as upnp;
import 'package:uuid/uuid.dart';

/// used in device_screen
class DeviceData{
  String deviceid = '';
  String name = "";
  String ipv4 = "";
  String ipv6 = "";
  
  UpnpData? upnpData;
  WifiData? wifiData;

  DeviceData({String? ipv4}) {
    if(ipv4!=null) this.ipv4 = ipv4;
    this.deviceid = Uuid().v1();
  }
}

/// Used on DeviceData.upnpData
/// skein_upnp.dart
class UpnpData {
  String deviceType='';
  String urlBase='';
  String friendlyName='';
  String manufacturer='';

  String modelName='';
  String udn='';
  String uuid='';
  String url='';

  String presentationUrl='';
  String modelType='';
  String modelDescription='';
  String manufacturerUrl='';

  List<upnp.UpnpIcon> icons = [];
  List<upnp.ServiceDescription> services = [];
  List<String?> get serviceNames => services.map((x) => x.id).toList();

  UpnpData(){}
  UpnpData.fromDevice(upnp.Device? d) {
    if(d==null) 
      return;
    this.deviceType = d.deviceType;
    this.urlBase = d.urlBase;
    this.friendlyName = d.friendlyName;
    this.manufacturer = d.manufacturer;

    this.modelName = d.modelName;
    this.udn = d.udn;
    this.uuid = d.uuid;
    this.url = d.url;

    this.presentationUrl = d.presentationUrl;
    this.modelType = d.modelType;
    this.modelDescription = d.modelDescription;
    this.manufacturerUrl = d.manufacturerUrl;

    this.icons = d.icons;
    this.services = d.services;
  }
}

/// Used on DeviceData.wifiData
/// for network_info_plus.dart
class WifiData{
  String wifiName = "";
  String wifiBSSID = "";
  String wifiIPv4 = "";
  String wifiIPv6 = "";
  String wifiGatewayIP = "";
  String wifiBroadcast = "";
  String wifiSubmask = "";
  WifiData({String? wifiName, String? wifiBSSID, String? wifiIPv4, String? wifiIPv6,
    String? wifiGatewayIP, String? wifiBroadcast, String? wifiSubmask}) {
    if (wifiName != null) this.wifiName = wifiName;
    if (wifiBSSID != null) this.wifiBSSID = wifiBSSID;
    if (wifiIPv4 != null) this.wifiIPv4 = wifiIPv4;
    if (wifiIPv6 != null) this.wifiIPv6 = wifiIPv6;
    if (wifiGatewayIP != null) this.wifiGatewayIP = wifiGatewayIP;
    if (wifiBroadcast != null) this.wifiBroadcast = wifiBroadcast;
    if (wifiSubmask != null) this.wifiSubmask = wifiSubmask;
  }
}

/// sample data for test
class SampleUpnpData extends UpnpData {
  String deviceType='urn:schemas-upnp-org:device:MediaServer:1';
  String urlBase='http://10.0.2.17:49152/devinfo.xml';
  String friendlyName='ABCD-0001';
  String manufacturer='Example Corporation';
  String modelName='ABCD-A';
  String udn='uuid:12345678-1111-2222-3333-1234567890ab';
  String uuid='12345678-1111-2222-3333-1234567890ab';
  String url='http://10.0.2.17:2800/upnphost/udhisapi.dll?content=uuid:12345678-1111-2222-3333-1234567890ab';
  String presentationUrl='http://10.0.2.17';
  String modelType='';
  String modelDescription='Wireless Network Camera';
  String modelNumber='';
  String manufacturerUrl='http://www.example.com';
  SampleDevice(){}
}

/// sample data for test
class SampleWifiData extends WifiData {
  String wifiName = "WiFi Spot";
  String wifiBSSID = "02:00:00:00:00:00";
  String wifiIPv4 = "10.0.2.16";
  String wifiIPv6 = "fe80::1111:2222:3333:4444";
  String wifiGatewayIP = "10.0.2.2";
  String wifiBroadcast = "/10.0.2.255";
  String wifiSubmask = "255.255.255.0";
  SampleWifiData();
}