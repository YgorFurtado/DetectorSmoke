#include "dht.h"

const int pinoDHT11 = A1;
const int sensorPin = A0; // Analog pin of MQ-2 sensor
const int warmupTime = 10000; // Sensor warm-up time (10 seconds)
const int measurementInterval = 500; // Measurement interval after warm-up (0.5 seconds)
const float thresholdMultiplier = 1.2; // Multiplier to check for smoke presence
dht DHT;

int sensorValue; // Current sensor value
float averageValue; // Average value recorded during warm-up
bool isSmokeDetected = false; // Flag to indicate smoke presence

void setup() {
  Serial.begin(9600);
  Serial.println("Aquecendo os Sensores..."); //Initializing

  // Sensor warm-up
  delay(warmupTime);
  Serial.println("Sensores Aquecidos!"); //Warm-up complete.

  // Calculate average during warm-up
  long sum = 0;
  for (int i = 0; i < warmupTime; i += measurementInterval) {
    sensorValue = analogRead(sensorPin);
    sum += sensorValue;
    delay(measurementInterval);
  }
  averageValue = sum / (warmupTime / measurementInterval);
  Serial.println("Valor Medio Do Sensor de Gas Calculado!"); //Average Complete!
  

  Serial.print("Average recorded during warm-up: ");
  Serial.println(averageValue);
}

void loop() {
  // Measurement and smoke presence check
  sensorValue = analogRead(sensorPin);
  DHT.read11(pinoDHT11);
  Serial.print("t");
  Serial.println(DHT.temperature);
  Serial.print("u");
  Serial.println(DHT.humidity);
  Serial.print("f"); //Measured value
  Serial.println(sensorValue);

  if (sensorValue >= thresholdMultiplier * averageValue) {
    if (!isSmokeDetected) {
      Serial.println("Fumaca!");
      isSmokeDetected = true;
    }
  } else {
    if (isSmokeDetected) {
      Serial.println("Fumaca Dissipada!");
      isSmokeDetected = false;
    }
  }

  delay(measurementInterval);
}
