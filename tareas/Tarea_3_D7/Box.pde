class Box {

  Body body;
  float w;
  float h;

  
  Box(float x, float y, float w_, float h_, boolean lock) {
    w = w_;
    h = h_;

    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x,y)));
    if (lock) bd.type = BodyType.STATIC;
    else bd.type = BodyType.DYNAMIC;

    body = box2d.createBody(bd);

    
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW, box2dH);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
   
    fd.density = 1;
    fd.friction = 0.5;
    fd.restitution = 0.0;

    body.createFixture(fd);

    // Velocidad random
    //body.setLinearVelocity(new Vec2(random(-5,5),random(2,5)));
    //body.setAngularVelocity(random(-5,5));
  }

  
  void killBody() {
    box2d.destroyBody(body);
  }

  
  void display() {
    
    Vec2 pos = box2d.getBodyPixelCoord(body);

    float a = body.getAngle();

    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-a);
    fill(175);
    noStroke();
    rect(0,0,w,h);
    popMatrix();
  }
}
