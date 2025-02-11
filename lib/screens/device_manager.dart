import 'package:flutter/material.dart';

class DeviceManager extends StatefulWidget {
  @override
  _DeviceManagerState createState() => _DeviceManagerState();
}

class _DeviceManagerState extends State<DeviceManager> {
  bool fanState = false;
  bool lightState = false;

  void _setAllDevicesState(bool state) {
    setState(() {
      fanState = state;
      lightState = state;
    });
  }

  Widget buildDeviceBlock(String deviceName, bool value, String imageOn,
      String imageOff, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 162, 218, 242),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Image.asset(value ? imageOn : imageOff, width: 80, height: 80),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Switch(
                    value: value,
                    onChanged: onChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Manager")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildDeviceBlock(
                      "Quạt",
                      fanState,
                      "assets/images/fan_on.png",
                      "assets/images/fan_off.png",
                      (newValue) {
                        setState(() {
                          fanState = newValue;
                        });
                      },
                    ),
                    buildDeviceBlock(
                      "Đèn",
                      lightState,
                      "assets/images/light_on.png",
                      "assets/images/light_off.png",
                      (newValue) {
                        setState(() {
                          lightState = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _setAllDevicesState(false),
                    child: const Text("Tắt tất cả"),
                  ),
                  ElevatedButton(
                    onPressed: () => _setAllDevicesState(true),
                    child: const Text("Bật tất cả"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
