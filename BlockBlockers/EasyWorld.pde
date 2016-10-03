// David Owen
// January 23, 2013 

import pbox2d.PBox2D;

import org.jbox2d.collision.Collision;
import org.jbox2d.collision.Manifold;
import org.jbox2d.collision.WorldManifold;

import org.jbox2d.collision.shapes.PolygonShape;

import org.jbox2d.common.Vec2;

import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.BodyDef;
import org.jbox2d.dynamics.BodyType;
import org.jbox2d.dynamics.FixtureDef;

import org.jbox2d.dynamics.contacts.Contact;

class World {
  PBox2D box2d;
  ArrayList<Body> bodies;
  
  // parent is "this" in .pde file with setup and draw.
  World(PApplet parent, boolean listenForCollisions) {
    box2d = new PBox2D(parent);
    box2d.createWorld();
    box2d.setGravity(0, 10);
    
    if (listenForCollisions)
      box2d.listenForCollisions();
    
    bodies = new ArrayList<Body>();
  }
  
  World(PApplet parent) {
    this(parent, false);
  }
  
  // Move simulation one step forward in time (should be
  // called once per frame).
  void step() {
    box2d.step();
  }
  
  // A platform is a box that doesn't move.
  // x, y - center position
  // w, h - width and height
  // returns (unique) id of new platform
  int addPlatform(int x, int y, int w, int h) {
    PolygonShape s = new PolygonShape();
    s.setAsBox(box2d.scalarPixelsToWorld(w / 2.0),
        box2d.scalarPixelsToWorld(h / 2.0));
        
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    
    Body b = box2d.createBody(bd);
    b.createFixture(s, 1);
    bodies.add(b);
    
    return (bodies.size() - 1);
  }
  
  // A box can move.
  // x, y - initial center position
  // w, h - width and height
  // returns (unique) id of new box
  int addBox(int x, int y, int w, int h) {
    PolygonShape s = new PolygonShape();
    s.setAsBox(box2d.scalarPixelsToWorld(w / 2.0),
        box2d.scalarPixelsToWorld(h / 2.0));
        
    FixtureDef fd = new FixtureDef();
    fd.shape = s;
    
    // You can adjust these to get different behavior.
    // restitution is "bounciness."
    fd.density = 2;
    fd.friction = 0.7;
    fd.restitution = 0.4;
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.bullet = true;
    
    Body b = box2d.createBody(bd);
    b.createFixture(fd);
    bodies.add(b);
    
    return (bodies.size() - 1);
  }
  
  void setUserData(int id, Object data) {
    bodies.get(id).setUserData(data);
  }
  
  // id - id of body whose x position you want to get
  // returns new x position calculated by physics simulation
  float getX(int id) {
    return box2d.getBodyPixelCoord(bodies.get(id)).x;
  }
  
  // id - id of body whose y position you want to get
  // returns new y position calculated by physics simulation
  float getY(int id) {
    return box2d.getBodyPixelCoord(bodies.get(id)).y;
  }
  
  // id - id of body whose rotation angle you want to get
  // returns new rotation angle calculated by physics simulation
  float getAngle(int id) {
    return -bodies.get(id).getAngle();
  }
  
  // id - id of body you want to apply a force to
  // x, y - direction and magnitude of force
  void applyForce(int id, float x, float y) {
    bodies.get(id).applyForce(new Vec2(x, y),
        bodies.get(id).getWorldCenter());
  }
}

void preSolve(Contact contact, Manifold manifold) {
  WorldManifold worldManifold = new WorldManifold();
  contact.getWorldManifold(worldManifold);
  Collision.PointState[] pointStatesA = new Collision.PointState[2];
  Collision.PointState[] pointStatesB = new Collision.PointState[2];
  Collision.getPointStates(pointStatesA, pointStatesB,
      manifold, contact.getManifold());
  
  if (pointStatesB[0] == Collision.PointState.ADD_STATE) {
    Body bodyA = contact.getFixtureA().getBody();
    Body bodyB = contact.getFixtureB().getBody();
    Vec2 point = worldManifold.points[0];
    Vec2 velocityA = bodyA.getLinearVelocityFromWorldPoint(point);
    Vec2 velocityB = bodyB.getLinearVelocityFromWorldPoint(point);
    
    float approachVelocity = abs(Vec2.dot(velocityB.sub(velocityA),
        worldManifold.normal));
    
    // You need a collision method in the sketch for this version to work.
    collision(bodyA.getUserData(), bodyB.getUserData(), approachVelocity);
  }
}

void beginContact(Contact contact) {
}

void endContact(Contact contact) {
}
