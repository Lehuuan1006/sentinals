import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

class DeviceManager extends StatefulWidget {
  @override
  _DeviceManagerState createState() => _DeviceManagerState();
}

class _DeviceManagerState extends State<DeviceManager> {
  bool fanState = false;
  bool lightState = false;
  String recordedText = "Result";
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Map<String, String> keywords = {
    "fan_on": "fan on",
    "fan_off": "fan off",
    "light_on": "light on",
    "light_off": "light off"
  };

  @override
  void initState() {
    super.initState();
    _loadKeywords();
    _checkPermissions();
  }

  void _setAllDevicesState(bool state) {
    setState(() {
      fanState = state;
      lightState = state;
    });
    updateDeviceState('fan', state);
    updateDeviceState('light', state);
  }

  Future<void> _loadKeywords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      keywords["fan_on"] = prefs.getString("fan_on") ?? "fan on";
      keywords["fan_off"] = prefs.getString("fan_off") ?? "fan off";
      keywords["light_on"] = prefs.getString("light_on") ?? "light on";
      keywords["light_off"] = prefs.getString("light_off") ?? "light off";
    });
  }

  Future<void> _saveKeyword(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    _loadKeywords();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<bool> _isGoogleAppInstalled() async {
    const url = 'com.google.android.googlequicksearchbox';
    final bool isInstalled = await canLaunch(url);
    return isInstalled;
  }

  void _showGoogleAppInstallDialog() {
    showCustomDialogModal(
      context: navigatorKey.currentContext!,
      textDesc:
          "Để dùng chức năng nhận diện giọng nói, bạn cần cài đặt ứng dụng Google và bật quyền truy cập micro",
      title: "Thông báo",
      colorButtonOk: Colors.blue,
      btnOKText: "Xác nhận",
      typeDialog: "info",
      eventButtonOKPress: () {},
      isTwoButton: true,
    );
  }

  void updateDeviceState(String device, bool state) {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('devices').child(device);
    ref.set(state ? 1 : 0);
  }

  void _startListening() async {
    if (!await _isGoogleAppInstalled()) {
      _showGoogleAppInstallDialog();
    }
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            recordedText = result.recognizedWords.isNotEmpty
                ? result.recognizedWords
                : "...";
          });
          _handleVoiceCommand(recordedText);
        },
        onSoundLevelChange: (level) {
          if (level < 0.1) {
            Future.delayed(Duration(seconds: 2), () {
              if (!_speech.isListening) {
                setState(() {
                  _isListening = false;
                });
              }
            });
          }
        },
      );
    }
  }

  void _handleVoiceCommand(String command) {
    if (command.contains(keywords["fan_on"]!)) {
      setState(() {
        fanState = true;
      });
      updateDeviceState('fan', true);
    } else if (command.contains(keywords["fan_off"]!)) {
      setState(() {
        fanState = false;
      });
      updateDeviceState('fan', false);
    } else if (command.contains(keywords["light_on"]!)) {
      setState(() {
        lightState = true;
      });
      updateDeviceState('light', true);
    } else if (command.contains(keywords["light_off"]!)) {
      setState(() {
        lightState = false;
      });
      updateDeviceState('light', false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Widget buildDeviceBlock(
      String deviceName,
      bool value,
      String imageOn,
      String imageOff,
      ValueChanged<bool> onChanged,
      String keyOn,
      String keyOff) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 162, 218, 242),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(value ? imageOn : imageOff,
                      width: 80, height: 80),
                  const SizedBox(width: 20),
                  Column(
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
                        onChanged: (newValue) {
                          onChanged(newValue);
                          updateDeviceState(deviceName.toLowerCase(), newValue);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Turn on mode: ${keywords[keyOn]}"),
                  TextButton(
                    onPressed: () async {
                      String? newKeyword =
                          await _showKeywordDialog(context, keyOn);
                      if (newKeyword != null) _saveKeyword(keyOn, newKeyword);
                    },
                    child: Text("Edit"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Turn off mode: ${keywords[keyOff]}"),
                  TextButton(
                    onPressed: () async {
                      String? newKeyword =
                          await _showKeywordDialog(context, keyOff);
                      if (newKeyword != null) _saveKeyword(keyOff, newKeyword);
                    },
                    child: Text("Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showKeywordDialog(BuildContext context, String key) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Insert new key",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("Save"),
            ),
          ],
        );
      },
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
                        "Fan",
                        fanState,
                        "assets/images/fan_on.png",
                        "assets/images/fan_off.png", (newValue) {
                      setState(() {
                        fanState = newValue;
                      });
                    }, "fan_on", "fan_off"),
                    buildDeviceBlock(
                        "Light",
                        lightState,
                        "assets/images/light_on.png",
                        "assets/images/light_off.png", (newValue) {
                      setState(() {
                        lightState = newValue;
                      });
                    }, "light_on", "light_off"),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _setAllDevicesState(false),
                  child: const Text("Turn off all"),
                ),
                ElevatedButton(
                  onPressed: () => _setAllDevicesState(true),
                  child: const Text("Turn on all"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.mic : Icons.mic_off),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                recordedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
