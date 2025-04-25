class LBUF {
  public void resize(int nsize) {
    if (buf == null) {
      buf = new float[nsize];
    } else {
      if (buf.length == nsize) return;
      if (nsize > buf.length) {
        float[] nbuf = new float[nsize];
        System.arraycopy(buf, 0, nbuf, 0, buf.length);
        buf = nbuf;
      } else {
        if (length > nsize) length = nsize;
      }
    }
  }

  public void add(float val) {
    if (buf == null) resize(1);
    System.arraycopy(buf, 0, buf, 1, min(buf.length - 1, length));
    if (length < buf.length) ++length;
    buf[0] = val;
  }

  public float get(int i) {
    return buf[i];
  }

  public float[] buf = null;
  public int length = 0;
};

class PPlot {
  // парсить данные:
  // - числа, разделённые ';' или ',' - значения осей
  // - текст, разделённый ';' или ',' - подписи осей
  // - текст, начинающийся с '#' - заголовок графика
  public void parse(String str) {
    if (str.startsWith("#")) {
      _title = str.substring(1);
      _upd = true;
      return;
    }

    String[] s = str.split(";|,");
    if (s.length == 0) return;

    char c = s[0].charAt(0);
    if (Character.isDigit(c) || c == '-') {
      float[] arr = new float[s.length];
      for (int i = 0; i < s.length; i++) {
        arr[i] = parseFloat(s[i].trim());
      }
      add(arr);
    } else {
      lbls = s;
    }
    _upd = true;
  }

  // добавить данные напрямую
  public void add(float[] data) {
    if (buf == null || buf.length != data.length) {
      buf = new LBUF[data.length];
      for (int i = 0; i < buf.length; i++) {
        buf[i] = new LBUF();
      }
      if (lbls == null || lbls.length != data.length) {
        lbls = new String[data.length];
        for (int i = 0; i < data.length; i++) {
          lbls[i] = "Line " + i;
        }
      }
    }
    for (int i = 0; i < data.length; i++) {
      buf[i].add(data[i]);
    }
    _upd = true;
  }

  // сдвинуть график на 1 единицу
  public void move() {
    if (buf == null) return;
    float[] arr = new float[buf.length];
    for (int i = 0; i < buf.length; i++) {
      arr[i] = buf[i].get(0);
    }
    add(arr);
  }

  // обновить график
  public void redraw(int x, int y, int w, int h, float scale) {
    redraw(x, y, w, h, scale, true);
  }
  public void redraw(int x, int y, int w, int h, float scale, boolean show) {
    if (buf == null || buf.length == 0 || buf[0].length == 0) return;

    boolean resize = _x != x || _y != y || _w != w || _h != h;
    if (resize) p = createGraphics(w, h);
    if (resize || _s != scale || _upd) {
      _x = x;
      _y = y;
      _w = w;
      _h = h;
      _s = scale;
      _upd = false;
      show = true;

      for (LBUF b : buf) b.resize(round(w / scale));

      int offyt = 20;
      int offyb = 7;
      int offx = 2;
      int tgap = 10;
      int huestep = 151;

      //p = createGraphics(w, h);
      p.beginDraw();

      // window
      p.noStroke();
      p.fill(255);
      p.rect(0, 0, w, h, 3);
      p.colorMode(HSB, 255, 255, 255);

      y = offyt;
      x = offx;
      h -= offyb + offyt;
      w -= offx * 2;

      // minmax
      int maxv = 999999999;
      float max = -maxv, min = maxv;
      for (int i = 0; i < buf[0].length; i++) {
        for (LBUF b : buf) {
          if (b.get(i) > max) max = b.get(i);
          if (b.get(i) < min) min = b.get(i);
        }
      }

      // labels
      if (lbls != null) {
        p.noStroke();
        p.textSize(15);
        p.textAlign(LEFT, BASELINE);
        float lw = 0;
        float tw[] = new float[lbls.length];
        for (int i = 0; i < lbls.length; i++) {
          tw[i] = p.textWidth(lbls[i]);
          lw += tw[i] + tgap;
        }
        int xx = w - (int)lw + tgap;
        for (int i = 0; i < lbls.length; i++) {
          p.fill((i * huestep) % 255, 255, 200);
          p.text(lbls[i], xx, y - 5);
          xx += tw[i] + tgap;
        }
      }

      // title
      if (_title.length() > 0) {
        p.fill(0);
        p.textAlign(CENTER, BASELINE);
        p.text(_title, x + w / 2, y - 5);
      }

      // grid
      int am = round(h / 80);
      float dif = max - min;
      float step = dif / am;
      p.textSize(13);
      p.textAlign(LEFT, BASELINE);
      p.fill(0);
      for (int i = 0; i < am + 1; i++) {
        float v = max - step * i;
        float yy = (min == max) ? (y + h) / 2 : map(max - step * i, min, max, y + h, y);
        p.strokeWeight(0.3);
        p.stroke(100);
        p.line(x, yy, x + w, yy);

        p.noStroke();
        p.text(v, 5, yy - 3);
      }

      // lines
      p.strokeWeight(1.5);

      for (int b = 0; b < buf.length; b++) {
        p.stroke((b * huestep) % 255, 255, 200);

        float px = 0, py = 0;
        for (int i = 0; i < buf[b].length; i++) {
          float xx = x + w - i * scale;
          float yy = (min == max) ? (y + h) / 2 : map(buf[b].get(i), min, max, y + h, y);
          if (xx < x) {
            p.line(px, py, x, yy);
            break;
          }
          if (i > 0) p.line(px, py, xx, yy);
          px = xx;
          py = yy;
        }
      }

      p.endDraw();
    }
    if (show) image(p, _x, _y);
  }

  PGraphics p;
  LBUF[] buf = null;
  String[] lbls = null;
  String _title = "";
  int _x = 0, _y = 0, _w = 0, _h = 0;
  float _s = 0;
  boolean _upd = false;
};
