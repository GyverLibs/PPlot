# PPlot
Processing plotter

![image](/plot.png)

```java
// парсить данные:
// - числа, разделённые ';' или ',' - значения осей (передадутся в add)
// - текст, разделённый ';' или ',' - подписи осей
// - текст, начинающийся с '#' - заголовок графика
void parse(String str);

// добавить данные напрямую
void add(float[] data);

// сдвинуть график на 1 единицу
void move();

// отрисовать график. show - принудительно, даже если данные не изменились
void redraw(int x, int y, int w, int h, float scale);   // show = true
void redraw(int x, int y, int w, int h, float scale, boolean show);
```