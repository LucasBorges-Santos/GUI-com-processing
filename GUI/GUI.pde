import processing.serial.*;

Serial port;

Table table;

Boolean teste = false;

String val;
float valFluxo = 0;
float media = 0;
float mediaMin = 0;
float gastoTotal = 0;

ArrayList<Float> dados = new ArrayList<Float>();
ArrayList<String> datas = new ArrayList<String>();

float valorMaximoGasto = 110;

PFont textFont;

int i = 0;
int x = 0;
float yoff = 0.0; 

float xanterior= 50;
float xLin = 50;

float yanterior= 650;
float yLin;
int h = 0;

int[] rgbLowVazao = {36, 123, 160};
int[] rgbHighVazao = {27, 152, 224};

int[] rgbLowVazaoGasto = {0, 255, 0};
int[] rgbHighVazaoGasto = {255, 255, 0};

PGraphics ajuste;

// fim variaveis ======================================================================================= //

// setup =============================================================================================== //

/*

São as primeiras configurações que
são feitas ao inicializar o sistema

inicializa uma vez

*/
void setup() {
  size(1200, 720);
  background(19, 41, 61);
  
  reset();
  
  // caso o sensor não esteja conectado, você pode testar colocando esse valor como 'true' nas variaveis
  if(!teste){
    
    // conectando com o arduino
    port = new Serial(this, "/dev/ttyUSB0", 9600);
  }
}

// fim setup ============================================================================================ //

// draw ================================================================================================= //

/*

Se repete constantimente enquanto
o programa estiver aberto

*/

void draw() { 
  
  // verificando se esta em teste
  if(!teste){
    
    val = port.readStringUntil('\n');
  } else{
    
    // valor
    val = "10";
  }
  
  // verificar se os dados são nulos
  if(val != null){
    
    // filtrando valores recebidos
    
    /*
    Os valores do sensor, podem vir 
    de forma errada, a função 
    FiltroValorFluxo retira os valores
    que não são validos
    */
    
    
    valFluxo = FiltroValorFluxo(val);
    
    // definindo media
    media = media + valFluxo;
    mediaMin = media / 60;    
      
    // Criando linhas do grafico ======================================================================== //
    yLin = map(mediaMin, 0, 40, 0, height - 120);
    yLin = height - 70 - yLin;
   
   // cria linhas do grafico
    stroke(27,152,224); 
    line(xanterior, yanterior, xLin, yLin);
    
    // define os pontos das linhas anteriores
    xanterior = xLin;
    xLin = xLin + 10;
    yanterior = yLin;

    /*
    
    se as linhas ultrapassarem a 
    area do grafico, ele reseta
    
    */ 
    
    // resetando as linhas
    if(xLin > 650){
      
      xanterior= 50;
      xLin = 50;
      yanterior= 650;
      h = 0;
      
      gastoTotal = gastoTotal + mediaMin;
      
      dados.add(gastoTotal);
      datas.add(data(false));
      
      // limpa a tela
      clear();
    } else{
      
      h++; 
    }  
  }
  
  // ajuste no PGraphics ================================================================================================= //
  
  /*
  
  O PGraphics é usado para atualizar 
  a area fora do grafico, dessa forma,
  não sobrepoe as linhas ja feitas
  
  */
  
  ajuste.beginDraw();
  ajuste.background(19, 41, 61);
  ajuste.endDraw();
  
  // definindo a area que deve ser atualizada
  image(ajuste, 50, 0);
  image(ajuste, 50, 650, 600, 70);
  image(ajuste, 0, 0, 50, 720);
  image(ajuste, 650, 0, 550, 720);
  image(ajuste, 650, 0, 550, 720);
  
  // fim PGraphics ======================================================================================================= //
  
  
  // criando ellipses de medição e botoes ================================================================================ //
  
  EllipseFluxo(valFluxo, rgbLowVazao,  rgbHighVazao, 1100, 150, "Fluxo (L/Min)", 30);
  EllipseFluxo(mediaMin, rgbLowVazao,  rgbHighVazao, 850, 150, "Média (L/Min)", 30);
  EllipseFluxo(gastoTotal, rgbLowVazaoGasto,  rgbHighVazaoGasto, 975, 350, "Gasto total (L/Min)", valorMaximoGasto);
  
  botao(750, 600, color(212, 0, 0), color(144, 0, 0), color(255, 0, 0), "Limpar");
  botao(950, 600, color(0,179,255), color(36,123,160), color(0,179,255), "Salvar Dados");

  
  
  // fim da crianção ellipses de medição e botoes ======================================================================= //
  
  // Gerar Grafico ===================================================================================================== //
  if(h == 0){      
    GerarGrafico();
    media = 0;
    mediaMin = 0;
  }  
  
  text(data(false), 50, 30);
}

// funções ============================================================================================================= //

// função filtro de valor do sensor
public float FiltroValorFluxo(String valor){
  float valorFinal; 
  
  /*
  
  vai tentar converter o valor
  recebido em string para 
  float, se não conseguir
  ele transforma o valor em 0
  
  */
  
  try {
    valorFinal = Float.parseFloat(valor);
  } catch(Exception e){
    valorFinal = 0;
  }
  
  // retornar valor
  return valorFinal;
}


// criando ellipse de fluxo

/*

EllipseFluxo(float valFl, int[] rgbLow, int[] rgbHigh, int x, int y, String titulo, float valMax);

valFl = valor que será mostrado na ellipse
rgbLow = cor original da ellipse
rgbHigh = cor que a ellipse terá no seu valor maximo
x = localização em x
y = localização em y
titulo = titulo do grafico
valMax = valor maximo

*/

void EllipseFluxo(float valFl, int[] rgbLow, int[] rgbHigh, int x, int y, String titulo, float valMax){
  // definindo cores
  float r = map(valFl, 0, valMax, rgbLow[0], rgbHigh[0]);
  if(r > rgbHigh[0]){
    r = rgbHigh[0];
  }
  
  float g = map(valFl, 0, valMax, rgbLow[1], rgbHigh[1]);
  if(g > rgbHigh[1]){
    g = rgbHigh[1];
  }
  
  float b = map(valFl, 0, valMax, rgbLow[2], rgbHigh[2]);
  if(b > rgbHigh[2]){
    b = rgbHigh[2];
  }
  
  // definindo diametro do circulo
  float d = map(valFl, 0, valMax, 80, 200);
  
  // diametro maximo
  if(d > 200){
    d = 200;
  }
  
  // definindo valor de segurança para o fluxo de agua
  
  /*
  
  caso o valor ultrapasse 30 L/Min, 
  a cor se torna vermelha como um alerta
  
  */
  
  if(valFl > valMax){
    fill(255, 0, 0);
  } else{
    fill(r, g, b);
  }
  
  // criando ellipse
  ellipse(x - 50, y, d, d);
  
  // desenhando o valor da ellipse em seu centro
  textFont = loadFont("Consolas-Bold-25.vlw");
  textFont(textFont);
  
  fill(255);
  if (valFl < 10){
    text(nf(valFl, 0, 2), x - 75, y + 10);
  } else {
    text(nf(valFl, 0, 2), x- 75 - 7, y + 10);
  }
  
  // definindo o titulo do grafico
  textFont = loadFont("Consolas-Bold-14.vlw");
  textFont(textFont);
  
  text(titulo, x - 50 - textWidth(titulo)/2, (d/2) + y + 20);
}

// gerar grafico 
void GerarGrafico(){
  // area do grafico
  fill(232, 241, 242);
  square(50, 50, height - 120);
  
  // linhas verticais
  for (int z = 0; z<= 8; z++){
    if(z == 6){
      stroke(255, 0, 0);
    } else{
      stroke(100, 100, 100);
    }
    line(51, height - 70 - (75 * z), 650, height - 70 - (75 * z));
  
    textFont = loadFont("Consolas-Bold-14.vlw");
    textFont(textFont);
    
    // valores no grafico de 5 em 5
    if ( z != 0 && z != 8 ){
      fill(0);
      text(5 * z, 55, height - 75 - (75 * z) );
    } 
  }
  
  // linhas horizontais
  for (int t = 0; t <= 60; t++){
    stroke(0);
    line(50 + (10 * t), height - 70, 50 + (10 * t), height - 80); 
  }
  
  // definindo tipos de valores
  fill(0);
  text("L/Min", 55, 65);
  text("s", 637, height - 85);
}

// gerar botoes

/*

Funções responsaveis pelo
funcionamento dos botoes

*/

void mousePressed() {
  /*
  
  checa se o mouse esta na area
  do botao
  
  */
  
  if (overRect (750, 600)) { // limpar
    /*
    
    reseta as principais variaveis 
    e recomeçando o programa
    
    */
  
    reset();
  }
  
  if (overRect (950, 600)) { // salvando dados  
    /*
  
    Criando arquivo csv com
    os dados que foram pegos 
    no tempo em que o programa
    esta rodando
  
    */
  
    table = new Table();
    table.addColumn("data");
    table.addColumn("fluxo");
    
    /*
    
    percorrendo os dados salvos
    nos ArrayList
    
    */
    
    for(int r = 0; r <= dados.size() - 1; r++){
      TableRow newRow = table.addRow();
      newRow.setString("data", datas.get(r));
      newRow.setFloat("fluxo", dados.get(r));
    }
    saveTable(table, "dados/" + data(true) + ".csv"); // salvando
    reset(); // resetando
  }
}

boolean overRect (int x, int y){
  /*
  
  checa se o mouse esta na area
  do botao
  
  retorna true se verdadeiro
  */
  if (mouseX >= x && mouseX <= x + 150 && mouseY >= y && mouseY <= y+50) {
    return true;
  } else {
    return false;
  }
}

void botao(int x, int y, color overOff, color overOnn, color borda, String titulo){  
  /*
  
  x = localização em x
  y = localização em y
  overOff = cor primaria
  overOnn = cor quando o mouse esta sobre o botao
  borda = borda do botao
  titulo = titulo do botao
  
  */
  
  if ( overRect(x, y) ) {
    fill(overOnn);
  } else {
    fill(overOff);
  }
  
  /*
  
  se o mouse estiver na area 
  do botao, ele altera a cor do
  quadrado pelo "fill"
  
  */
  
  stroke(borda);
  rect(x, y, 150, 50);
  
  fill(255);
  text(titulo, x + 75 - textWidth(titulo)/2, y + 30);
}

void reset(){
  valFluxo = 0;
  media = 0;
  mediaMin = 0;
  gastoTotal = 0;
  i = 0;
  x = 0;
  yoff = 0.0; 
  xanterior= 50;
  xLin = 50;
  yanterior= 650;
  h = 0;
  dados.clear(); // limpando dados
  datas.clear(); // limpando datas
  
  background(19, 41, 61);
  GerarGrafico();
  ajuste = createGraphics(600, 50);
}

String data(boolean save){
  /*
  
  Função para pegar a data do sistema
  
  save = true -> condiciona a data para nome de arquivo
  
  */
  
  
  
  int dia = day();
  int mes = month();
  int ano = year();
  int segundos = second();  // Values from 0 - 59
  int minutos = minute();  // Values from 0 - 59
  int hora = hour();
  
  if (save){
    return dia + "_" + mes + "_" + ano + " " + hora + "_" + minutos + "_" + segundos;
  } else{
    return dia + "/" + mes + "/" + ano + " " + hora + ":" + minutos + ":" + segundos;
  }
}
