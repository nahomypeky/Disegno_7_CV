import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
//import java.util.Iterator;
//import java.util.Map;
import ddf.minim.*;

Minim minim;
AudioPlayer sonidoAbsorcion;
AudioPlayer magnetic;
AudioSample sonidoIman;
AudioSample suelta;
AudioSample ting;
AudioPlayer hit;

// Variables globales
PBox2D box2d;
Bola bola;
Iman iman;
Flipper miFlipperDerecho, miFlipperIzquierdo;
Boundary rect1, rect2;
Teletransportador espiral;

String status;

ArrayList<Boundary> boundaries;

// ▼▼ NUEVO: manejamos configuraciones de obstáculos
ArrayList<ObstaculoCircular> obstaculos = new ArrayList<ObstaculoCircular>();
int configActual = 1;                 // 1 = config inicial
boolean imanAtrayendoPrev = false;    // para detectar transición (pegado → liberado)

void setup() {
  size(450,760);
  smooth();

  box2d = new PBox2D(this);
  box2d.createWorld();
  box2d.setGravity (0, -100); //CAMBIAR A -30
  
  box2d.listenForCollisions();
  
  boundaries = new ArrayList<Boundary>();
  
  miFlipperDerecho = new Flipper(width/2+100, height/2+240, 90, 11, true);
  miFlipperIzquierdo  = new Flipper(width/2-100, height/2+240, 90, 11, false);
  
  bola = new Bola();

  // ▼▼ NUEVO: iniciamos con la configuración 1 (idéntica a tu lista original)
  obstaculos = configObstaculos1();
  
  minim = new Minim(this);
  hit = minim.loadFile(dataPath("flipper.mp3"));
  sonidoAbsorcion = minim.loadFile("abs.mp3");
  magnetic = minim.loadFile("magnetic.mp3");
  sonidoIman = minim.loadSample("anvil.mp3");
  suelta = minim.loadSample("suelta.mp3");
  ting = minim.loadSample("ting.mp3");
  
  iman = new Iman(225, 0);  // Crea el imán en el centro superior
  
  rect1 = new Boundary(48, 570, 155, 10, 20, -150);
  rect2 = new Boundary(399, 570, 150, 10, 20, 150);
  
  espiral = new Teletransportador(30, "espiral.png"); // 30 = radio
}

void draw() {
  background(228,215,207);
  box2d.step();
  iman.aplicarFuerzaMagnetica(bola);  // Aplica las fuerzas magnéticas
  iman.dibujar();   

  // Dibuja el imán
  miFlipperDerecho.display();
  miFlipperIzquierdo.display();
  rect1.display();
  rect2.display();
  bola.display();
  
  espiral.display();

  if (espiral.colisionConBola(bola)) {
    espiral.actualizar(bola);
  }

  boundaries.add(new Boundary(width/2, 0, width, 10));        // techo
  boundaries.add(new Boundary(0, height/2, 10, height));      // izquierda
  boundaries.add(new Boundary(width, height/2, 10, height));  // derecha
  
  for (ObstaculoCircular o : obstaculos) {
    o.display();
  }

  // ▼▼ NUEVO: detectar transición "pegado → liberado" para cambiar de config
  boolean imanAtrayendoAhora = iman.estaAtrayendo();
  if (imanAtrayendoPrev && !imanAtrayendoAhora) {
    // se acaba de liberar del imán → cambia la configuración
   // cambiarAProximaConfig();
  }
  imanAtrayendoPrev = imanAtrayendoAhora;
}

void keyPressed() {
  if (keyCode == LEFT) {
    miFlipperIzquierdo.activar();
    hit.rewind();
    hit.play();
  } else if (keyCode == RIGHT) {
    miFlipperDerecho.activar();
    hit.rewind();
    hit.play();
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    miFlipperIzquierdo.soltar();
  } else if (keyCode == RIGHT) {
    miFlipperDerecho.soltar();
  }
}

// =====================
// ▼▼▼ CONFIGURACIONES ▼▼▼
// =====================

// Igual a tu configuración actual
ArrayList<ObstaculoCircular> configObstaculos1() {
  ArrayList<ObstaculoCircular> lista = new ArrayList<ObstaculoCircular>();
  lista.add(new ObstaculoCircular(width/2, 188.6, 12)); //x,y,radio
  //lista.add(new ObstaculoCircular(width/2, 498.6, 12));
  lista.add(new ObstaculoCircular(380, 343.6, 12));
  lista.add(new ObstaculoCircular(70, 343.6, 12));
  lista.add(new ObstaculoCircular(312, 257, 19));
  lista.add(new ObstaculoCircular(312, 430, 19));
  lista.add(new ObstaculoCircular(138, 258, 19));
  lista.add(new ObstaculoCircular(138, 430, 19));
  lista.add(new ObstaculoCircular(width/2, 344, 19));
  return lista;
}

// Un layout alternativo de ejemplo (podés editarlo a gusto)
ArrayList<ObstaculoCircular> configObstaculos2() {
  ArrayList<ObstaculoCircular> lista = new ArrayList<ObstaculoCircular>();
  // Triángulo superior
  lista.add(new ObstaculoCircular(width/2, 220, 16));
  lista.add(new ObstaculoCircular(width/2 - 80, 300, 14));
  lista.add(new ObstaculoCircular(width/2 + 80, 300, 14));
  // Línea media
  lista.add(new ObstaculoCircular(width/3, 420, 18));
  lista.add(new ObstaculoCircular(2*width/3, 420, 18));
  // Centro
  lista.add(new ObstaculoCircular(width/2, 360, 20));
  // Bajos laterales
  lista.add(new ObstaculoCircular(95, 520, 14));
  lista.add(new ObstaculoCircular(width-95, 520, 14));
  return lista;
}

// =====================
// ▼▼▼ UTILIDADES ▼▼▼
// =====================

// Destruye bodies de la config actual y carga la siguiente
void cambiarAProximaConfig() {
  // Destruir cuerpos de la config anterior
  for (ObstaculoCircular o : obstaculos) {
    o.destroy(); // elimina el body del mundo
  }
  obstaculos.clear();

  // Avanzar al siguiente índice
  if (configActual == 1) {
    obstaculos = configObstaculos2();
    configActual = 2;
  } else {
    obstaculos = configObstaculos1();
    configActual = 1;
  }
}
void beginContact(Contact cp) {
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1 != null && o2 != null) {
    // Bola con obstáculo
    if ((o1 instanceof Bola && o2 instanceof ObstaculoCircular) ||
        (o2 instanceof Bola && o1 instanceof ObstaculoCircular)) {
      
      if (ting != null) {
        
        ting.trigger();
      }
    }
  }
}
void endContact(Contact cp) {
 
}
