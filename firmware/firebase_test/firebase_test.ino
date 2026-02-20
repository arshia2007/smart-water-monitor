#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#define WIFI_SSID "Arshia"
#define WIFI_PASSWORD "srmrobocon"

#define API_KEY "AIzaSyBrpuch3sxF_GqEzfQ4X-f1kVCj5yc0nKg"
#define DATABASE_URL "https://smart-water-monitor-b06bf-default-rtdb.asia-southeast1.firebasedatabase.app/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

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

  Firebase.begin(&config, &auth);   // ✅ only once
  Firebase.reconnectWiFi(true);
}

void loop() {

  Serial.println("Loop running...");

  if (Firebase.ready()) {
    Serial.println("Firebase READY");
    float value = random(1, 100);

    if (Firebase.RTDB.setFloat(&fbdo, "/test/flow_rate", value)) {
      Serial.println("Flow rate sent");
    } else {
      Serial.println(fbdo.errorReason());
    }

  } else {
    Serial.println("Firebase NOT ready");
  }

  delay(5000);
}