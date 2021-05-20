import processing.serial.*;

Serial port;

Boolean teste = false;

String val;
float filtro;
float valFluxo;
float media = 0;
float mediaMin = 0;

PFont textFont;
int[] rgbLowVazao = {36, 123, 160};
int[] rgbHighVazao = {27, 152, 224};

int i = 0;
int x = 0;
float yoff = 0.0; 

float xanterior= 50;
float xLin = 50;

float yanterior= 650;
float yLin;
int h = 0;

PGraphics ajuste;

void setup() {
  size(1200, 720);
  background(19, 41, 61);
  
  ajuste = createGraphics(600, 50);
  
  if(!teste){
    port = new Serial(this, "COM4", 9600);
  }
}

void draw() { 
  if(!teste){
    val = port.readStringUntil('\n');
    
    if(val != null){
      valFluxo = FiltroValorFluxo(val);
      
      println(valFluxo);
      yLin = map(valFluxo, 0, 40, 0, height - 120);
    
      yLin = height - 70 - yLin;
   
      stroke(27,152,224); 
      line(xanterior, yanterior, xLin, yLin);
    
      xanterior = xLin;
    
      xLin = xLin + 10;
    
      yanterior = yLin;

      if(xLin > 650){
        xanterior= 50;
        xLin = 50;

        yanterior= 650;
      
        h = 0;
      
        clear();
      } else{
        h++;
      }  
    }
  } else{
    valFluxo = 30;
  }
  
  // ajuste no PGraphics =================================================================================================    
  ajuste.beginDraw();
  ajuste.background(19, 41, 61);
  ajuste.endDraw();
  
  image(ajuste, 50, 0);
  image(ajuste, 50, 650, 600, 70);
  image(ajuste, 0, 0, 50, 720);
  image(ajuste, 650, 0, 550, 720);
  image(ajuste, 650, 0, 550, 720);
  // fim PGraphics =======================================================================================================
  
  EllipseFluxo(valFluxo, rgbLowVazao,  rgbHighVazao, 1100, 150, "Fluxo (L/Min)");
  EllipseFluxo(mediaMin, rgbLowVazao,  rgbHighVazao, 875, 150, "Média (L/Min)");
  
  if( i == 60 ){
    media = media + valFluxo;
    x++;
    
    if(x == 60){
      media = media / 60;
      
      mediaMin = media;
      
      media = 0;
      x = 0;
    }
    
    i = 0;
  } else{
    i++;
  } 
  
  // Gerar Grafico ==================================================================================================
  if(h == 0){      
    
    /*
    
    Problemas encontrados
    
    por conta da forma como a interface é feita,
    conforme os primeiros dados do sensor de fluxo vão aparecendo
    o background e os outros sistemas de visualizações sobrepoem o grafico.
    
    estudar pgrafics para a correção
    
    
    */
    fill(232, 241, 242);
    square(50, 50, height - 120);
  
    for (int z = 0; z<= 8; z++){
      stroke(100, 100, 100);
      line(50, height - 70 - (75 * z), 650, height - 70 - (75 * z));
    
      textFont = loadFont("Consolas-Bold-14.vlw");
      textFont(textFont);
    
      if ( z != 0 && z != 8 ){
        fill(0);
        text(5 * z, 55, height - 75 - (75 * z) );
      } 
    }
  
    for (int t = 0; t <= 60; t++){
      stroke(0);
      line(50 + (10 * t), height - 70, 50 + (10 * t), height - 80); 
    }
  
    fill(0);
    text("L/Min", 55, 65);
    text("s", 637, height - 85);
  }  
}

// funções ============================================================================================================

public float FiltroValorFluxo(String valor){
  float valorFinal; 
  
  try {
    valorFinal = Float.parseFloat(valor);
  } catch(Exception e){
    valorFinal = 0;
  }
  
  return valorFinal;
}

//width - 157 - textWidth(Float.toString(valFluxo))/2
//27
//35

void EllipseFluxo(float valFl, int[] rgbLow, int[] rgbHigh, int x, int y, String titulo){
  float r = map(valFl, 0, 40, rgbLow[0], rgbHigh[0]);
  float g = map(valFl, 0, 40, rgbLow[1], rgbHigh[1]);
  float b = map(valFl, 0, 40, rgbLow[2], rgbHigh[2]);
  
  float d = map(valFl, 0, 40, 80, 200);
  
  if(d > 200){
    d = 200;
  }
  
  fill(r, g, b);
  ellipse(x - 50, 150, d, d);
  
  
  textFont = loadFont("Consolas-Bold-25.vlw");
  textFont(textFont);
  
  fill(255);
  if (valFl < 10){
    text(nf(valFl, 0, 2), x - 75, y + 10);
  } else {
    text(nf(valFl, 0, 2), x- 75 - 7, y + 10);
  }
  
  
  textFont = loadFont("Consolas-Bold-14.vlw");
  textFont(textFont);
  
  float t = map(valFl,0 , 40,40, 100);
  
  if (t > 100){
    t = 100;
  }
  
  text(titulo, x - 50 - textWidth(titulo)/2, t + y + 20);
}

void FundoAnimado(){
  fill(12, 25, 38);
  // We are going to draw a polygon out of the wave points
  beginShape(); 
  
  float xoff = 0;       // Option #1: 2D Noise
  // float xoff = yoff; // Option #2: 1D Noise
  
  // Iterate over horizontal pixels
  for (float x = 0; x <= width; x += 10) {
    // Calculate a y value according to noise, map to 
    float y = map(noise(xoff, yoff), 0, 1, 200,300); // Option #1: 2D Noise
    // float y = map(noise(xoff), 0, 1, 200,300);    // Option #2: 1D Noise
    
    // Set the vertex
    vertex(x, y); 
    // Increment x dimension for noise
    xoff += 0.05;
  }
  // increment y dimension for noise
  yoff += 0.01;
  vertex(width, height);
  vertex(0, height);
  endShape(CLOSE);
}

void GerarGrafico(float valFlu){
  float xanterior= 50;
  float x = 50;

  float yanterior= 650;
  float y;

  int i = 0;
  
  if(i == 0){
    PFont textFont;
  
    fill(232, 241, 242);
    square(50, 50, height - 120);
  
    for (int z = 0; z<= 8; z++){
      stroke(100, 100, 100);
      line(50, height - 70 - (75 * z), 650, height - 70 - (75 * z));
    
      textFont = loadFont("Consolas-Bold-14.vlw");
      textFont(textFont);
    
      if ( z != 0 && z != 8 ){
        fill(0, 100, 148);
        text(5 * z, 55, height - 75 - (75 * z) );
      } 
    }
  
    for (int t = 0; t <= 60; t++){
      stroke(100, 100, 100);
      line(50 + (10 * t), height - 70, 50 + (10 * t), height - 80); 
    }
  
    fill(0, 100, 148);
    text("L/Min", 55, 65);
    text("s", 637, height - 85);
  }
  
  i++;
   
  y=map(valFlu, 0, 40, 0, height - 120);
    
  y= height - 70 - y;
   
  stroke(0); 
  line(xanterior, yanterior, x, y);
    
  xanterior = x;
    
  x = x + 10;
    
  yanterior = y;

  if(x > 650){
    xanterior = 0;
    x = 0;
      
    yanterior = 0;
    y = 0;
      
    i = 0;
      
    clear();
  }
}
