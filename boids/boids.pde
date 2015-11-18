import controlP5.*;

/* Steering Behaviors
   http://www.futuredatalab.com/steeringbehaviors/
   
   Compatible with Processing 3.0.1 and ControlP5 2.2.5 */
   
// Global variables
World world;
ControlP5 cp5;

// Setup the Processing Canvas
void setup() {
  size(800, 600);
  world = new World();
  controlUI();
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
    cp5.getController("Bound").setValue((bounded) ? 1 : 0);
    redraw();
  }
  // Debug mode
  if (key == 'd') {
    debug = !debug;
    cp5.getController("Debug").setValue((debug) ? 1 : 0);
    redraw();
  }
  // Reset
  if (key == ' ') {
    world = new World();
    redraw();
  }
}

void mousePressed() {
  mouseAction(); // Add/Delete one by one
}

void mouseDragged() {
  mouseAction(); // Add/Delete multiple
}

void mouseAction() {
  if (keyPressed) {
    if (mouseButton == LEFT) {
      // Add boid
      if (key == 'z' && bNum < 500) {
        Agent boid = new Agent(mouseX, mouseY, 1);
        world.boids.add(boid);
        bNum = world.boids.size();
        cp5.getController("Boid Num").setValue(bNum);
      }
      else if (key == 'x' && pNum < 200) {
        Agent predator = new Agent(mouseX, mouseY, 2);
        world.predators.add(predator);
        pNum = world.predators.size();
        cp5.getController("Predator Num").setValue(pNum);
      }
      else if (key == 'c' && oNum < 50) {
        Obj obj = new Obj(mouseX, mouseY, random(50, 100), round(random(1, 2)));
        world.objs.add(obj);
        oNum = world.objs.size();
        cp5.getController("Object Num").setValue(oNum);
      }
    }
    if (mouseButton == RIGHT) {
      // Remove boid
      if (key == 'z') {
        if (world.boids.size() > 0) {
          world.boids.remove(0);
          bNum = world.boids.size();
          cp5.getController("Boid Num").setValue(bNum);
        }
      }
      // Remove predator
      else if (key == 'x') {
        if (world.predators.size() > 0) {
          world.predators.remove(0);
          pNum = world.predators.size();
          cp5.getController("Predator Num").setValue(pNum);
        }
      }
      // Remove object
      else if (key == 'c') {
        if (world.objs.size() > 0) {
          world.objs.remove(0);
          oNum = world.objs.size();
          cp5.getController("Object Num").setValue(oNum);
        }
      }
    }
  }
}