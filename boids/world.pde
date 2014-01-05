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
