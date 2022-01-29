import 'package:skein_upnp/skein_upnp.dart' as upnp;
import 'package:uuid/uuid.dart';

/// used in device_screen
class DeviceData{
  String deviceid = '';
  String name = "";
  String ipv4 = "";
  String ipv6 = "";
  
  UpnpData? upnpData;
  NetworkData? networkData;

  DeviceData({String? name}) {
    if(name!=null) this.name = name;
    this.deviceid = Uuid().v1();
  }
}

/// for skein_upnp.dart
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

/// for network_info_plus.dart
class NetworkData{
  String wifiName = "";
  String wifiBSSID = "";
  String wifiIPv4 = "";
  String wifiIPv6 = "";
  String wifiGatewayIP = "";
  String wifiBroadcast = "";
  String wifiSubmask = "";
  NetworkData({String? wifiName, String? wifiBSSID, String? wifiIPv4, String? wifiIPv6,
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
