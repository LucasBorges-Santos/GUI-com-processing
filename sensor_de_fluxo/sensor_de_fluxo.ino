int contaPulso; // numero de impulsos

float media = 0;
float vazao;
int i = 0;

void impulso (){
  contaPulso++;
}

void setup() {
  // definindo taxa de transferencia em bits por segundo
  Serial.begin(9600);

  // definindo o pino 2 como entrada
  pinMode(2, INPUT);

  // defindindo interrupção da porta 2 (0 = porta 2, 1 = porta 3)
  // RISING = Ativa quando for HIGH, e ativa a função "impulso".
  attachInterrupt(0, impulso, RISING);

  // assim que o programa começa, ele printa no serial
  // Serial.println("\nInicio\n");
}

void loop() {
  contaPulso = 0; // zera a quantidade de inpulsos por segundo (definido pelo delay(1000))
  
  // desativa a interrupção
  sei();
  
  delay(1000);

  // ativa a interrupção
  cli();

  vazao = contaPulso / 5.5; // converte para L/min
  media = media + vazao;    // acrescenta a vazão obtida em 1 segundo
  i++; 

  // imprime a quantidade de vazão de agua em L/min a cada segundo que passa
  Serial.println(vazao);     // vazão
  // Serial.print(" L/min - ");
  // Serial.print(i);          // quantidade de segundos
  // Serial.println("s");

  /*if( i == 60){
    // imprime a media e inicia uma nova contagem
    media = media / 60;    // media de litros em 60 segundos
    Serial.print("\n Media por minuto = ");
    Serial.print(media);
    Serial.println(" L/min - ");
    media = 0;
    i = 0;
    Serial.print("\nNova contagem\n\n");
  }
}*/
}

// contar impulsos.
