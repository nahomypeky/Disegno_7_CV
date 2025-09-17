class Bola {
  Body body;
  float r;
  boolean isDead = false;
  int respawnFrame = -1;

  Bola() {
    r = 12; // radio en píxeles
    makeBody(width/2 - 200, 0);
  }

  void makeBody(float x, float y) {
    Vec2 pos = box2d.coordPixelsToWorld(x, y);

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(pos);
    body = box2d.world.createBody(bd);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 2.0;
    fd.friction = 0.1;
    fd.restitution = 0.9;

    body.createFixture(fd);

    isDead = false;
    respawnFrame = -1;
  }

  void display() {
    if (isDead) {
      if (frameCount >= respawnFrame) {
        // generar x aleatoria pero fuera del iman
        float xSpawn = generarPosicionAleatoria();
        makeBody(xSpawn, 0); // reaparece desde arriba
      }
      return;
    }

    Vec2 pos = box2d.getBodyPixelCoord(body);

    if (pos.y > height) {
      box2d.destroyBody(body);
      isDead = true;
      respawnFrame = frameCount + 60; // ~1 segundo de delay
      return;
    }

    pushMatrix();
    translate(pos.x, pos.y);
    fill(242, 61, 61); // rojo
    noStroke();
    ellipse(0, 0, r*2, r*2);
    popMatrix();
  }
  
  float generarPosicionAleatoria(){
    float xSpawn;
    do {
      xSpawn = random(r, width - r); //dentro de la pantalla
    } while (dist(xSpawn, 0, iman.getX(), iman.getY()) < iman.getRadioAtraccion());
    return xSpawn;
    }
}
