import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isCameraVisible = false;
  late WebViewController _controller;
  int _servo1Angle = 90;
  int _servo2Angle = 90;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://192.168.1.150:81/stream'));
  }

  void _updateServoValue(String servoPath, int angle) {
    _database.child('devices/$servoPath').set(angle);
  }
  void _adjustServo1(int change) {
    setState(() {
      _servo1Angle = (_servo1Angle + change).clamp(0, 180).toInt();
    });
    _updateServoValue("servo1", _servo1Angle);
  }
  void _adjustServo2(int change) {
    setState(() {
      _servo2Angle = (_servo2Angle + change).clamp(0, 180).toInt();
    });
    _updateServoValue("servo2", _servo2Angle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32-CAM Stream'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Container(
              width: 300.w,
              height: 260.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isCameraVisible
                  ? WebViewWidget(controller: _controller)
                  : const Center(
                      child: Text(
                        'Camera is Off',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isCameraVisible = !_isCameraVisible;
              });
            },
            child: Text(_isCameraVisible ? 'Tắt Camera' : 'Bật Camera'),
          ),
          const SizedBox(height: 20),

          // Điều khiển Servo
          Column(
            children: [
              const Text(
                "Điều khiển Servo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Điều khiển lên
              IconButton(
                icon: const Icon(Icons.arrow_drop_up, size: 40),
                onPressed: () => _adjustServo2(-10),
              ),

              // Điều khiển trái - phải
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, size: 40),
                    onPressed: () => _adjustServo1(10),
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, size: 40),
                    onPressed: () => _adjustServo1(-10),
                  ),
                ],
              ),

              // Điều khiển xuống
              IconButton(
                icon: const Icon(Icons.arrow_drop_down, size: 40),
                onPressed: () => _adjustServo2(10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
