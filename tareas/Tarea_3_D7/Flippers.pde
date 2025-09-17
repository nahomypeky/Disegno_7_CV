class Flipper {
  RevoluteJoint joint;
  Paleta box1;
  Box box2;
  RevoluteJointDef rjd;

  Flipper(float x, float y, int ancho, int largo, boolean der) {

    box1 = new Paleta(x, y, ancho, largo, false, der);
    box2 = new Box(x, y, 5, 5, true); // el eje quieto


    rjd = new RevoluteJointDef();

    Vec2 offset;
    rjd.initialize(box1.body, box2.body, box1.body.getWorldCenter());
    if (der) offset = box2d.vectorPixelsToWorld(new Vec2(ancho/2, 0));
    else offset = box2d.vectorPixelsToWorld(new Vec2(-ancho/2, 0));
    rjd.localAnchorA = offset;

    // Turning on a motor (optional)
    //rjd.motorSpeed = TWO_PI*100000;       // how fast?
    rjd.maxMotorTorque = 200000.0; // how powerful?
    rjd.enableMotor = false;      // is it on?

    //Límites de rotación---------------------------------------
    if (der) {
      rjd.motorSpeed = TWO_PI*80;       // how fast?
      rjd.enableLimit = true;    
      rjd.lowerAngle = -0.5; 
      rjd.upperAngle = 0.5;
    } else {
      rjd.motorSpeed = -TWO_PI*80;       // how fast?
      rjd.enableLimit = true;    
      rjd.lowerAngle = -0.5; 
      rjd.upperAngle = 0.5;
    }


    // Create the joint
    joint = (RevoluteJoint) box2d.world.createJoint(rjd);
  } // end of constructor

  // Turn the motor on or off
  void toggleMotor() {
    joint.enableMotor(!joint.isMotorEnabled());
  }

  boolean motorOn() {
    return joint.isMotorEnabled();
  }

  void display() {
    box1.display();
  }
} // end class


class Paleta {
  
  Body body;
  float w;
  float h;
  boolean der;

  
  Paleta(float x, float y, float w_, float h_, boolean lock, boolean _der) {
    w = w_;
    h = h_;
    der = _der;

    
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
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
    fd.restitution = 0.0001;

    body.createFixture(fd);

    // Give it some initial random velocity
    body.setLinearVelocity(new Vec2(random(-5, 5), random(2, 5)));
    body.setAngularVelocity(random(-5, 5));
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  
  void display() {
   
    Vec2 pos = box2d.getBodyPixelCoord(body);
   
    float a = body.getAngle();

    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(242, 141, 53);
    noStroke();

    //ellipse(0,0,20,20);// punto central
    if (der) {
      ellipse(w/2, 0, h*2, h*2); 
      ellipse(-w/2, 0, h, h);
      beginShape();
      vertex(w/2, h);
      vertex(w/2, -h);
      vertex(-w/2, -h/2);
      vertex(-w/2, h/2);
      endShape(CLOSE);
 
      fill(242, 141, 53);
      ellipse(w/2, 0, h/2, h/2);
    } else {
      ellipse(w/2, 0, h, h); 
      ellipse(-w/2, 0, h*2, h*2);
      beginShape();
      vertex(w/2, h/2);
      vertex(w/2, -h/2);
      vertex(-w/2, -h);
      vertex(-w/2, h);
      endShape(CLOSE);
      // punto central
      fill(242, 141, 53);
      ellipse(-w/2, 0, h/2, h/2);
    }



    popMatrix();
  }
}
