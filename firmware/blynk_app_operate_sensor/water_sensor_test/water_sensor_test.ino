/*************************************************************

  This is a simple demo of sending and receiving some data.
  Be sure to check out other examples!
 *************************************************************/
#define BLYNK_TEMPLATE_ID "TMPL3mVf3djCY"
#define BLYNK_TEMPLATE_NAME "Esp32 control"
#define BLYNK_AUTH_TOKEN "2KTqXEEBzcGG766tNyCvqhlLdLo22v8a"
#define FLOW_PIN 27



/* Comment this out to disable prints and save space */
#define BLYNK_PRINT Serial


#include <WiFi.h>
#include <WiFiClient.h>
#include <BlynkSimpleEsp32.h>

// Your WiFi credentials.
// Set password to "" for open networks.
char ssid[] = "srmrobocon";
char pass[] = "srmrobocon";

BlynkTimer timer;

// This function is called every time the Virtual Pin 0 state changes
BLYNK_WRITE(V0)
{
  // Set incoming value from pin V0 to a variable
  int value = param.asInt();

  // Update state
  Blynk.virtualWrite(V1, value);
}

// This function is called every time the device is connected to the Blynk.Cloud
BLYNK_CONNECTED()
{
  // Change Web Link Button message to "Congratulations!"
  Blynk.setProperty(V3, "offImageUrl", "https://static-image.nyc3.cdn.digitaloceanspaces.com/general/fte/congratulations.png");
  Blynk.setProperty(V3, "onImageUrl",  "https://static-image.nyc3.cdn.digitaloceanspaces.com/general/fte/congratulations_pressed.png");
  Blynk.setProperty(V3, "url", "https://docs.blynk.io/en/getting-started/what-do-i-need-to-blynk/how-quickstart-device-was-made");
}

// This function sends Arduino's uptime every second to Virtual Pin 2.
void myTimerEvent()
{
  // You can send any value at any time.
  // Please don't send more that 10 values per second.
  Blynk.virtualWrite(V2, millis() / 1000);
}

//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
volatile unsigned long pulseCount = 0;
float flowRate = 0.0;
float totalLiters = 0.0;

unsigned long lastTime = 0;

// Interrupt function
void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

void setup()
{
  // Debug console
  Serial.begin(115200);

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);
  // You can also specify server:
  //Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass, "blynk.cloud", 80);
  //Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass, IPAddress(192,168,1,100), 8080);

  // Setup a function to be called every second
  timer.setInterval(1000L, myTimerEvent);

  pinMode(FLOW_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(FLOW_PIN), pulseCounter, RISING);
  lastTime = millis();
}

void loop()
{
  Blynk.run();
  timer.run();
  // You can inject your own code or combine it with other sketches.
  // Check other examples on how to communicate with Blynk. Remember
  // to avoid delay() function!

  if (millis() - lastTime >= 1000) { // every 1 second
    detachInterrupt(FLOW_PIN);

    // YF-S201: 450 pulses per liter
   float flowRate_mLps = 0.0;
  float totalMilliLiters = 0.0;

  flowRate_mLps = (pulseCount * 1000.0) / 450.0;   // mL/s
  totalMilliLiters += flowRate_mLps;               // cumulative mL

    pulseCount = 0;
    lastTime = millis();

    attachInterrupt(digitalPinToInterrupt(FLOW_PIN), pulseCounter, RISING);
    Blynk.virtualWrite(V5, flowRate_mLps);    // Gauge → Flow rate
    Blynk.virtualWrite(V27, totalMilliLiters); // Optional → Total liters
    Serial.println(flowRate_mLps);
    Serial.println(totalMilliLiters);

  }
}