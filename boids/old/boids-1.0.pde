/* Steering Behaviors
   Version 1.0 - 2010/07/29 */
   
// Global variables
World world;
int bNum = 50;
int pNum = 2;
int oNum = 5;

// Variables
float Rn = 80.0; // R neighborhood
float maxspeed = 5.0; // Maximum speed
float maxforce = 3.0; // Maximum steering force
float maxpursue = 20.0; // Maximum steering force
float maxevade = 10.0; // Maximum steering force
boolean info = false; // Display information
boolean bounded = true; // Bounded within world
boolean debug = false; // Display viewing fields and more

float ARadius = 100.0; // Arrival: max distance at which the agent may begin to slow down
float ERadius = 50.0; // Evade: radius of evade range
float WRadius = 40.0; // Wander: radius of wandering circle
float NRadius = 0.3; // Wander: radius of wander noise circle
float BRadius = 20.0; // Avoid: radius of agent bounding sphere
float ORadius = 20.0; // Avoid: radius of object bounding sphere
float CStep = 1.0/100.0; // Cohesion: move it #% of the way towards the center
float SDistance = 6000.0f; // Separation: small separation distance
float AVelocity = 1.0/8.0; // Alignment: add a small portion to the velocity

// Weight constants
float KNoise = 1.0;
float KWander = 1.0;
float KAvoid = 5.0;
float KFlock = 1.0;
float KCohesion = 1.0;
float KSeparate = 2.0;
float KAlignment = 1.0;

// Setup the Processing Canvas
void setup() {
  size(800, 600);  
  world = new World();
  smooth();
}

// Main draw loop
void draw() {
  background(255);  
  world.run();
}

void keyPressed() {
  // Display info
  if (key == 'a') {
    info = !info;
  }
  // Boundary mode
  if (key == 's') {
    bounded = !bounded;
    redraw();
  }
  // Debug mode
  if (key == 'd') {
    debug = !debug;
    redraw();
  }
  // Reset
  if (key == ' ') {
    world = new World();
    redraw();
  }
}

void mousePressed() {
  if (keyPressed) {
    if (mouseButton == LEFT) {
      // Add boid
      if (key == 'z') {
        Agent boid = new Agent(mouseX, mouseY, 1);
        world.boids.add(boid);
      }
      else if (key == 'x') {
        Agent predator = new Agent(mouseX, mouseY, 2);
        world.predators.add(predator);
      }
      else if (key == 'c') {
        Obj obj = new Obj(mouseX, mouseY, random(50, 100), round(random(1, 2)));
        world.objs.add(obj);
      }
    }
    if (mouseButton == RIGHT) {
      // Remove boid
      if (key == 'z') {
        if (world.boids.size() > 0) {
          world.boids.remove(0);      
        }
      }
      // Remove predator
      else if (key == 'x') {
        if (world.predators.size() > 0) {
          world.predators.remove(0);      
        }
      }
      // Remove object
      else if (key == 'c') {
        if (world.objs.size() > 0) {
          world.objs.remove(0);      
        }
      }
    }
  }
}

class Agent {
  float mass;
  float energy;
  Vector3D pos; // Position
  Vector3D vel; // Velocity
  Vector3D acc; // Acceleration
  int type; // Agent type
  float wdelta; // Wander delta
  int action; // Current action
  int prey; // Predator's target
  // Weights
  float wWan;
  float wAvo;
  float wFlo;
  float wCoh;
  float wSep;
  float wAli;

  Agent(float px, float py, int t) {
    mass = 10.0;
    energy = 10*ceil(random(5, 10));
    pos = new Vector3D(px, py);
    vel = new Vector3D(random(-5, 5), random(-5, 5));
    acc = new Vector3D();
    type = t;
    wdelta = 0.0;
    action = 0;
    updateweight();
  }

  void run(ArrayList boids, ArrayList predators, ArrayList objs) {
    acc.setXYZ(0, 0, 0); // Reset accelertion to 0 each cycle
    steer(boids, predators, objs); // Update steering with approprate behavior
    vel.add(acc); // Update velocity
    switch (action) {
      case 1: vel.limit(maxpursue); break; // Limit pursue speed
      case 2: vel.limit(maxevade); break; // Limit evade speed
      default: vel.limit(maxspeed); break; // Limit speed      
    }
    pos.add(vel); // Move agent
    bounding(); // Wrap around the screen or else...
    updateweight(); // Updates weights
    render();
  }

  void steer(ArrayList boids, ArrayList predators, ArrayList objs) { 
    if (type == 2) predator(boids); // Determine current action
    // Initialize steering forces
    Vector3D wan = new Vector3D();
    Vector3D flo = new Vector3D();
    Vector3D avo = new Vector3D();
    Vector3D pur = new Vector3D();
    Vector3D eva = new Vector3D();
    Vector3D arr = new Vector3D();
    Vector3D dep = new Vector3D();
    // Calculate steering forces
    switch (action) {
      // Evading
      case 1: {
        eva = evade(predators);
        avo = avoid(objs); 
        break; 
      }
      // Pursuing
      case 2: {
        pur = pursue(boids);
        avo = avoid(objs);  
        break;
      }
      // Wandering
      default: {
        if (type == 1) {
          wan = wander(); 
          avo = avoid(objs);
          flo = flocking(boids);
          eva = evade(predators);
          break;
        }
        if (type == 2) {
          wan = wander(); 
          avo = avoid(objs);   
          break;
        }
      }      
    }
    // User interaction
    if (mousePressed && keyPressed == false && type == 1) {
      // Left mouse button - Arrival
      if (mouseButton == LEFT) {
        Vector3D mouse = new Vector3D(mouseX, mouseY);
        arr = arrival(mouse);
      }
      // Right mouse button - Departure
      else if (mouseButton == RIGHT) {
        Vector3D mouse = new Vector3D(mouseX, mouseY);
        dep = departure(mouse);
        dep.mult(maxevade);
      }
    }
    // Apply weights
    wan.mult(wWan);
    avo.mult(wAvo);
    flo.mult(wFlo);
    // Accumulate steering force
    acc.add(wan);
    acc.add(avo);
    acc.add(flo);
    acc.add(pur);
    acc.add(eva);
    acc.add(arr);
    acc.add(dep);
    acc.limit(maxforce); // Limit to maximum steering force
  }
  
  void predator(ArrayList boids) {
    if (energy > 0) energy -= random(0.5);
    if (energy < 0) energy = 10*ceil(random(5, 10));
    if (energy < 20 && action == 0) {
      action = 2;
      prey = int(random(boids.size() - 1));
    }        
    if (energy > 20 && action == 2) action = 0;
  }

  Vector3D seek(Vector3D target) {
    Vector3D steer; // The steering vector
    Vector3D desired = Vector3D.sub(target, pos); // A vector pointing from current location to the target
    float distance = desired.mag2(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (distance > 0) {
      desired.normalize(); // Normalize desired

      desired.mult(maxforce);

      steer = Vector3D.sub(desired, vel); // Steering = Desired minus Velocity
    }
    else {
      steer = new Vector3D(0, 0);
    }
    return steer;
  }

  Vector3D flee(Vector3D target) {
    Vector3D steer; // The steering vector
    Vector3D desired = Vector3D.sub(target, pos); // A vector pointing from current location to the target
    float distance = desired.mag2(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (distance > 0 && distance < ARadius*100) {
      desired.normalize(); // Normalize desired

      desired.mult(maxforce);

      steer = Vector3D.sub(vel, desired); // Steering = Desired minus Velocity
    }
    else {
      steer = new Vector3D(0, 0);
    }
    return steer;
  }

  Vector3D arrival(Vector3D target) {
    Vector3D steer; // The steering vector
    Vector3D desired = Vector3D.sub(target, pos); // A vector pointing from current location to the target
    float distance = desired.mag2(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (distance > 0) {
      desired.normalize(); // Normalize desired

      if (distance < ARadius) desired.mult(maxspeed*(distance/ARadius)); // This damping is somewhat arbitrary
      else desired.mult(maxforce);

      steer = Vector3D.sub(desired, vel); // Steering = Desired minus Velocity
    }
    else {
      steer = new Vector3D();
    }
    return steer;
  }

  Vector3D departure(Vector3D target) {
    Vector3D steer; // The steering vector
    Vector3D desired = Vector3D.sub(target, pos); // A vector pointing from current location to the target
    float distance = desired.mag2(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (distance > 0 && distance < ARadius*100) {
      desired.normalize(); // Normalize desired

      if (distance < ARadius) desired.mult(maxspeed*(ARadius/distance)); // This damping is somewhat arbitrary
      else desired.mult(maxforce);

      steer = Vector3D.sub(vel, desired); // Steering = Desired minus Velocity
    }
    else {
      steer = new Vector3D();
    }
    return steer;
  }
  
  Vector3D pursue(ArrayList boids) {
    Vector3D steer = new Vector3D();
    if (prey < boids.size()) {
      Agent boid = (Agent) boids.get(prey);
      steer = Vector3D.sub(boid.pos, pos);
      steer.mult(maxpursue);
    }
    return steer;
  }
  
  Vector3D evade(ArrayList predators) {
    Vector3D steer = new Vector3D();
    for (int i = 0; i < predators.size(); i++) {
      Agent predator = (Agent) predators.get(i);
      float distance = Vector3D.dist2(pos, predator.pos);
      if (distance < ERadius*ERadius) {
        action = 1;
        steer = flee(predator.pos);
        steer.mult(maxevade);
        return steer;
      }
    }
    action = 0;
    return steer;
  }

  Vector3D wander() {
    wdelta += random(-NRadius, NRadius); // Determine noise ratio
    // Calculate the new location to steer towards on the wander circle
    Vector3D center = vel.get(); // Get center of wander circle
    center.mult(60.0); // Multiply by distance
    center.add(pos); // Make it relative to boid's location
    // Apply offset to get new target    
    Vector3D offset = new Vector3D(WRadius*cos(wdelta), WRadius*sin(wdelta));
    Vector3D target = Vector3D.add(center, offset); // Determine new target
    // Steer toward new target    
    Vector3D steer = seek(target); // Steer towards it    
    return steer;
  }
  
  Vector3D avoid(ArrayList objs) {
    Vector3D steer  = new Vector3D();    

    for (int i = 0; i < objs.size(); i++) {
      Obj obj = (Obj) objs.get(i);
      // Distance between object and avoidance sphere
      float distance = Vector3D.dist2(obj.pos, pos);
      // If distance is less than the sum of the two radius, there is collision
      float bound = obj.mass*0.5 + BRadius + ORadius;
      if (distance < bound*bound) {
        wAvo = 10.0;
        wWan = 0.1;
        float collision = (obj.mass + mass)*0.5;
        if (distance < collision*collision) {
          steer = Vector3D.sub(pos, obj.pos);
          steer.mult(maxforce*0.1);
          return steer;
        }
        else {
          float direction = Vector3D.dist2(obj.pos, Vector3D.add(pos, vel));
          // If is heading toward obstacle
          if (direction < distance) {
            // If steering in the verticle direction
            if (abs(vel.x) <= abs(vel.y)) {   
              steer = new Vector3D((pos.x - obj.pos.x), vel.y);
              steer.mult(maxforce*((bound*bound)/distance)*0.001);       
            }
            // If steering in the horizontal direction
            else {
              steer = new Vector3D(vel.x, (pos.y - obj.pos.y));
              steer.mult(maxforce*((bound*bound)/distance)*0.001);  
            }
          }
        }
      }
    }
    return steer;
  }

  Vector3D flocking(ArrayList boids) {
    // Get steering forces
    Vector3D steer = new Vector3D();
    Vector3D coh = new Vector3D(); // Perceived center
    Vector3D sep = new Vector3D(); // Displacement
    Vector3D ali = new Vector3D(); // Perceived velocity
    int count = 0;
    // Agents try to fly towards the centre of mass of neighbouring agents
    // Agents try to keep a small distance away from other objects (including other agents)
    // Agents try to match velocity with near agents
    for (int i = 0; i < boids.size(); i++) {
      Agent boid = (Agent) boids.get(i);
      float distance = Vector3D.dist2(pos, boid.pos);
      // Go through each agents
      if (this != boid && distance < Rn*Rn) {
        coh.add(boid.pos); // Cohesion
        ali.add(boid.vel); // Alignment
        count++;
      }      
      // Separation
      if (this != boid && distance < SDistance) {
        Vector3D diff = Vector3D.sub(boid.pos, pos); // (agent.position - bJ.position)
        diff.normalize();
        distance = (float) Math.sqrt(distance);
        diff.div(distance); // Weighed by distance
        sep.sub(diff); // c = c - (agent.position - bJ.position)
      }
    }
    if (count > 0) {
      // Cohesion - Step towards the center of mass
      coh.div((float)count); // cJ = pc / (N-1)
      coh.sub(pos); // (pcJ - bJ.position)
      coh.mult(CStep); // (pcJ - bJ.position) / 100
    // Alignment - Find average velocity
      ali.div((float)count); // pvJ = pvJ / N-1
      ali.sub(vel); // (pvJ - bJ.velocity)
      ali.mult(AVelocity); // (pvJ - bJ.velocity) / 8
    }
    // Apply weights
    coh.mult(wCoh);
    sep.mult(wSep);
    ali.mult(wAli);
    // Accumulate forces
    steer.add(coh);
    steer.add(sep);
    steer.add(ali);
    // Add speed
    steer.mult(maxspeed);
    return steer;
  }
  
  // Wrap around or bounded 
  void bounding() {
    if (bounded) {
      if (pos.x <= BRadius) vel.x = BRadius - pos.x;
      else if (pos.x >= width - BRadius) vel.x = (width - BRadius) - pos.x;
      if (pos.y <= BRadius) vel.y = BRadius - pos.y;
      else if (pos.y >= height - BRadius) vel.y = (height - BRadius) - pos.y;
    }
    else {
      if (pos.x < -mass) pos.x = width + mass;
      if (pos.y < -mass) pos.y = height + mass;
      if (pos.x > width + mass) pos.x = -mass;
      if (pos.y > height + mass) pos.y = -mass;
    }
  }
  
  void updateweight() {
    wWan = KWander;
    wAvo = KAvoid;
    wFlo = KFlock;
    wCoh = KCohesion;
    wSep = KSeparate;
    wAli = KAlignment;
  }
  
  void render() {   
    if (type == 1) {
      fill(156, 206, 255);
      stroke(16, 16, 222);
      ellipse(pos.x, pos.y, mass, mass);
      Vector3D dir = vel.get();
      dir.normalize();
      line(pos.x, pos.y, pos.x + dir.x*10, pos.y + dir.y*10);
    }
    else if (type == 2) {
      // Draw a triangle rotated in the direction of velocity        
      float theta = vel.heading2D() + radians(90);
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(theta);
      fill(220, 0, 0);
      noStroke();
      beginShape(TRIANGLES);
      vertex(0, -mass);
      vertex(-3, mass);
      vertex(3, mass);
      endShape();
      popMatrix();
    }
    // Debug mode
    if (debug) {
      // Velocity
      stroke(16, 148, 16);
      line(pos.x, pos.y, pos.x + vel.x*4, pos.y + vel.y*4);
      // Steering
      stroke(255, 0, 0);
      line(pos.x, pos.y, pos.x + acc.x*20, pos.y + acc.y*20);
      // Neighborhood radius
      fill(239, 239, 239, 10);
      stroke(132, 132, 132);
      ellipse(pos.x, pos.y, Rn*2, Rn*2);
      fill(100, 100, 100, 30);
      noStroke();
      ellipse(pos.x, pos.y, BRadius*2, BRadius*2);
      stroke(255, 0, 0);
      noFill();
    }
  }
}

class Obj {
  Vector3D pos;
  float mass;
  int type;

  Obj(float px, float py, float m, int t) {
    pos = new Vector3D(px, py);
    mass = m;
    type = t;
  }
}

class World {
  ArrayList boids;
  ArrayList predators;
  ArrayList objs;

  World() {
    initAgents();
    initobjs();
  }

  void initAgents() {
    // Add boids
    boids = new ArrayList();
    for (int i = 0; i < bNum; i++) {
      Agent boid = new Agent(random(width), random(height), 1);
      boids.add(boid);
    }
    // Add predator
    predators = new ArrayList();
    for (int i = 0; i < pNum; i++) {
      Agent predator = new Agent(random(width), random(height), 2);
      predators.add(predator);
    }
  }

  void initobjs() {
    objs = new ArrayList();
    // Add objects
    for (int i = 0; i < oNum; i++) {
      Obj obj = new Obj(random(1, width), random(1, height), random(50, 100), round(random(1, 2)));
      objs.add(obj);
    }
  }

  void run() {
    update();
    render();
  }

  void update() {
    // Update agents
    for (int i = 0; i < boids.size(); i++) {
      Agent boid = (Agent) boids.get(i);
      boid.run(boids, predators, objs);
    }
    for (int i = 0; i < predators.size(); i++) {
      Agent predator = (Agent) predators.get(i);
      predator.run(boids, predators, objs);
    }
  }

  void render() {
    // Render objects
    for (int i = 0; i < objs.size(); i++) {
      Obj obj = (Obj) objs.get(i);

      if (obj.type == 1) {
        fill(200, 180, 160);
        stroke(50, 30, 20);
        ellipse(obj.pos.x, obj.pos.y, obj.mass, obj.mass);
      }
      else if (obj.type == 2) {
        fill(120, 190, 150);
        stroke(80, 70, 40);
        ellipse(obj.pos.x, obj.pos.y, obj.mass, obj.mass);
      }
      // Debug mode
      if (debug) {
        // Neighborhood radius
        fill(100, 100, 100, 30);
        noStroke();
        ellipse(obj.pos.x, obj.pos.y, obj.mass + ORadius*2, obj.mass + ORadius*2);
      }
    }
    // Render info
    if (info) {
      fill(0);
      text("FPS: " + frameRate, 15, 20);
      text("Boids: " + (world.boids.size()), 15, 35);
      text("Predators: " + (world.predators.size()), 15, 50);
      text("Objects: " + (world.objs.size()), 15, 65);
    }
  }
}

static class Vector3D {
  float x; float y; float z;

  Vector3D(float x_, float y_, float z_) { x = x_; y = y_; z = z_; }
  Vector3D(float x_, float y_) { x = x_; y = y_; z = 0.0; }
  Vector3D() { x = 0.0; y = 0.0; z = 0.0; }
  void setX(float x_) { x = x_; }
  void setY(float y_) { y = y_; }
  void setZ(float z_) { z = z_; }
  void setXY(float x_, float y_) { x = x_; y = y_; }
  void setXYZ(float x_, float y_, float z_) { x = x_; y = y_; z = z_; }
  void setXYZ(Vector3D v) { x = v.x; y = v.y; z = v.z; }
  Vector3D get() { return new Vector3D(x, y, z); }
  void add(Vector3D v) { x += v.x; y += v.y; z += v.z; }
  void sub(Vector3D v) { x -= v.x; y -= v.y; z -= v.z; }
  void mult(float n) { x *= n; y *= n; z *= n; }
  void div(float n) { float f = 1/n; x *= f; y *= f; z *= f; }
  float dist(Vector3D v) { return (float) Math.sqrt((x - v.x)*(x - v.x) + (y - v.y)*(y - v.y) + (z - v.z)*(z - v.z)); }
  float dist2(Vector3D v) { return ((x - v.x)*(x - v.x) + (y - v.y)*(y - v.y) + (z - v.z)*(z - v.z)); }
  float dot(Vector3D v) { return x*v.x + y*v.y + z*v.z; }
  Vector3D cross(Vector3D v) { return new Vector3D((y*v.z - z*v.y), (z*v.x - x*v.z), (x*v.y - y*v.x)); }
  float mag() { return (float) Math.sqrt(x*x + y*y + z*z); }
  float mag2() { return (x*x + y*y + z*z); }
  void normalize() { float m = mag(); if (m > 0) { div(m); } }
  void limit(float max) { if (mag() > max) { normalize(); mult(max); } }
  float heading2D() { return -1*((float) Math.atan2(-y, x)); }

  static Vector3D add(Vector3D v1, Vector3D v2) { return new Vector3D(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z); }
  static Vector3D sub(Vector3D v1, Vector3D v2) { return new Vector3D(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z); }
  static Vector3D mult(Vector3D v1, float n) { return new Vector3D(v1.x*n, v1.y*n, v1.z*n); }
  static Vector3D div(Vector3D v1, float n) { float f = 1/n; return new Vector3D(v1.x*f, v1.y*f, v1.z*f); }
  static float dist(Vector3D v1, Vector3D v2) { return (float) Math.sqrt((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) + (v1.z - v2.z)*(v1.z - v2.z)); }
  static float dist2(Vector3D v1, Vector3D v2) { return ((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) + (v1.z - v2.z)*(v1.z - v2.z)); }
  static float dot(Vector3D v1, Vector3D v2) { return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z; }
  static Vector3D cross(Vector3D v1, Vector3D v2) { return new Vector3D((v1.y*v2.z - v1.z*v2.y), (v1.z*v2.x - v1.x*v2.z), (v1.x*v2.y - v1.y*v2.x)); }
}
