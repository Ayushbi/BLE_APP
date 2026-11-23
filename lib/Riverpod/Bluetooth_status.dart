import 'package:ble_app/Services/Bluetooth_services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetooth_button = StreamProvider<BluetoothAdapterState>(
  (ref) => bluetoothService().Checkbluetooth(),
);

final availabledevices = StreamProvider<List<ScanResult>>((ref) {
  final state = ref.watch(bluetooth_button);
  if (state.value == BluetoothAdapterState.on) {
    return bluetoothService.Devices();
  }
  return Stream.value(<ScanResult>[]);
});
