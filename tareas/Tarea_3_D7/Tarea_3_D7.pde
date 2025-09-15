import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

import ddf.minim.*;
Minim minim;

PBox2D box2d;
Flipper miFlipperDerecho, miFlipperIzquierdo;
Bola bola;

String status;

AudioPlayer hit;

ArrayList<Boundary> boundaries;

void setup() {
  size(560, 1000);
  smooth();

  box2d = new PBox2D(this);
  box2d.createWorld();
  box2d.setGravity (0, -220);
  
  boundaries = new ArrayList<Boundary>();
  
  miFlipperDerecho = new Flipper(width/2+170, height/2+350, 150, 15, true);
  miFlipperIzquierdo  = new Flipper(width/2-170, height/2+350, 150, 15, false);
  bola = new Bola();
  
  minim = new Minim(this);
  hit = minim.loadFile(dataPath("flipper.mp3"));
}

void draw() {
  background(228,215,207);
  box2d.step();
  miFlipperDerecho.display();
  miFlipperIzquierdo.display();
  bola.display();
  
  // ❌ quitamos el piso
  // boundaries.add(new Boundary(width/2, height, width, 10));   // piso
  boundaries.add(new Boundary(width/2, 0, width, 10));        // techo
  boundaries.add(new Boundary(0, height/2, 10, height));      // izquierda
  boundaries.add(new Boundary(width, height/2, 10, height));  // derecha
}

void keyPressed() {
  if (keyCode == LEFT) {
    miFlipperIzquierdo.toggleMotor();
    hit.rewind();
    hit.play();
  } else if (keyCode == RIGHT) {
    miFlipperDerecho.toggleMotor();
    hit.rewind();
    hit.play();
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    miFlipperIzquierdo.toggleMotor();
  } else if (keyCode == RIGHT) {
    miFlipperDerecho.toggleMotor();
  }
}
