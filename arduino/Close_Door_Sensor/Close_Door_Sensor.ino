#include "OLED.h"
#include "DHTesp.h"
#include <Ultrasonic.h>
#include "BluetoothSerial.h"

// 溫溼度感應器
#define dhtPin 33      // 設定溫溼度感測器針腳
// 蜂鳴器 1 設定
#define buzzerPin 32   // 無緣蜂鳴器的PWM針腳
#define pwmChannel 1   // PWM 頻道為 1
#define resolution 10  // 解析度可選 1~15 位元
// 蜂鳴器 2 設定
#define alt_buzzerPin 25   // 無緣蜂鳴器的PWM針腳
#define alt_pwmChannel 2   // PWM 頻道為 2
#define alt_resolution 10  // 解析度可選 1~15 位元
// 超音波感測器
#define trigPin 15     // 超音波感應器的 Trig Pin
#define echoPin 4      // 超音波感應器的 Echo Pin
// 輸入元件
#define switchPin 13   // 開關的針腳在 13 
#define resistorPin 12 // 可變電阻在 12
#define doorPin 35     // 磁簧開關在 35
// 輸出元件
#define LED1Pin 2      // 紅色LED在 2
#define LED2Pin 0      // 黃色LED在 0
// 其他設定
#define openDelay 35   // 門開啟5秒後會當作未關閉
#define bluetooth_name "ESP32Server" //藍芽名稱

DHTesp dht;
SSD1306 OLED;
BluetoothSerial SerialBT;
TempAndHumidity lastTempValue;
Ultrasonic ultrasonic(trigPin, echoPin);

int timeCountdown;
void update_OLED();
unsigned long lastUpdate;
bool btStats = true, doorStats, isDoorTimeout = false; 
int distanceList[] = {25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400};

void setup() {
  Serial.begin(115200);
  OLED.begin();
  dht.setup(dhtPin, DHTesp::DHT11);
  SerialBT.begin(bluetooth_name);
  // 蜂鳴器接到輸出
  pinMode(buzzerPin, OUTPUT); 
  pinMode(alt_buzzerPin, OUTPUT);
  ledcAttachPin(buzzerPin, pwmChannel); // 開啟 PWM 通道
  ledcSetup(pwmChannel, 1000, resolution); // 開啟聲音
  
  ledcAttachPin(alt_buzzerPin, alt_pwmChannel); // 開啟 PWM 通道
  ledcSetup(alt_pwmChannel, 1000, alt_resolution); // 開啟聲音
  pinMode(switchPin, INPUT);
  pinMode(resistorPin, INPUT);
  pinMode(LED1Pin, OUTPUT);
  pinMode(LED2Pin, OUTPUT);
  Serial.println("[Info] Initialization Completed !");
}

void loop() {
  if (analogRead(35) < 2048){ // 開門
    doorStats = true;
    isDoorTimeout = false;
    digitalWrite(LED2Pin, doorStats);
    SerialBT.printf("cmd:start_record:%lf\n", lastTempValue.temperature);
    Serial.printf("[BT] cmd:start_record:%lf\n", lastTempValue.temperature);
    timeCountdown = openDelay; // 一次100ms, 等200次, 共20秒 
    while (true) {
      Serial.printf("[Info] Door open count down: %d \n", timeCountdown);
      update_OLED();
      if (ultrasonic.read() < distanceList[map(analogRead(resistorPin), 0, 4096, 0, 15)]) timeCountdown = openDelay; // 有人經過，重置倒數
      if (analogRead(35) > 2048) break; // 關門時結束計時
      if (timeCountdown <= 0 && analogRead(switchPin) > 4000) {
        ledcWrite(pwmChannel, 512); //開啟蜂鳴器聲音
        ledcWrite(alt_pwmChannel, 512); 
      } else { //關閉蜂鳴器聲音
        ledcWrite(pwmChannel, 0);
        ledcWrite(alt_pwmChannel, 0);
      }
      if (timeCountdown < 0 && !isDoorTimeout) {
        digitalWrite(LED1Pin, HIGH);
        isDoorTimeout = true;
      }
      timeCountdown -= 1;
      delay(100);
    }
    ledcWrite(pwmChannel, 0); // 關閉蜂鳴器聲音
    ledcWrite(alt_pwmChannel, 0);
    SerialBT.printf("cmd:stop_record:%lf:%d\n", lastTempValue.temperature, isDoorTimeout);
    Serial.printf("[BT] cmd:stop_record:%lf:%d\n", lastTempValue.temperature, isDoorTimeout);
  }else{ //關門
    doorStats = false;
    digitalWrite(LED1Pin, LOW);
    digitalWrite(LED2Pin, doorStats);
  }
  
  update_OLED();
  delay(20);
}

// 傳送脈波讓超音波感應器開始測距 (cm)
int get_distance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPin, HIGH); // 給 Trig 高電位，持續 10微秒
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  pinMode(echoPin, INPUT);     // 讀取 echo 的電位
  return (pulseIn(echoPin, HIGH) / 2) / 29.1; // 將收到高電位時的時間回傳並換算 cm
  // Inches: (pulseIn(echoPin, HIGH) / 2) / 74;
}

void update_OLED(){
  if (SerialBT.connected() ^ btStats) {
    btStats = !btStats;
    if (btStats) Serial.println("[Info] Bluetooth connected!");
    else Serial.println("[Info] Bluetooth not connected!");
  }
  lastTempValue = dht.getTempAndHumidity();
  OLED.clearBuffer();
  if (btStats) OLED.println("藍芽: 已連線");
  else OLED.println("藍芽: 未連線");
  if(doorStats) OLED.println("磁簧: " + String(timeCountdown));
  else OLED.println("磁簧: 閉合中");
  OLED.println("距離: " + String(distanceList[map(analogRead(resistorPin), 0, 4096, 0, 15)]) + "cm");
  OLED.println(String(lastTempValue.temperature) + "°C / " + String(lastTempValue.humidity) + "%");
  OLED.sendBuffer();
}
