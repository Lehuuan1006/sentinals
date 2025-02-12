import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  }
  void _setAllDevicesState(bool state) {
    setState(() {
      fanState = state;
      lightState = state;
    });
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

  void _startListening() async {
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

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _handleVoiceCommand(String command) {
    setState(() {
      if (command == keywords["fan_on"]) {
        fanState = true;
      } else if (command == keywords["fan_off"]) {
        fanState = false;
      } else if (command == keywords["light_on"]) {
        lightState = true;
      } else if (command == keywords["light_off"]) {
        lightState = false;
      }
    });
  }

  Widget buildDeviceBlock(String deviceName, bool value, String imageOn,
      String imageOff, ValueChanged<bool> onChanged, String keyOn, String keyOff) {
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
                  Image.asset(value ? imageOn : imageOff, width: 80, height: 80),
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
                        onChanged: onChanged,
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
                      String? newKeyword = await _showKeywordDialog(context, keyOn);
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
                      String? newKeyword = await _showKeywordDialog(context, keyOff);
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
          title: Text("Insert new key", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          content: TextField(controller: controller),
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
                      "Fan", fanState, "assets/images/fan_on.png",
                      "assets/images/fan_off.png", (newValue) {
                        setState(() {
                          fanState = newValue;
                        });
                      }, "fan_on", "fan_off"
                    ),
                    buildDeviceBlock(
                      "Light", lightState, "assets/images/light_on.png",
                      "assets/images/light_off.png", (newValue) {
                        setState(() {
                          lightState = newValue;
                        });
                      }, "light_on", "light_off"
                    ),
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
              child: Text(_isListening ? "Stop recored" : "Record"),  
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
