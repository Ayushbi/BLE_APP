import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class bluetoothService {
  static Future<void> turnOnBluetooth() async {
    await FlutterBluePlus.turnOn();
  }

  Stream<BluetoothAdapterState>Checkbluetooth() {
    return FlutterBluePlus.adapterState;
  }

  static Future<void> Scan() async {
    try {

      await FlutterBluePlus.startScan(
        removeIfGone: const Duration(seconds: 2),
        continuousUpdates: true,
      );

    } catch (e) {
      print('Scan failed: $e');
    }
  }

  static Stream<List<ScanResult>> Devices() {
    return FlutterBluePlus.onScanResults;
  }

  static Future<void> closebluetooth() async {
    try {
      await FlutterBluePlus.turnOff();
      debugPrint('Bluetooth turned off successfully');
    } catch (e) {
      debugPrint('Failed to turn off Bluetooth: $e');
    }
  }
}
