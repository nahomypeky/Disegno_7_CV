class ObstaculoCircular {
  Body body;
  float r;
  Vec2 pos;

  ObstaculoCircular(float x, float y, float radio) {
    r = radio;
    pos = new Vec2(x, y);

    // Definir el cuerpo estático
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(pos));

    body = box2d.world.createBody(bd);

    // Definir la forma circular
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

    // Definir las propiedades físicas
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1.0;
    fd.friction = 0.1;
    fd.restitution = 0.40; // rebota bien

    body.createFixture(fd);
  }

  void display() {
    Vec2 posScreen = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(posScreen.x, posScreen.y);
    fill(219, 192, 163);
    noStroke();
    ellipse(0, 0, r*2, r*2);
    popMatrix();
  }
}
