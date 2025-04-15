PPlot p = new PPlot();
float scale = 3;

void setup() {
  size(800, 300);
  surface.setTitle("Plotter");
  surface.setResizable(true);

  p.parse("sin1;Sin2");
}

void draw() {
  int offs = 5;
  p.redraw(offs, offs, width-offs*2, height-offs*2, scale);

  if (frameCount % 5 == 0) {
    float[] v = {sin(frameCount / 15.0)*10, cos(frameCount / 10.0)*5};
    p.add(v);
  }
}

void mouseWheel(MouseEvent e) {
  scale -= e.getCount() / 5.0;
  scale = max(scale, 0.05);
}
