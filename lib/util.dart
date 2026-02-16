import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

abstract class Configurations {
  /// TODO : Get the port from localstorage
  static int get port => 4200;
  static double spacing = 10;

  /// get the ip of the device
  ///
  /// set the ipName with the ipv6 or ipv4 address
  /// if not, set the ipName to "unknown"
  ///
  ///
  static InternetAddress? _ipAddress;
  static Future<InternetAddress> get address async {
    if (_ipAddress == null) {
      final info = NetworkInfo();

      final ipv6 = await info.getWifiIPv6();

      if (ipv6 == null) {
        final ipv4 = await info.getWifiIP();

        if (ipv4 == null) {
          throw Exception("Failed to get the ip address");
        }

        return _ipAddress = InternetAddress(ipv4);
      }

      return _ipAddress = InternetAddress(ipv6);
    }

    return _ipAddress!;
  }
}


