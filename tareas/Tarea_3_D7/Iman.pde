class Iman {
  // Propiedades
  float x, y;               // Posición del centro del imán (en píxeles)
  float radio;              // Radio del semicírculo visible
  float radioAtraccion;     // Radio del campo magnético
  long tiempoRetencion;     // Tiempo en ms que retiene la bola
  float velocidadLiberacion;

  // Estado
  boolean bolaEstaAtraida;
  long tiempoInicioAtraccion;
  long ultimaLiberacion;
  long cooldownTiempo;

  // ---------- CONSTRUCTORES ----------
  // Constructor por defecto: coloca el imán en (223,42)
  Iman() {

  }

  // Constructor con floats
  Iman(float x, float y) {
    this.x = x;
    this.y = y;
    this.radio = 50;
    this.radioAtraccion = 80;
    this.tiempoRetencion = 2000; // 2 segundos
    this.cooldownTiempo = 1000;  // 1s cooldown
    this.velocidadLiberacion = 25; // magnitud del impulso al liberar

    this.bolaEstaAtraida = false;
    this.tiempoInicioAtraccion = 0;
    this.ultimaLiberacion = 0;
  }

  // Constructor con ints (evita "constructor undefined")
  Iman(int x, int y) {
    this((float)x, (float)y);
  }

  // ---------- LÓGICA ----------
  void aplicarFuerzaMagnetica(Bola bola) {
    if (bola.isDead) {
      if (bolaEstaAtraida) {
        bolaEstaAtraida = false;
        ultimaLiberacion = millis();
      }
      return;
    }

    Vec2 posBola = box2d.getBodyPixelCoord(bola.body);
    float distancia = dist(posBola.x, posBola.y, x, y);
    boolean dentro = distancia <= radioAtraccion;
    boolean cooldownListo = (millis() - ultimaLiberacion) >= cooldownTiempo;

    if (dentro && !bolaEstaAtraida && cooldownListo) {
      bolaEstaAtraida = true;
      tiempoInicioAtraccion = millis();
      //println("Bola capturada por el imán");
    }

    if (bolaEstaAtraida) {
      long transcurrido = millis() - tiempoInicioAtraccion;
      if (transcurrido >= tiempoRetencion) {
        // liberar
        bolaEstaAtraida = false;
        ultimaLiberacion = millis();
        //println("Bola liberada del imán");
        // Impulso hacia abajo (mundo físico)
        Vec2 impulso = new Vec2(0, velocidadLiberacion);
        bola.body.applyLinearImpulse(impulso, bola.body.getWorldCenter());
      } else {
        // mantener "pegada" al borde curvo inferior del semicírculo
        pegarBolaAlIman(bola, posBola);
      }
    }
  }

  // Mantiene la bola pegada en el perímetro inferior del semicírculo
  void pegarBolaAlIman(Bola bola, Vec2 posBola) {
    // Ángulo de la bola respecto al centro del imán
    float angulo = atan2(posBola.y - y, posBola.x - x);
    // Limitamos el ángulo a la mitad inferior (PI a TWO_PI)
    if (angulo < PI) angulo = PI;
    if (angulo > TWO_PI) angulo = TWO_PI;

    // Posición exacta en el borde del semicírculo (en píxeles)
    float px = x + radio * cos(angulo);
    float py = y + radio * sin(angulo);

    // Convertir posiciones a coordenadas del mundo de Box2D
    Vec2 destinoPixels = new Vec2(px, py);
    Vec2 actualWorld = box2d.coordPixelsToWorld(posBola);
    Vec2 targetWorld = box2d.coordPixelsToWorld(destinoPixels);

    // Vector velocidad deseada en unidades del mundo
    Vec2 vel = targetWorld.sub(actualWorld);
    vel.mulLocal(10.0f); // factor para "pegar" rápido
    bola.body.setLinearVelocity(vel);
  }

  // Punto sólido: ahora la curva es la mitad inferior (py >= y)
  boolean puntoEnIman(float px, float py) {
    float d = dist(px, py, x, y);
    return (d <= radio && py >= y);
  }

  void liberarBola() {
    if (bolaEstaAtraida) {
      bolaEstaAtraida = false;
      ultimaLiberacion = millis();
    }
  }

  void dibujar() {
    pushMatrix();
    noStroke();

    // Área de atracción (visual)
    if (bolaEstaAtraida) fill(50, 79, 166, 100);
    else {
      long since = millis() - ultimaLiberacion;
      if (since < cooldownTiempo) fill(50, 79, 166, 80);
      else fill(50, 79, 166, 80);
    }
    arc(x, y, radioAtraccion*2, radioAtraccion*2, 0, PI);


    // Semicírculo: curva hacia abajo, parte recta arriba
    fill(50, 79, 166);
    arc(x, y, radio * 2, radio * 2, 0, PI); // 0..PI dibuja semicirc. con curva abajo

    // Brillo decorativo
    if (bolaEstaAtraida) fill(50, 79, 166, 200);
    else fill(50, 79, 166, 150);
    noStroke();
    arc(x, y - 10, radio * 1.2, radio * 1.2, 0.3, PI - 0.3);

    popMatrix();
  }

  // Getters (opcionales)
  float getX() { return x; }
  float getY() { return y; }
  float getRadio() { return radio; }
  float getRadioAtraccion() { return radioAtraccion; }
  boolean estaAtrayendo() { return bolaEstaAtraida; }

  String getInfoDebug() {
    String estado = bolaEstaAtraida ? "ATRAYENDO" : "LIBRE";
    long cooldownRestante = cooldownTiempo - (millis() - ultimaLiberacion);
    if (cooldownRestante > 0 && !bolaEstaAtraida) {
      estado = "COOLDOWN (" + (cooldownRestante/1000.0) + "s)";
    }
    return "Estado del imán: " + estado;
  }
}
