class Teletransportador {
  PImage img;
  float x, y;
  float r;

  // estados y tiempos
  boolean absorbiendo = false;
  boolean enCooldown = false;
  long tiempoInicioAbsorcion = 0;
  long duracionAbsorcion = 500;        // ms que tarda en absorber
  long cooldownAfterExpulsion = 400;   // ms después de expulsar sin reactivar
  long tiempoFinCooldown = 0;

  float velocidadExpulsada = 15;       // magnitud (ajustable)
  
  float anguloRotacion = 0;
  float velocidadRotacion = 0.05;

  Teletransportador(float radio, String pathImg) {
    this.r = radio;
    img = loadImage(pathImg);
    

    // Genera una posicion libre automàticamente
    Vec2 pos = generarPosicionLibre(r);
    this.x = pos.x;
    this.y = pos.y;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(anguloRotacion);
    imageMode(CENTER);
    image(img, 0, 0, r*2, r*2);
    popMatrix();
    
    anguloRotacion += velocidadRotacion;
  }

  boolean colisionConBola(Bola b) {
    if (b == null || b.body == null) return false;
    Vec2 posBola = box2d.getBodyPixelCoord(b.body);
    float d = dist(posBola.x, posBola.y, x, y);
    return d < r + b.r;
  }

  void actualizar(Bola b) {
    // seguridad
    if (b == null || b.body == null || b.isDead) return;

    // cooldown: mientras está, no hace nada hasta que expire
    if (enCooldown) {
      if (millis() >= tiempoFinCooldown) enCooldown = false;
      else return;
    }

    // posición de la bola en píxeles
    Vec2 posBolaPix = box2d.getBodyPixelCoord(b.body);

    // iniciar absorción si hay colisión y no estaba absorbiendo
    if (!absorbiendo && colisionConBola(b)) {
      absorbiendo = true;
      tiempoInicioAbsorcion = millis();
     // reproducir sonido de absorción
    if (sonidoAbsorcion != null) {
        sonidoAbsorcion.rewind(); // asegurarse que empieza desde el inicio
        sonidoAbsorcion.play(); 
     }
   }

    if (absorbiendo) {
      // distancia en píxeles (para decidir cuando está "en el centro")
      float distanciaPix = dist(posBolaPix.x, posBolaPix.y, x, y);

      // calculamos la velocidad deseada en unidades *world* para "pegar" la bola al centro
      Vec2 targetWorld = box2d.coordPixelsToWorld(new Vec2(x, y));
      Vec2 actualWorld = b.body.getPosition(); // ya está en world
      Vec2 velWorld = targetWorld.sub(actualWorld); // vector hacia el centro (world)
      // si la bola aún está lejos y no se pasó el tiempo de absorción, moverla hacia el centro
      if (distanciaPix > 4 && millis() - tiempoInicioAbsorcion < duracionAbsorcion) {
        // suavizamos la velocidad
        velWorld.mulLocal(4.0f); // factor: ajustar a lo que se sienta bien
        b.body.setLinearVelocity(velWorld);
      } else {
        // llegó al centro (o se acabó el tiempo): expulsar y mover espiral
        // 1) mover el espiral a nueva posición libre
        Vec2 nuevaPos = generarPosicionLibre(r);
        this.x = nuevaPos.x;
        this.y = nuevaPos.y;

        // 2) determinar dirección y magnitud de expulsión (en píxeles)
        Vec2 impulsoPixels = new Vec2(0,1); //vector unitario hacia abajo
        // multiplicador para la magnitud en píxeles (ajustable)
        float magnitudPixels = velocidadExpulsada * 20.0; // puedes bajar/subir este número
        impulsoPixels.mulLocal(magnitudPixels); // ahora es en píxeles

        // 3) colocar la bola JUSTO AFUERA del espiral nuevo para evitar solapamiento
        float separacion = this.r + b.r + 4; // píxels, margen para que no se toquen
        Vec2 targetPixelForBall = new Vec2(this.x + (impulsoPixels.x == 0 ? 0 : (impulsoPixels.x/dist(0,0,impulsoPixels.x,impulsoPixels.y))*separacion),
                                           this.y + (impulsoPixels.y == 0 ? 0 : (impulsoPixels.y/dist(0,0,impulsoPixels.x,impulsoPixels.y))*separacion));
        // para evitar división por cero simplificamos: si impulsoPixels es muy pequeño, usamos (0,-1)
        float lenImp = (float)Math.sqrt(impulsoPixels.x*impulsoPixels.x + impulsoPixels.y*impulsoPixels.y);
        if (lenImp < 0.0001f) {
          targetPixelForBall.set(this.x, this.y - separacion);
          impulsoPixels.set(0, -magnitudPixels);
          lenImp = (float)Math.sqrt(impulsoPixels.x*impulsoPixels.x + impulsoPixels.y*impulsoPixels.y);
        } else {
          // normalizar impulsoPixels para posicionar correctamente
          Vec2 unit = new Vec2(impulsoPixels.x/lenImp, impulsoPixels.y/lenImp);
          targetPixelForBall.set(this.x + unit.x * separacion, this.y + unit.y * separacion);
        }

        // 4) convertir objetivo y velocidad a world y aplicar
        Vec2 targetWorldForBall = box2d.coordPixelsToWorld(targetPixelForBall);
        Vec2 impulsoWorld = box2d.vectorPixelsToWorld(impulsoPixels); // convierte vector píxeles->world

        // teletransportar la bola a la posición objetivo (world) y aplicarle la velocidad
        b.body.setTransform(targetWorldForBall, 0);
        b.body.setLinearVelocity(impulsoWorld);
        b.body.setAngularVelocity(0);

        // 5) terminar absorción y poner cooldown para evitar reactivación inmediata
        absorbiendo = false;
        enCooldown = true;
        tiempoFinCooldown = millis() + cooldownAfterExpulsion;
        cambiarAProximaConfig();
      }
    }
  } 

  // ---------------- Genera posición libre similar a lo que ya tenías ----------------
  Vec2 generarPosicionLibre(float radio) {
    while (true) {
      float px = random(radio, width - radio);
      //limite de altura
      float py = random(radio, height - 300);
      
      Vec2 pos = new Vec2(px, py);
      boolean valido = true;

      // evitar colisión con obstáculos circulares
      for (ObstaculoCircular o : obstaculos) {
        if (dist(px, py, o.pos.x, o.pos.y) < radio + o.r + 5) {
          valido = false; break;
        }
      }

      // evitar colisión con boundaries (aprox con cajas)
      for (Boundary b : boundaries) {
        if (px > b.x - b.w/2 - radio && px < b.x + b.w/2 + radio &&
            py > b.y - b.h/2 - radio && py < b.y + b.h/2 + radio) {
          valido = false; break;
        }
      }

      // evitar imán
      if (dist(px, py, iman.getX(), iman.getY()) < iman.getRadioAtraccion() + radio) {
        valido = false;
      }

      if (valido) return pos;
    }
  }
  void stop () {
    if (sonidoAbsorcion != null) sonidoAbsorcion.close();
  }
} 
