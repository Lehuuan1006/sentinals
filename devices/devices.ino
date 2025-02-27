#include <WiFi.h>
#include <ESP32Firebase.h>
#include <ESP32Servo.h>  // Thư viện Servo cho ESP32

// Thông tin WiFi
#define WIFI_SSID "None"      
#define WIFI_PASSWORD "boohofwooer"

// Địa chỉ Firebase
#define FIREBASE_URL "https://sentinal-ce1bd-default-rtdb.asia-southeast1.firebasedatabase.app/"
Firebase firebase(FIREBASE_URL);

// Chân GPIO của thiết bị
#define LED1_PIN 19
#define LED2_PIN 4
#define SERVO1_PIN 23
#define SERVO2_PIN 22

Servo servo1;
Servo servo2;

int prevLed1State = -1;
int prevLed2State = -1;
int prevServo1Angle = -1;
int prevServo2Angle = -1;

void setup() {
  Serial.begin(115200);

  // Kết nối WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Đang kết nối WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi đã kết nối!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Cấu hình GPIO
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  digitalWrite(LED1_PIN, LOW);
  digitalWrite(LED2_PIN, LOW);

  // Gắn servo vào chân điều khiển
  servo1.attach(SERVO1_PIN, 500, 2500);  // Giới hạn PWM cho servo
  servo2.attach(SERVO2_PIN, 500, 2500);
  servo1.write(90);  // Khởi tạo góc ban đầu
  servo2.write(90);
}

void loop() {
  // Đọc giá trị từ Firebase
  int led1State = firebase.getInt("devices/light");
  int led2State = firebase.getInt("devices/fan");
  int servo1Angle = firebase.getInt("devices/servo1");
  int servo2Angle = firebase.getInt("devices/servo2");

  // Cập nhật LED nếu có thay đổi
  if (led1State != prevLed1State) {
    digitalWrite(LED1_PIN, led1State);
    Serial.print("light: ");
    Serial.println(led1State);
    prevLed1State = led1State;
  }
  if (led2State != prevLed2State) {
    digitalWrite(LED2_PIN, led2State);
    Serial.print("fan: ");
    Serial.println(led2State);
    prevLed2State = led2State;
  }

  // Cập nhật Servo nếu có thay đổi
  if (servo1Angle != prevServo1Angle && servo1Angle >= 0 && servo1Angle <= 180) {
    servo1.write(servo1Angle);
    Serial.print("Servo1: ");
    Serial.println(servo1Angle);
    prevServo1Angle = servo1Angle;
  }
  if (servo2Angle != prevServo2Angle && servo2Angle >= 0 && servo2Angle <= 180) {
    servo2.write(servo2Angle);
    Serial.print("Servo2: ");
    Serial.println(servo2Angle);
    prevServo2Angle = servo2Angle;
  }

  delay(100);  // Tránh Firebase bị gọi liên tục
}
