import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

int cx, cy;
float secondsRadius;

PVector point;
ArrayList<PVector> points = new ArrayList<PVector>();

int numFreqs = 360;
float[] freqs;


Minim minim;
AudioPlayer player;
FFT fft;

void setup() {
  size(500, 500);
  stroke(255);

  freqs = new float[numFreqs];

  minim = new Minim(this);
  minim.debugOn();  
  player = minim.loadFile("flight.mp3", 1024);  
  player.loop();
  fft = new FFT(player.bufferSize(), player.sampleRate());

  int radius = min(width, height) / 2;
  secondsRadius = radius * 0.72;

  cx = width / 2;
  cy = height / 2;
  beginShape(POINTS);
  for (int a = 0; a < 360; a+=36) {
    float angle = radians(a);
    float x = cos(angle) * secondsRadius;
    float y = sin(angle) * secondsRadius;
    point = new PVector(x, y);
    points.add(point);
  }
  endShape();
}

void draw() {
  background(0);
  translate(width/2, height/2);
  fft.forward(player.mix);

  // Draw the clock background
  fill(80);
  noStroke();

  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(second(), 0, 60, 0, TWO_PI) - HALF_PI;

  // Draw the hands of the clock
  stroke(255);
  strokeWeight(1);

  println(fft.specSize());

  float baseRadius = 200 + 50 * player.mix.level();


  float max = min(numFreqs, fft.specSize());
  float PI2 = PI * 2;
  float PX = 0;
  float PY = 0;
  float X1 = 0;
  float Y1 = 0;

  float time = millis()/1000.0;

  for (int i = 0; i < max; i++) {

    float val = baseRadius - (fft.getBand(i) * i / 50);
    //float val = baseRadius - fft.getBand(i);
    freqs[i] = (val + freqs[i] * 3) / 4;
    float angle = map(i, 0, max, 0, PI2) + time;
    
    float X = freqs[i] * cos(angle);
    float Y = freqs[i] * sin(angle);
    if (i != 0) line(PX, PY, X, Y);
    if (i == 0) {
      X1 = X;
      Y1 = Y;
    }
    PX = X;
    PY = Y;
  }
  line(X1, Y1, PX, PY);


  // Draw the minute ticks
  strokeWeight(2);
  /*
  for (PVector p : points) {
   point(p.x, p.y);   
   p.normalize(new PVector(0, 0));
   pushMatrix();
   for (int i = 0; i < fft.specSize(); i++) {
   float cc = fft.getBand(i) * 2550;
   float ran = random(255);
   stroke(i);
   float b = min(fft.getBand(i), fft.getBand(i));
   float m = max(fft.getBand(i), fft.getBand(i));
   float r = map(fft.getBand(i), 0, 50, 0, 1);
   line(p.x, p.y, p.x / r, p.y / r);
   }
   popMatrix();
   }
   */
  //println(points.size());
}

