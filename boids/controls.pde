// World
public int bNum = 40;
public int pNum = 2;
public int oNum = 5;

// Canvas
public boolean info = false; // Display information
public boolean bounded = true; // Bounded within world
public boolean debug = false; // Display viewing fields and more

// Agent
public float Rn = 80.0; // R neighborhood
public float maxspeed = 5.0; // Maximum speed
public float maxforce = 3.0; // Maximum steering force
public float maxpursue = 20.0; // Maximum steering force
public float maxevade = 10.0; // Maximum steering force

// Steering
public float ARadius = 100.0; // Arrival: max distance at which the agent may begin to slow down
public float ERadius = 50.0; // Evade: radius of evade range
public float WRadius = 40.0; // Wander: radius of wandering circle
public float NRadius = 0.3; // Wander: radius of wander noise circle
public float BRadius = 20.0; // Avoid: radius of agent bounding sphere
public float ORadius = 20.0; // Avoid: radius of object bounding sphere
public float CStep = 1.0/100.0; // Cohesion: move it #% of the way towards the center
public float SDistance = 80.0f; // Separation: small separation distance
public float AVelocity = 1.0/8.0; // Alignment: add a small portion to the velocity

// Weights
public float KArrive = 1.0;
public float KDepart = 1.0;
public float KPursue = 1.0;
public float KEvade = 1.0;
public float KWander = 1.0;
public float KAvoid = 5.0;
public float KFlock = 1.0;
public float KCohesion = 1.0;
public float KSeparate = 2.0;
public float KAlignment = 1.0;

void controlUI() {
  // Position offsets
  int xoffset = 10;
  int yoffset = 15;
  int canvasoffset = 10;
  int worldoffset = 60;
  int agentoffset = 130;
  int steeroffset = 230;
  int flockoffset = 345;
  int weightoffset = 415;
  
  cp5 = new ControlP5(this);
  // Group menu items
  ControlGroup ui = cp5.addGroup("Settings").setPosition(585, 10).setWidth(215);
  ui.setBackgroundColor(color(0, 200));
  ui.setBackgroundHeight(590);
  ui.mousePressed(); // Menu is hidden by default
  // Increment/decrement stuff in the world  
  Textlabel textWorld = cp5.addTextlabel("World").setText("World").setPosition(xoffset, worldoffset);
  textWorld.setColorValue(color(200));
  Slider sliderBoid = cp5.addSlider("Boid Num").setRange(0, 500).setValue(bNum).setPosition(xoffset, worldoffset + yoffset*1).setSize(100, 10);
  Slider sliderPredator = cp5.addSlider("Predator Num").setRange(0, 100).setValue(pNum).setPosition(xoffset, worldoffset + yoffset*2).setSize(100, 10);
  Slider sliderObject = cp5.addSlider("Object Num").setRange(0, 50).setValue(oNum).setPosition(xoffset, worldoffset + yoffset*3).setSize(100, 10);
  // Canvas settings and more
  Textlabel textCanvas = cp5.addTextlabel("Canvas").setText("Canvas Options").setPosition(xoffset, canvasoffset);
  textCanvas.setColorValue(color(200));
  Toggle toggleInfo = cp5.addToggle("Info").setValue(info).setPosition(xoffset + 0, canvasoffset + yoffset*1).setSize(10, 10);
  Toggle toggleBound = cp5.addToggle("Bound").setValue(bounded).setPosition(xoffset + 45, canvasoffset + yoffset*1).setSize(10, 10);
  Toggle toggleDebug = cp5.addToggle("Debug").setValue(debug).setPosition(xoffset + 90, canvasoffset + yoffset*1).setSize(10, 10);
  Button buttonDefault = cp5.addButton("Default").setValue(0).setPosition(xoffset + 135, canvasoffset + yoffset*1).setSize(45, 10);
  Button buttonReset = cp5.addButton("Reset").setValue(0).setPosition(xoffset + 135, canvasoffset + yoffset*2).setSize(45, 10);
  // Speed variables
  Textlabel textAgent = cp5.addTextlabel("Agent").setText("Agent").setPosition(xoffset, agentoffset);
  textAgent.setColorValue(color(200));
  Slider sliderRn = cp5.addSlider("Neighborhood").setRange(1, 200).setValue(Rn).setPosition(xoffset, agentoffset + yoffset*1).setSize(100, 10);
  Slider sliderMaxSpeed = cp5.addSlider("Max Speed").setRange(1, 10).setValue(maxspeed).setPosition(xoffset, agentoffset + yoffset*2).setSize(100, 10);
  Slider sliderMaxForce = cp5.addSlider("Max Force").setRange(1, 10).setValue(maxforce).setPosition(xoffset, agentoffset + yoffset*3).setSize(100, 10);
  Slider sliderMaxPursue = cp5.addSlider("Pursue Speed").setRange(1, 20).setValue(maxpursue).setPosition(xoffset, agentoffset + yoffset*4).setSize(100, 10);
  Slider sliderMaxEvade = cp5.addSlider("Evade Speed").setRange(1, 20).setValue(maxevade).setPosition(xoffset, agentoffset + yoffset*5).setSize(100, 10);
  // Steering variables
  Textlabel textSteer = cp5.addTextlabel("Steering").setText("Steering").setPosition(xoffset, steeroffset);
  textSteer.setColorValue(color(200));
  Slider sliderARadius = cp5.addSlider("Arrival Departure").setRange(1, 200).setValue(ARadius).setPosition(xoffset, steeroffset + yoffset*1).setSize(100, 10);
  Slider sliderERadius = cp5.addSlider("Evasion").setRange(1, 200).setValue(ERadius).setPosition(xoffset, steeroffset + yoffset*2).setSize(100, 10);
  Slider sliderWRadius = cp5.addSlider("Wandering").setRange(1, 200).setValue(WRadius).setPosition(xoffset, steeroffset + yoffset*3).setSize(100, 10);
  Slider sliderNRadius = cp5.addSlider("Wandering Noise").setRange(0.1, 1).setValue(NRadius).setPosition(xoffset, steeroffset + yoffset*4).setSize(100, 10);
  Slider sliderBRadius = cp5.addSlider("Agent Avoidance").setRange(1, 200).setValue(BRadius).setPosition(xoffset, steeroffset + yoffset*5).setSize(100, 10);
  Slider sliderORadius = cp5.addSlider("Object Avoidance").setRange(1, 200).setValue(ORadius).setPosition(xoffset, steeroffset + yoffset*6).setSize(100, 10);
  // Flocking variables
  Textlabel textFlock = cp5.addTextlabel("Flocking").setText("Flocking").setPosition(xoffset, flockoffset);
  textFlock.setColorValue(color(200));
  Slider sliderCStep = cp5.addSlider("Cohesion Step").setRange(0.01, 0.1).setValue(CStep).setPosition(xoffset, flockoffset + yoffset*1).setSize(100, 10);
  Slider sliderSDistance = cp5.addSlider("Separation Distance").setRange(1, 200).setValue(SDistance).setPosition(xoffset, flockoffset + yoffset*2).setSize(100, 10);
  Slider sliderAVelocity = cp5.addSlider("Alignment Velocity").setRange(0.01, 0.5).setValue(AVelocity).setPosition(xoffset, flockoffset + yoffset*3).setSize(100, 10);
  // Weight constants
  Textlabel textWeight = cp5.addTextlabel("Weights").setText("Weights").setPosition(xoffset, weightoffset);
  textWeight.setColorValue(color(200));
  Slider sliderKArrive = cp5.addSlider("Arrive").setRange(1, 10).setValue(KArrive).setPosition(xoffset, weightoffset + yoffset*1).setSize(100, 10);
  Slider sliderKDepart = cp5.addSlider("Depart").setRange(1, 10).setValue(KDepart).setPosition(xoffset, weightoffset + yoffset*2).setSize(100, 10);
  Slider sliderKPursue = cp5.addSlider("Pursue").setRange(1, 10).setValue(KPursue).setPosition(xoffset, weightoffset + yoffset*3).setSize(100, 10);
  Slider sliderKEvade = cp5.addSlider("Evade").setRange(1, 10).setValue(KEvade).setPosition(xoffset, weightoffset + yoffset*4).setSize(100, 10);
  Slider sliderKWander = cp5.addSlider("Wander").setRange(1, 10).setValue(KWander).setPosition(xoffset, weightoffset + yoffset*5).setSize(100, 10);
  Slider sliderKAvoid = cp5.addSlider("Avoid").setRange(1, 10).setValue(KAvoid).setPosition(xoffset, weightoffset + yoffset*6).setSize(100, 10);
  Slider sliderKFlock = cp5.addSlider("Flock").setRange(1, 10).setValue(KFlock).setPosition(xoffset, weightoffset + yoffset*7).setSize(100, 10);
  Slider sliderKCohesion = cp5.addSlider("Cohesion").setRange(1, 10).setValue(KCohesion).setPosition(xoffset, weightoffset + yoffset*8).setSize(100, 10);
  Slider sliderKSeparate = cp5.addSlider("Separate").setRange(1, 10).setValue(KSeparate).setPosition(xoffset, weightoffset + yoffset*9).setSize(100, 10);
  Slider sliderKAlignment = cp5.addSlider("Alignment").setRange(1, 10).setValue(KAlignment).setPosition(xoffset, weightoffset + yoffset*10).setSize(100, 10);
  // Assign ID to all menu items
  sliderBoid.setId(1);
  sliderPredator.setId(2);
  sliderObject.setId(3);
  toggleInfo.setId(4);
  toggleBound.setId(5);
  toggleDebug.setId(6);
  buttonDefault.setId(7);
  buttonReset.setId(8);
  sliderRn.setId(9);
  sliderMaxSpeed.setId(10);
  sliderMaxForce.setId(11);
  sliderMaxPursue.setId(12);
  sliderMaxEvade.setId(13);
  sliderARadius.setId(14);
  sliderERadius.setId(15);
  sliderWRadius.setId(16);
  sliderNRadius.setId(17);
  sliderBRadius.setId(18);
  sliderORadius.setId(19);
  sliderCStep.setId(20);
  sliderSDistance.setId(21);
  sliderAVelocity.setId(22);
  sliderKArrive.setId(23);
  sliderKDepart.setId(24);
  sliderKPursue.setId(25);
  sliderKEvade.setId(26);
  sliderKWander.setId(27);
  sliderKAvoid.setId(28);
  sliderKFlock.setId(29);
  sliderKCohesion.setId(30);
  sliderKSeparate.setId(31);
  sliderKAlignment.setId(32);  
  // Add all menu items to the UI group
  textWorld.setGroup(ui);
  sliderBoid.setGroup(ui);
  sliderPredator.setGroup(ui);
  sliderObject.setGroup(ui);  
  textCanvas.setGroup(ui);
  toggleInfo.setGroup(ui);
  toggleBound.setGroup(ui);
  toggleDebug.setGroup(ui);
  buttonDefault.setGroup(ui);
  buttonReset.setGroup(ui);  
  textAgent.setGroup(ui);
  sliderRn.setGroup(ui);
  sliderMaxSpeed.setGroup(ui);
  sliderMaxForce.setGroup(ui);
  sliderMaxPursue.setGroup(ui);
  sliderMaxEvade.setGroup(ui);  
  textSteer.setGroup(ui);
  sliderARadius.setGroup(ui);
  sliderERadius.setGroup(ui);
  sliderWRadius.setGroup(ui);
  sliderNRadius.setGroup(ui);
  sliderBRadius.setGroup(ui);
  sliderORadius.setGroup(ui);  
  textFlock.setGroup(ui);
  sliderCStep.setGroup(ui);
  sliderSDistance.setGroup(ui);
  sliderAVelocity.setGroup(ui);  
  textWeight.setGroup(ui);
  sliderKArrive.setGroup(ui);
  sliderKDepart.setGroup(ui);
  sliderKPursue.setGroup(ui);
  sliderKEvade.setGroup(ui);
  sliderKWander.setGroup(ui);
  sliderKAvoid.setGroup(ui);
  sliderKFlock.setGroup(ui);
  sliderKCohesion.setGroup(ui);
  sliderKSeparate.setGroup(ui);
  sliderKAlignment.setGroup(ui);
}

// Restore all variables to their default values
void restoreDefault() {
  updateWorld(40, 2, 5);
  cp5.getController("Boid Num").setValue(bNum);
  cp5.getController("Predator Num").setValue(pNum);
  cp5.getController("Object Num").setValue(oNum);
  info = false;
  bounded = true;
  debug = false;
  cp5.getController("Info").setValue((info) ? 1 : 0);
  cp5.getController("Bound").setValue((bounded) ? 1 : 0);
  cp5.getController("Debug").setValue((debug) ? 1 : 0);
  Rn = 80.0;
  maxspeed = 5.0;
  maxforce = 3.0;
  maxpursue = 20.0;
  maxevade = 10.0;
  cp5.getController("Neighborhood").setValue(Rn);
  cp5.getController("Max Speed").setValue(maxspeed);
  cp5.getController("Max Force").setValue(maxforce);
  cp5.getController("Pursue Speed").setValue(maxpursue);
  cp5.getController("Evade Speed").setValue(maxevade);
  ARadius = 100.0;
  ERadius = 50.0;
  WRadius = 40.0;
  NRadius = 0.3;
  BRadius = 20.0;
  ORadius = 20.0;
  CStep = 1.0/100.0;
  SDistance = 80.0f;
  AVelocity = 1.0/8.0;
  cp5.getController("Arrival Departure").setValue(ARadius);
  cp5.getController("Evasion").setValue(ERadius);
  cp5.getController("Wandering").setValue(WRadius);
  cp5.getController("Wandering Noise").setValue(NRadius);
  cp5.getController("Agent Avoidance").setValue(BRadius);
  cp5.getController("Object Avoidance").setValue(ORadius);
  cp5.getController("Cohesion Step").setValue(CStep);
  cp5.getController("Separation Distance").setValue(SDistance);
  cp5.getController("Alignment Velocity").setValue(AVelocity);
  KArrive = 1.0;
  KDepart = 1.0;
  KPursue = 1.0;
  KEvade = 1.0;
  KWander = 1.0;
  KAvoid = 5.0;
  KFlock = 1.0;
  KCohesion = 1.0;
  KSeparate = 2.0;
  KAlignment = 1.0;
  cp5.getController("Arrive").setValue(KArrive);
  cp5.getController("Depart").setValue(KDepart);
  cp5.getController("Pursue").setValue(KPursue);
  cp5.getController("Evade").setValue(KEvade);
  cp5.getController("Wander").setValue(KWander);
  cp5.getController("Avoid").setValue(KAvoid);
  cp5.getController("Flock").setValue(KFlock);
  cp5.getController("Cohesion").setValue(KCohesion);
  cp5.getController("Separate").setValue(KSeparate);
  cp5.getController("Alignment").setValue(KAlignment);
}

// Update the number of agents and objects in the world
void updateWorld(int bn, int pn, int on) {
  if (bn > bNum) {
    bNum = bn;
    while (world.boids.size() < bNum) {
      Agent boid = new Agent(random(width), random(height), 1);
      world.boids.add(boid);
    }
  }
  else if (bn < bNum) {
    bNum = bn;
    while (world.boids.size() >  bNum) {
      world.boids.remove(0);
    }    
  }
  if (pn > pNum) {
    pNum = pn;
    while (world.predators.size() < pNum) {
      Agent predator = new Agent(random(width), random(height), 2);
      world.predators.add(predator);
    }
  }
  else if (pn < pNum) {
    pNum = pn;
    while (world.predators.size() >  pNum) {
      world.predators.remove(0);
    }    
  }
  if (on > oNum) {
    oNum = on;
    while (world.objs.size() < oNum) {
      Obj obj = new Obj(random(1, width), random(1, height), random(50, 100), round(random(1, 2)));
      world.objs.add(obj);
    }
  }
  else if (on < oNum) {
    oNum = on;
    while (world.objs.size() >  oNum) {
      world.objs.remove(0);
    }    
  }
}

// Event handler
void controlEvent(ControlEvent theEvent) {
  switch(theEvent.getController().getId()) {
    case 1: { updateWorld((int)theEvent.getController().getValue(), pNum, oNum); break; }
    case 2: { updateWorld(bNum, (int)theEvent.getController().getValue(), oNum); break; }
    case 3: { updateWorld(bNum, pNum, (int)theEvent.getController().getValue()); break; }
    case 4: { info = (theEvent.getController().getValue() == 1.0) ? true : false; break; }
    case 5: { bounded = (theEvent.getController().getValue() == 1.0) ? true : false; break; }
    case 6: { debug = (theEvent.getController().getValue() == 1.0) ? true : false; break; }
    case 7: { restoreDefault(); break; }
    case 8: { world = new World(); redraw(); break; }
    case 9: { Rn = theEvent.getController().getValue(); break; }
    case 10: { maxspeed = theEvent.getController().getValue(); break; }
    case 11: { maxforce = theEvent.getController().getValue(); break; }
    case 12: { maxpursue = theEvent.getController().getValue(); break; }
    case 13: { maxevade = theEvent.getController().getValue(); break; }
    case 14: { ARadius = theEvent.getController().getValue(); break; }
    case 15: { ERadius = theEvent.getController().getValue(); break; }
    case 16: { WRadius = theEvent.getController().getValue(); break; }
    case 17: { NRadius = theEvent.getController().getValue(); break; }
    case 18: { BRadius = theEvent.getController().getValue(); break; }
    case 19: { ORadius = theEvent.getController().getValue(); break; }
    case 20: { CStep = theEvent.getController().getValue(); break; }
    case 21: { SDistance = theEvent.getController().getValue(); break; }
    case 22: { AVelocity = theEvent.getController().getValue(); break; }
    case 23: { KArrive = theEvent.getController().getValue(); break; }
    case 24: { KDepart = theEvent.getController().getValue(); break; }
    case 25: { KPursue = theEvent.getController().getValue(); break; }
    case 26: { KEvade = theEvent.getController().getValue(); break; }
    case 27: { KWander = theEvent.getController().getValue(); break; }
    case 28: { KAvoid = theEvent.getController().getValue(); break; }
    case 29: { KFlock = theEvent.getController().getValue(); break; }
    case 30: { KCohesion = theEvent.getController().getValue(); break; }
    case 31: { KSeparate = theEvent.getController().getValue(); break; }
    case 32: { KAlignment = theEvent.getController().getValue(); break; }
  }
}