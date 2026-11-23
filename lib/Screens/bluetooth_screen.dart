import 'package:ble_app/Riverpod/Bluetooth_status.dart';
import 'package:ble_app/Services/Bluetooth_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class BluetoothScreen extends ConsumerStatefulWidget {
  const BluetoothScreen({super.key});

  @override
  ConsumerState<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends ConsumerState<BluetoothScreen> {
  List<BluetoothDevice> connected_device = [];
  bool scan = false;
  String deviceName = "My Phone";
  final TextEditingController name = TextEditingController();
  Timer? time;
  int count = 0;
  XFile? image;
  XFile? video;
  PlatformFile? audio;
  bool selected = false;
  bool clicked = false;

  Future checkbluetooth() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) {
      await bluetoothService.Scan();
    }
  }

  Future Image() async {
    final XFile? Selected_image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (Selected_image == null) {
      return;
    }
    setState(() {
      image = Selected_image;
      selected = true;
    });
  }

  Future Video() async {
    final XFile? VideFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (VideFile == null) {
      return;
    }
    setState(() {
      video = VideFile;
      selected = true;
    });
  }

  Future<void> Audio() async {
    var audioFile = await FilePicker.pickFile(type: FileType.audio);
    if (audioFile == null) {
      return;
    }

    setState(() {
      audio = audioFile;
      selected = true;
    });
  }

  @override
  void initState() {
    super.initState();
    checkbluetooth();

    time = Timer.periodic(const Duration(seconds: 5), (timer) {
      count++;

      if (count == 4) {
        timer.cancel();

        if (mounted) {
          setState(() {
            scan = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            scan = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    time?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = ref.watch(bluetooth_button);
    final devices = ref.watch(availabledevices);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bluetooth_Screens",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    "Bluetooth",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  trailing: Switch(
                    value: button.when(
                      data: (state) => state == BluetoothAdapterState.on,
                      loading: () => false,
                      error: (error, stack) => false,
                    ),
                    onChanged: (value) async {
                      if (value) {
                        final status = await Permission.bluetoothScan.request();
                        final connectStatus = await Permission.bluetoothConnect
                            .request();

                        if (status.isGranted && connectStatus.isGranted) {
                          await bluetoothService.turnOnBluetooth();
                          await bluetoothService.Scan();
                        } else {
                          debugPrint('Bluetooth permission denied');
                        }
                      } else {
                        print("");
                      }
                    },
                  ),
                ),
                SizedBox(height: height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Device name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(deviceName)),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Change device name",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    content: TextField(
                                      controller: name,
                                      decoration: const InputDecoration(
                                        hintText: "Enter your new device name",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            deviceName = name.text;
                                          });
                                          Navigator.pop(dialogContext);
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Divider(thickness: 2),
                SizedBox(height: height * 0.01),
                Text(
                  "Paired devices",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                SizedBox(height: height * 0.01),

                if (connected_device.isEmpty)
                  const Text("No paired device")
                else
                  Container(
                    height: height * 0.3,
                    child: ListView.builder(
                      itemCount: connected_device.length,
                      itemBuilder: (context, index) {
                        final result = connected_device[index];

                        return ListTile(
                          leading: Icon(Icons.signal_cellular_alt),
                          title: Text(
                            result.platformName.isNotEmpty
                                ? result.platformName
                                : result.remoteId.str,
                          ),
                          subtitle: Row(
                            children: [
                              const Text("Connected"),
                              const SizedBox(width: 12),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 80,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    audio?.name ??
                                        image?.name ??
                                        video?.name ??
                                        "Select a file",
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              if (selected)
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      clicked = true;
                                    });
                                    await Future.delayed(
                                      const Duration(seconds: 3),
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      clicked = false;
                                      selected = false;

                                      audio = null;
                                      image = null;
                                      video = null;
                                    });
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: clicked
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send),
                                ),
                              if (!selected)
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == "Image") {
                                      Image();
                                    } else if (value == "Audio") {
                                      Audio();
                                    } else if (value == "Video") {
                                      Video();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: "Audio",
                                      child: Row(
                                        children: [
                                          Icon(Icons.audio_file),
                                          SizedBox(width: 8),
                                          Text("Select audio file"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: "Image",
                                      child: Row(
                                        children: [
                                          Icon(Icons.image),
                                          SizedBox(width: 8),
                                          Text("Select Image file"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: "Video",
                                      child: Row(
                                        children: [
                                          Icon(Icons.video_call),
                                          SizedBox(width: 8),
                                          Text("Select Video file"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          onTap: () async {
                            if (!result.isConnected) return;

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: Text("Disconnect Device?"),
                                  content: Text(
                                    "Are you sure you want to disconnect "
                                    "${result.platformName.isNotEmpty ? result.platformName : result.remoteId.str}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, false);
                                      },
                                      child: Text("cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, true);
                                      },
                                      child: Text("Disconnect"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm != true) return;

                            try {
                              await result.disconnect();

                              if (!mounted) return;

                              setState(() {
                                connected_device.remove(result);
                              });
                            } catch (e) {
                              debugPrint("Disconnect error: $e");
                            }
                          },
                        );
                      },
                    ),
                  ),

                Divider(thickness: 2),
                SizedBox(height: height * 0.01),
                Row(
                  children: [
                    Text(
                      "Available Devices",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (scan)
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                  ],
                ),

                devices.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("No available devices found"),
                      );
                    }

                    return SizedBox(
                      height: height * 0.2,
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];

                          var name =
                              (result.advertisementData.advName.isNotEmpty
                                      ? result.advertisementData.advName
                                      : result.device.platformName)
                                  .toLowerCase();

                          var Headphone =
                              name.contains('headphone') ||
                              name.contains('headset') ||
                              name.contains('airpods') ||
                              name.contains('earbuds') ||
                              name.contains('buds') ||
                              name.contains('tws') ||
                              name.contains('audio') ||
                              name.contains('speaker');

                          var Phone =
                              name.contains('phone') ||
                              name.contains('iphone') ||
                              name.contains('galaxy') ||
                              name.contains('pixel') ||
                              name.contains('oneplus') ||
                              name.contains('redmi');

                          String device = 'Unknown Device';

                          if (Headphone) {
                            device = 'Earbud / Headset';
                          } else if (Phone) {
                            device = 'Phone / Mobile';
                          }

                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  result.rssi >= -50
                                      ? Icons.signal_cellular_alt
                                      : result.rssi >= -70
                                      ? Icons.signal_cellular_alt_2_bar
                                      : result.rssi >= -85
                                      ? Icons.signal_cellular_alt_1_bar
                                      : Icons.signal_cellular_0_bar,
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                            title: Text(
                              result.advertisementData.advName.isNotEmpty
                                  ? result.advertisementData.advName
                                  : result.device.platformName.isNotEmpty
                                  ? result.device.platformName
                                  : 'Unknown device',
                            ),
                            trailing: Icon(
                              Headphone
                                  ? Icons.headphones
                                  : Phone
                                  ? Icons.smartphone
                                  : Icons.bluetooth,
                            ),
                            onTap: () async {
                              try {
                                await result.device.connect(
                                  license: License.nonprofit,
                                );

                                if (!connected_device.contains(result.device)) {
                                  setState(() {
                                    connected_device.add(result.device);
                                  });
                                }
                                result.device.connectionState.listen((state) {
                                  if (state ==
                                      BluetoothConnectionState.disconnected) {
                                    setState(() {
                                      connected_device.remove(result.device);
                                    });
                                  }
                                });
                              } catch (e) {
                                print("Bluetooth error: $e");
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stack) {
                    return Text('Error: $error');
                  },
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },
                ),

                Divider(thickness: 2),
                SizedBox(height: height * 0.01),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Note: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "When Bluetooth is turned on, you can connect to nearby devices.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
