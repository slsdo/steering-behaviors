class Obj {
  PVector pos;
  float mass;
  int type;

  Obj(float px, float py, float m, int t) {
    pos = new PVector(px, py);
    mass = m;
    type = t;
  }
}
