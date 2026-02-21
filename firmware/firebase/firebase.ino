#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#define WIFI_SSID "Arshia"
#define WIFI_PASSWORD "srmrobocon"

#define API_KEY "AIzaSyBrpuch3sxF_GqEzfQ4X-f1kVCj5yc0nKg"
#define DATABASE_URL "https://smart-water-monitor-b06bf-default-rtdb.asia-southeast1.firebasedatabase.app/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

volatile int pulseCount = 0;
float flowRate = 0.0;
float totalLiters = 0.0;

const int flowPin = 27;  // change if needed
unsigned long previousMillis = 0;

void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

void setup() {
  Serial.begin(115200);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected!");

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  time_t now = time(nullptr);
  while (now < 8 * 3600 * 2) {
    delay(500);
    now = time(nullptr);
  }
  Serial.println("Time synced!");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = "test@gmail.com";
  auth.user.password = "123456";

  config.timeout.serverResponse = 10000;

  Firebase.begin(&config, &auth);   
  Firebase.reconnectWiFi(true);

  pinMode(flowPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(flowPin), pulseCounter, FALLING);
}

void loop() {

  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= 1000) {

    detachInterrupt(digitalPinToInterrupt(flowPin));

    // Calculate flow rate (L/min)
    flowRate = pulseCount / 7.5;

    // Convert to liters per second
    float litersThisSecond = flowRate / 60.0;

    // Accumulate total volume
    totalLiters += litersThisSecond;

    pulseCount = 0;
    previousMillis = currentMillis;

    attachInterrupt(digitalPinToInterrupt(flowPin), pulseCounter, FALLING);

    Serial.print("Flow rate: ");
    Serial.print(flowRate);
    Serial.print(" L/min | Total: ");
    Serial.print(totalLiters);
    Serial.println(" L");

    if (Firebase.ready()) {

      FirebaseJson json;
      json.set("flow_rate", flowRate);
      json.set("total_liters", totalLiters);
      json.set("timestamp", millis());

      Firebase.RTDB.setJSON(&fbdo, "/water/current", &json);
    }
  }
}