import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import java.util.Iterator;
import java.util.Map;
import ddf.minim.*;
Minim minim;

// Variables globales
PBox2D box2d;
Bola bola;
Iman iman;
Flipper miFlipperDerecho, miFlipperIzquierdo;
Boundary rect1, rect2;

String status;

AudioPlayer hit;
ArrayList<Boundary> boundaries;
ArrayList<ObstaculoCircular> obstaculos = new ArrayList<ObstaculoCircular>();

void setup() {
  size(450,760);
  smooth();

  box2d = new PBox2D(this);
  box2d.createWorld();
  box2d.setGravity (0, -30);
  
  boundaries = new ArrayList<Boundary>();
  
  miFlipperDerecho = new Flipper(width/2+100, height/2+240, 90, 12, true);
  miFlipperIzquierdo  = new Flipper(width/2-100, height/2+240, 90, 12, false);
  
  bola = new Bola();
  
  obstaculos.add(new ObstaculoCircular(width/2, 188.6, 12)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(width/2, 498.6, 12)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(380, 343.6, 12)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(70, 343.6, 12)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(312, 257, 19)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(312, 430, 19)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(138, 258, 19)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(138, 430, 19)); //x,y,radio
  obstaculos.add(new ObstaculoCircular(width/2, 344, 19)); //x,y,radio

  // ... agrega los que quieras
  
  minim = new Minim(this);
  hit = minim.loadFile(dataPath("flipper.mp3"));
  
  iman = new Iman(225, 0);  // Crea el imán en el centro superior
  
  rect1 = new Boundary(68, 576, 100, 10, 20, -150);
  rect2 = new Boundary(389, 576, 100, 10, 20, 150);
}

void draw() {
  background(228,215,207);
  box2d.step();
  iman.aplicarFuerzaMagnetica(bola);  // Aplica las fuerzas magnéticas
  iman.dibujar();                      // Dibuja el imán
  miFlipperDerecho.display();
  miFlipperIzquierdo.display();
  rect1.display();
  rect2.display();
  bola.display();
  
  // ❌ quitamos el piso
  // boundaries.add(new Boundary(width/2, height, width, 10));   // piso
  boundaries.add(new Boundary(width/2, 0, width, 10));        // techo
  boundaries.add(new Boundary(0, height/2, 10, height));      // izquierda
  boundaries.add(new Boundary(width, height/2, 10, height));  // derecha
  
  for (ObstaculoCircular o : obstaculos) {
  o.display();
  }
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
