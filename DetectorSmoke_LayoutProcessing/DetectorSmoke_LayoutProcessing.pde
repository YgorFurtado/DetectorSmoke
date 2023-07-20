import processing.serial.*;

Serial port;
int sensorValueSmoke;
float sensorValueTemperatura;
float sensorValueUmidade;
boolean setupCompleted = false;
boolean calcAverage = false;
boolean isSmokeDetected = false;

PFont regularFont;
PFont boldFont;

boolean isLoadingScreen = true;

int fadeDuration = 1000; // Fade duration in milliseconds
int fadeInStartTime;
int fadeOutStartTime;

void setup() {
  fullScreen();
  textAlign(CENTER);
  noLoop();

  String[] portList = Serial.list();
  if (portList.length > 0) {
    port = new Serial(this, portList[0], 9600);
    port.bufferUntil('\n');
  }

  regularFont = createFont("Montserrat-Regular.ttf", width / 20);
  boldFont = createFont("Montserrat-Bold.ttf", width / 15);

  fadeInStartTime = millis(); // Set the start time for fade-in
  fadeOutStartTime = millis(); // Set the start time for fade-out
}

void draw() {
  // Calculate the fade-in and fade-out amounts based on time
  int fadeInTime = millis() - fadeInStartTime;
  int fadeOutTime = millis() - fadeOutStartTime;

  // Calculate the fade-in and fade-out percentages
  float fadeInPercent = constrain(map(fadeInTime, 0, fadeDuration, 0, 1), 0, 1);
  float fadeOutPercent = constrain(map(fadeOutTime, 0, fadeDuration, 1, 0), 0, 1);

  // Calculate the alpha values for fade-in and fade-out
  int fadeInAlpha = int(255 * fadeInPercent);
  int fadeOutAlpha = int(255 * fadeOutPercent);

  // Set the background color with fade-in and fade-out
  color bgColor = color(190, 210, 230, max(fadeInAlpha, fadeOutAlpha));
  background(bgColor);

  drawBackgroundArt(); // Draw the monochromatic background art

  if (setupCompleted && calcAverage) {
    drawSmokeDetector();
    drawsensorValueSmoke();
  } else if (setupCompleted) {
    drawCalculationInProgress();
  } else {
    drawInitializing();
  }
}

void drawBackgroundArt() {
  // Set the color for the background art
  color bgColor = color(190, 210, 230); // Monochromatic blue

  // Set the background color
  background(bgColor);
}

void drawSmokeDetector() {
  float ellipseSize = width / 4;
  float ellipseX = width / 2;
  float ellipseY = height / 2;

  stroke(0); // Set the stroke color to black
  strokeWeight(1); // Set the border thickness to 1 pixel
  fill(isSmokeDetected ? color(255, 133, 133) : color(123, 218, 150)); // Pastel red or pastel green
  ellipse(ellipseX, ellipseY, ellipseSize * 0.8, ellipseSize * 0.8);
}

void drawsensorValueSmoke() {
  fill(0);
  textSize(width / 20);
  float textY = height / 2 + width / 8 + (width / 8); // Adjust the value 50 for the desired spacing
  textFont(regularFont); // Set the regular font
  
  // Valor de Fumaça
  text("Valor Fumaça: " + sensorValueSmoke, width / 2, textY - (width / 8));
  
  // Valor de Temperatura
  text("Valor Temperatura: " + sensorValueTemperatura, width / 2, textY);
  
  // Valor de Umidade
  text("Valor Umidade: " + sensorValueUmidade, width / 2, textY + (width / 8));
  
  isLoadingScreen = false;
}


void drawCalculationInProgress() {
  fill(0);
  textSize(width / 15);
  textFont(boldFont); // Set the bold font
  text("Calculando Valor Médio", width / 2, height / 2);

  isLoadingScreen = true;
}

void drawInitializing() {
  fill(0);
  textSize(width / 15);
  textFont(boldFont); // Set the bold font
  text("Iniciando", width / 2, height / 2);

  isLoadingScreen = true;
}

void serialEvent(Serial port) {
  String serialData = port.readStringUntil('\n');
  if (serialData != null) {
    serialData = serialData.trim();
    if (serialData.equals("Aquecendo os Sensores...")) {
      setupCompleted = false;
      println("Aquecendo os Sensores...");
    } else if (serialData.equals("Sensores Aquecidos!")) {
      setupCompleted = true;
      println("Sensores Aquecidos!");
      loop();
    } else if (serialData.equals("Valor Medio Do Sensor de Gas Calculado!")) {
      calcAverage = true;
      println("Valor Medio Do Sensor de Gas Calculado!");
      loop();
    } else if (serialData.startsWith("f")) {
      sensorValueSmoke = int(trim(serialData.substring(2)));
    } else if (serialData.startsWith("t")) {
      sensorValueTemperatura = int(trim(serialData.substring(2)));
    } else if (serialData.startsWith("u")) {
      sensorValueUmidade = int(trim(serialData.substring(2)));
    } else if (serialData.equals("Fumaca!")) {
      isSmokeDetected = true;
      println("Fumaca Detectada!");
    } else if (serialData.equals("Fumaca Dissipada!")) {
      isSmokeDetected = false;
      println("Fumaca Dissipada.");
    }
  }
}
