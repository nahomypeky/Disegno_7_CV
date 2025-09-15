class Bola {
  Body body;
  float r;
  boolean isDead = false;
  int respawnFrame = -1;

  Bola() {
    r = 10; // radio en píxeles
    makeBody(width/2 - 100, 0);
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
    fd.density = 0.5;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);

    isDead = false;
    respawnFrame = -1;
  }

  void display() {
    if (isDead) {
      if (frameCount >= respawnFrame) {
        makeBody(width/2 - 100, 0); // reaparece después del delay
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
    fill(255, 0, 0); // rojo
    noStroke();
    ellipse(0, 0, r*2, r*2);
    popMatrix();
  }
}
