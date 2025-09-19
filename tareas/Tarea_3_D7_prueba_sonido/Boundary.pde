class Boundary {
  float x, y;       // posición central
  float w, h;       // ancho y alto
  float r;          // radio de borde redondeado
  float angulo;     // ángulo del rectángulo en radianes
  Body body;        // cuerpo de Box2D

  // ----------------- CONSTRUCTORES -----------------
  Boundary(float x, float y, float w, float h, float r, float anguloGrados) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.r = r;
    this.angulo = radians(anguloGrados); // convertir a radianes
    crearCuerpo();
  }

  // Constructor con ángulo por defecto (0°)
  Boundary(float x, float y, float w, float h, float r) {
    this(x, y, w, h, r, 0);
  }

  Boundary(int x, int y, int w, int h, int r, int anguloGrados) {
    this((float)x, (float)y, (float)w, (float)h, (float)r, (float)anguloGrados);
  }

  Boundary(int x, int y, int w, int h) {
    this((float)x, (float)y, (float)w, (float)h, 20, 0);
  }

  // ----------------- CREAR CUERPO -----------------
  void crearCuerpo() {
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.angle = -angulo; // rotar el cuerpo en Box2D
    bd.type = BodyType.STATIC;

    body = box2d.world.createBody(bd);

    PolygonShape ps = new PolygonShape();
    ps.setAsBox(box2d.scalarPixelsToWorld(w/2), box2d.scalarPixelsToWorld(h/2));

    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = 1;
    fd.friction = 0.1f;    // poca fricción para deslizar
    fd.restitution = 0.0f; // sin rebote

    body.createFixture(fd);
  }

  // ----------------- DIBUJAR -----------------
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a); // para que coincida con Box2D
    fill(219, 192, 163);
    rectMode(CENTER);
    rect(0, 0, w, h, r);
    popMatrix();
  }
}
