#ifndef MLP_H
#define MLP_H


#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <math.h>
#include <time.h>
#include <stdlib.h>

using namespace std;

#define PI 3.14159265358979323846
/****************RANDOMIZER************************************************/

/**************************************************************************/
enum TFuncion{Sigmoidal, TangenteH, Umbral, UmbralS, Lineal};

class MLP{
public:
  //First Data
  struct TNeurona{
    double a, u;
    double *w, *dw, delta;
  };
  int C, M, N, L;
  double eta, alfa;
  int epocas;
  double minimal_error, minimal_maximo;

  TNeurona** neuronas;

  double randn_notrig(double mu=0.0, double sigma=1.0) {
  	static bool deviateAvailable=false;	//	flag
  	static double storedDeviate;			//	deviate from previous calculation
  	double polar, rsquared, var1, var2;

  	if (!deviateAvailable) {
  		do {
  			var1=2.0*( double(rand())/double(RAND_MAX) ) - 1.0;
  			var2=2.0*( double(rand())/double(RAND_MAX) ) - 1.0;
  			rsquared=var1*var1+var2*var2;
  		} while ( rsquared>=1.0 || rsquared == 0.0);

  		polar=sqrt(-2.0*log(rsquared)/rsquared);

  		storedDeviate=var1*polar;
  		deviateAvailable=true;

  		return var2*polar*sigma + mu;
  	}
  	else {
  		deviateAvailable=false;
  		return storedDeviate*sigma + mu;
  	}
  }
  double randn_trig(double mu=0.0, double sigma=1.0) {
  	static bool deviateAvailable=false;	//	flag
  	static double storedDeviate;			//	deviate from previous calculation
  	double dist, angle;

  	if (!deviateAvailable) {
  		dist=sqrt( -2.0 * log(double(rand()) / double(RAND_MAX)) );
  		angle=2.0 * PI * (double(rand()) / double(RAND_MAX));

  		storedDeviate=dist*cos(angle);
  		deviateAvailable=true;

  		return dist * sin(angle) * sigma + mu;
  	}

  	else {
  		deviateAvailable=false;
  		return storedDeviate*sigma + mu;
  	}
  }

  // Calcula el error cuadratico medio
  double ErrorC(vector<double> entrada, vector<double> salida){
      double er=0;
      vector<double> y = Activar(entrada);
      for(int i=0; i<L; i++){
          er += pow(( salida[i] - y[i]) ,2);
      }
      return 0.5 * er;
  }
  // Selecciona el tipo de funcion de activacion y la calcula
  double Funcion(double x, TFuncion funcion){
      switch (funcion){
          case Sigmoidal:
              return 1/(1 + exp(-x) );
          case TangenteH:
              return (1 - exp(-x) )/(1 + exp(-x) );
          case Umbral:
              if(x<0){
                  return 0;
              }else{
                  return 1;
              }
          case UmbralS:
              if(x<0){
                  return -1;
              }else{
                  return 1;
              }
          case Lineal:
              return x;
      }
  }
  // Selecciona el tipo de funcion derivada de activacion y la calcula
  double DFuncion(double x, TFuncion funcion){
      switch (funcion){
          case Sigmoidal:
              return Funcion(x,Sigmoidal) * (1 - Funcion(x,Sigmoidal));
          case TangenteH:
              return 2 * Funcion(x,TangenteH) * (1 - Funcion(x,TangenteH));
          case Umbral:
              return 0;
          case UmbralS:
              return 0;
          case Lineal:
              return 1;
      }
  }

  MLP(int c_capas, int m_entradas, int n_neuronas, int l_salidas, double n_alfa = 0.7, double n_eta = 0.05){
    this->C = c_capas; this->M = m_entradas;
    this->N = n_neuronas; this->L = l_salidas;
    this->eta = n_eta; this->alfa = n_alfa;

    this->epocas = 1000;
    this->minimal_error = 0.02;
    this->minimal_maximo = 0.005;

    srand ((unsigned int)time(NULL));
    // Creamos las neuronas de todas las capas
    neuronas = new TNeurona*[C];
    neuronas[0] = new TNeurona[M];
    for(int q=0; q<C-2; q++){
        neuronas[q+1] = new TNeurona[N];
    }
    neuronas[C-1] = new TNeurona[L];

    // Reservamos los pesos de todas las neuronas
    for(int i=0; i<M; i++){
        neuronas[0][i].w = new double[N];
        neuronas[0][i].dw = new double[N];
    }
    for(int q=0; q<C-3; q++){
        for(int i=0; i<N; i++){
            neuronas[q+1][i].w = new double[N];
            neuronas[q+1][i].dw = new double[N];
        }
    }
    for(int i=0; i<N; i++){
        neuronas[C-2][i].w = new double[L];
        neuronas[C-2][i].dw = new double[L];
    }

    // Ponemos los pesos aleatorios y umbrales usando una v.a. gaussiana N(0,10) mod 10
    for(int i=0; i<M; i++){
        for(int j=0; j<N; j++){
            neuronas[0][i].w[j] = fmod(this->randn_notrig(0,5),10);
            neuronas[0][i].dw[j] = 0.0;
        }
        neuronas[0][i].u = fmod(this->randn_notrig(0,5),10);
    }

    for(int q=0; q<C-3; q++){
        for(int i=0; i<N; i++){
            for(int j=0; j<N; j++){
                neuronas[q+1][i].w[j] = fmod(this->randn_notrig(0,5),10);
                neuronas[q+1][i].dw[j] = 0.0;
            }
            neuronas[q+1][i].u = fmod(this->randn_notrig(0,5),10);
        }
    }
    for(int i=0; i<N; i++){
        for(int j=0; j<L; j++){
            neuronas[C-2][i].w[j] = fmod(this->randn_notrig(0,5),10);
            neuronas[C-2][i].dw[j] = 0.0;
        }
        neuronas[C-2][i].u = fmod(this->randn_notrig(0,5),10);
    }

    for(int i=0; i<L; i++){
        neuronas[C-1][i].u = fmod(this->randn_notrig(0,5),10);
    }
  }
  MLP(string sinapsis){
      ifstream entrada(sinapsis.c_str(),ios::in|ios::binary);
      entrada.read(reinterpret_cast<char *>(&C), sizeof(int));
      entrada.read(reinterpret_cast<char *>(&M), sizeof(int));
      entrada.read(reinterpret_cast<char *>(&N), sizeof(int));
      entrada.read(reinterpret_cast<char *>(&L), sizeof(int));
      entrada.read(reinterpret_cast<char *>(&eta), sizeof(double));
      entrada.read(reinterpret_cast<char *>(&alfa), sizeof(double));

      this->epocas = 1000;
      this->minimal_error = 0.02;
      this->minimal_maximo = 0.005;

      // Creamos las neuronas de todas las capas
      neuronas = new TNeurona*[C];
      neuronas[0] = new TNeurona[M];
      for(int q=0; q<C-2; q++){
          neuronas[q+1] = new TNeurona[N];
      }
      neuronas[C-1] = new TNeurona[L];

      // Reservamos los pesos de todas las neuronas
      for(int i=0; i<M; i++){
          neuronas[0][i].w = new double[N];
          neuronas[0][i].dw = new double[N];
      }
      for(int q=0; q<C-3; q++){
          for(int i=0; i<N; i++){
              neuronas[q+1][i].w = new double[N];
              neuronas[q+1][i].dw = new double[N];
          }
      }
      for(int i=0; i<N; i++){
          neuronas[C-2][i].w = new double[L];
          neuronas[C-2][i].dw = new double[L];
      }

      // Cargamos los pesos
      for(int i=0; i<M; i++){
          for(int j=0; j<N; j++){
              entrada.read( reinterpret_cast<char *>(&neuronas[0][i].w[j]),  sizeof(double));
          }
      }

      for(int q=0; q<C-3; q++){
          for(int i=0; i<N; i++){
              for(int j=0; j<N; j++){
                  entrada.read(reinterpret_cast<char *>(&neuronas[q+1][i].w[j]), sizeof(double));
              }
          }
      }
      for(int i=0; i<N; i++){
          for(int j=0; j<L; j++){
              entrada.read(reinterpret_cast<char *>(&neuronas[C-2][i].w[j]), sizeof(double));
          }
      }

      // Cargamos los umbrales
      for(int q=0; q<C-2; q++){
          for(int i=0; i<N; i++){
              entrada.read(reinterpret_cast<char *>(&neuronas[q+1][i].u), sizeof(double));
          }
      }

      for(int i=0; i<L; i++){
          entrada.read(reinterpret_cast<char *>(&neuronas[C-1][i].u), sizeof(double));
      }

      entrada.close();
  }
  ~MLP(){
    this->C = 0; this->M = 0;
    this->N= 0; this->L = 0;
    this->eta = 0; this->alfa = 0;
    this->epocas = 0;
    this->minimal_error = 0.0;
    this->minimal_maximo = 0.0;

    // Borramos los pesos de todas las neuronas
    for(int i=0; i<M; i++){
        delete[] neuronas[0][i].w;
        delete[] neuronas[0][i].dw;
    }
    for(int q=0; q<C-3; q++){
        for(int i=0; i<N; i++){
            delete[] neuronas[q+1][i].w;
            delete[] neuronas[q+1][i].dw;
        }
    }
    for(int i=0; i<N; i++){
        delete[] neuronas[C-2][i].w;
        delete[] neuronas[C-2][i].dw;
    }
    // Borramos las neuronas de todas las capas
    delete[] neuronas;
  }


  // Seleccionamos los parametros de la red
  void SelParametros(int c_capas, int m_entradas, int n_neuronas, int l_salidas, double n_alfa, double n_eta){
      // Inicializamos los valores de la red
      this-> ~MLP();
      C = c_capas;    M = m_entradas;
      N = n_neuronas; L = l_salidas;
      eta = n_eta;     alfa = n_alfa;

      this->epocas = 1000;
      this->minimal_error = 0.02;
      this->minimal_maximo = 0.05;

      srand ((unsigned int)time(NULL));
      // Creamos las neuronas de todas las capas
      neuronas = new TNeurona*[C];
      neuronas[0] = new TNeurona[M];
      for(int q=0; q<C-2; q++){
          neuronas[q+1] = new TNeurona[N];
      }
      neuronas[C-1] = new TNeurona[L];

      // Reservamos los pesos de todas las neuronas
      for(int i=0; i<M; i++){
          neuronas[0][i].w = new double[N];
          neuronas[0][i].dw = new double[N];
      }
      for(int q=0; q<C-3; q++){
          for(int i=0; i<N; i++){
              neuronas[q+1][i].w = new double[N];
              neuronas[q+1][i].dw = new double[N];
          }
      }
      for(int i=0; i<N; i++){
          neuronas[C-2][i].w = new double[L];
          neuronas[C-2][i].dw = new double[L];
      }
      // Ponemos los pesos aleatorios y umbrales usando una v.a. gaussiana N(0,10) mod 10
      for(int i=0; i<M; i++){
          for(int j=0; j<N; j++){
              neuronas[0][i].w[j] = fmod(this->randn_notrig(0,5),10);
              neuronas[0][i].dw[j] = 0.0;
          }
          neuronas[0][i].u = fmod(this->randn_notrig(0,5),10);
      }

      for(int q=0; q<C-3; q++){
          for(int i=0; i<N; i++){
              for(int j=0; j<N; j++){
                  neuronas[q+1][i].w[j] = fmod(this->randn_notrig(0,5),10);
                  neuronas[q+1][i].dw[j] = 0.0;
              }
              neuronas[q+1][i].u = fmod(this->randn_notrig(0,5),10);
          }
      }
      for(int i=0; i<N; i++){
          for(int j=0; j<L; j++){
              neuronas[C-2][i].w[j] = fmod(this->randn_notrig(0,5),10);
              neuronas[C-2][i].dw[j] = 0.0;
          }
          neuronas[C-2][i].u = fmod(this->randn_notrig(0,5),10);
      }
      for(int i=0; i<L; i++){
          neuronas[C-1][i].u = fmod(this->randn_notrig(0,5),10);
      }
  }
  // Activa las neuronas y devuelve la salida
  vector<double> Activar(vector<double> entrada, TFuncion funcion = Sigmoidal){
      double sum = 0.0;
      vector<double> salida;

      // Activaciones de la capa de entrada
      for(int i=0; i<M; i++){
          neuronas[0][i].a = entrada[i];
      }

      // Activaciones de la primera capa oculta
      for(int j=0; j<N; j++){
          for(int i=0; i<M; i++){
              sum += neuronas[0][i].w[j] * neuronas[0][i].a;
          }
          neuronas[1][j].a = Funcion(sum + neuronas[1][j].u, funcion);
          sum = 0.0;

      }

      // Activaciones de las capas ocultas
      for(int q=1; q<C-2; q++){
          for(int i=0; i<N; i++){
              for(int j=0; j<N; j++){
                  sum += neuronas[q][j].w[i] * neuronas[q][j].a;
              }
              neuronas[q+1][i].a = Funcion(sum + neuronas[q+1][i].u, funcion);
              sum = 0.0;
          }
      }

      // Activaciones de la capa de salida
      for(int i=0; i<L; i++){
          for(int j=0; j<N; j++){
              sum += neuronas[C-2][j].w[i] * neuronas[C-2][j].a;
          }
          neuronas[C-1][i].a = Funcion(sum + neuronas[C-1][i].u, funcion);
          sum = 0.0;
          salida.push_back(neuronas[C-1][i].a);
      }
      return salida;

  }
  // Aprendizaje de la red
  void Aprender(vector<double> entrada, vector<double> salida){
      double sum = 0.0, dif = 0.0;
      vector<double> y = Activar(entrada);

      // Delta de la capa de salida
      for(int i=0; i<L; i++){
          neuronas[C-1][i].delta = (salida[i] - y[i]) * y[i] * (1 - y[i]);
      }

      // Delta de la ultima capa oculta a la de salida
      for(int j=0; j<N; j++){
          for(int i=0; i<L; i++){
              sum += neuronas[C-1][i].delta * neuronas[C-2][j].w[i];
          }
          neuronas[C-2][j].delta = neuronas[C-2][j].a * (1 - neuronas[C-2][j].a) * sum;
          sum = 0.0;
      }

      // Delta de la penultima capa oculta hasta la primera capa oculta
      for(int q=C-3; q>0; q--){
          for(int j=0; j<N; j++){
              for(int i=0; i<N; i++){
                  sum += neuronas[q+1][i].delta * neuronas[q][j].w[i];
              }
              neuronas[q][j].delta = neuronas[q][j].a * (1 - neuronas[q][j].a) * sum;
              sum = 0.0;
          }
      }

      // Pesos de la ultima capa oculta a la capa de salida y umbral de la capa de salida
      for(int i=0; i<L; i++){
          for(int j=0; j<N; j++){
              dif = neuronas[C-2][j].w[i] - neuronas[C-2][j].dw[i];
              neuronas[C-2][j].dw[i] = neuronas[C-2][j].w[i];
              neuronas[C-2][j].w[i] += eta * neuronas[C-1][i].delta * neuronas[C-2][j].a - alfa * dif;
              dif = 0.0;
          }
          neuronas[C-1][i].u += eta * neuronas[C-1][i].delta;
      }

      // Pesos de las capas ocultas
      for(int q=1; q<C-2; q++){
          for(int j=0; j<N; j++){
              for(int i=0; i<N; i++){
                  dif = neuronas[q][i].w[j] - neuronas[q][i].w[j];
                  neuronas[q][i].dw[j] = neuronas[q][i].w[j];
                  neuronas[q][i].w[j] += eta * neuronas[q+1][i].delta * neuronas[q+1][i].a - alfa * dif;
                  dif = 0.0;
              }
          }
      }


      // Umbrales de las capas ocultas
      for(int q=1; q<C-1; q++){
          for(int i=0; i<N; i++){
              neuronas[q][i].u += eta * neuronas[q][i].delta;
          }
      }

      // Pesos de la capa de entrada a la primera capa oculta
      for(int i=0; i<M; i++){
          for(int j=0; j<N; j++){
              dif = neuronas[0][i].w[j] - neuronas[0][i].dw[j];
              neuronas[0][i].dw[j] = neuronas[0][i].w[j];
              neuronas[0][i].w[j] += eta * neuronas[1][i].delta * neuronas[0][i].a - alfa * dif;
              dif = 0.0;
          }
      }

  }
  // Entrena la red
  int Entrenar(vector<vector<double> > pentrada, vector<vector<double> > psalida, double &errorT, double errorco, int epocas){
      double error = 0.0; errorT = 1.0;
      int rep = 0;
      int n_patrones = (int)pentrada.size();

      int max_stack_iteracciones = 1000;
      int actual_iteracciones = 0;

      bool minimal_condition = true;
      double minimal_error = 99999;
      double minimal_maximo_difference = this->minimal_maximo;

      while( (errorT > errorco) && (rep < epocas) && minimal_condition ){
      // for(int i=0; i<epocas; i++){
          error = 0.0;
          for(int j=0; j<n_patrones; j++){
              error += ErrorC(pentrada[j], psalida[j]); Aprender(pentrada[j], psalida[j]);
          }
          errorT = error / n_patrones;
          rep++;
          //cout<<"["<<rep<<"]  "<<errorT<<endl;

          //Condicion de pare escalado
          if(errorT < minimal_error){
            minimal_error = errorT;
          }

          if((errorT - minimal_error) > minimal_maximo_difference){
            minimal_condition = false;
          }
      }
      return rep;
  }


  // Guardamos los valores
  void Guardar(char *sinapsis){
      ofstream salida(sinapsis, ios::out|ios::binary);
      salida.write(reinterpret_cast<char *>(&C), sizeof(int));
      salida.write(reinterpret_cast<char *>(&M), sizeof(int));
      salida.write(reinterpret_cast<char *>(&N), sizeof(int));
      salida.write(reinterpret_cast<char *>(&L), sizeof(int));
      salida.write(reinterpret_cast<char *>(&eta), sizeof(double));
      salida.write(reinterpret_cast<char *>(&alfa), sizeof(double));

      // Guardamos los pesos
      for(int i=0; i<M; i++){
          for(int j=0; j<N; j++){
              salida.write(reinterpret_cast<char *>(&neuronas[0][i].w[j]), sizeof(double));
          }
      }
      for(int q=0; q<C-3; q++){
          for(int i=0; i<N; i++){
              for(int j=0; j<N; j++){
                  salida.write(reinterpret_cast<char *>(&neuronas[q+1][i].w[j]), sizeof(double));
              }
          }
      }
      for(int i=0; i<N; i++){
          for(int j=0; j<L; j++){
              salida.write(reinterpret_cast<char *>(&neuronas[C-2][i].w[j]), sizeof(double));
          }
      }

      // Guardamos los umbrales
      for(int q=0; q<C-2; q++){
          for(int i=0; i<N; i++){
              salida.write(reinterpret_cast<char *>(&neuronas[q+1][i].u), sizeof(double));
          }
      }

      for(int i=0; i<L; i++){
          salida.write(reinterpret_cast<char *>(&neuronas[C-1][i].u), sizeof(double));
      }

      salida.close();
  }
  //Leemos los valores de aprendizaje desde
  string Leer(string entrances){
    string temp_word;
    double temp_num;

    int n_layers = 0; //Numero de capas de la red neuronal
    int n_entrance_layers = 0; // Numero de neuronas de la capa de entrada
    int n_middle_layers = 0; // Numero de neuronas de las capas de intermedia
    int n_final_layers = 0; // Numero de neuronas de la capa de salida.
    int n_examples = 0; // Numero de datos que la red va a aprender

    ifstream lector;
    lector.open(entrances.c_str(), ifstream::in);

    if(lector.is_open()){
      lector>>temp_word; n_layers = stoi(temp_word); //Leyendo el numero de capas
      lector>>temp_word; n_entrance_layers = stoi(temp_word); //Leyendo el numero de neuronas en la capa de entrada
      lector>>temp_word; n_middle_layers = stoi(temp_word); //Leyendo el numero de neuronas de las capas intermedias
      lector>>temp_word; n_final_layers = stoi(temp_word); //Leyendo el numero de neurona de las capas de salida
      lector>>temp_word; n_examples = stoi(temp_word); //Numero de ejemplos que la red va a aprender

      vector<vector<double>> pentrada(n_examples, vector<double>(n_entrance_layers, 0.0)); //Estableciendo limites del campo del vector
      vector<vector<double>> psalida(n_examples, vector<double>(n_entrance_layers, 0.0));

      //cout<<"[Iniciando lectura de documento]"<<endl;
      int index_example = 0;
      while(lector >> temp_word){
        //Guardamos los datos de entrada
        temp_num = stod(temp_word);
        pentrada[index_example][0] = temp_num;

        for(int i = 1; i < n_entrance_layers; i++){
          lector >> temp_word;
          temp_num = stod(temp_word);
          pentrada[index_example][i] = temp_num;
        }

        for(int i = 0; i < n_final_layers; i++){
          lector >> temp_word;
          temp_num = stod(temp_word);
          psalida[index_example][i] = temp_num;
        }
        //Guardamos los datos de salida
        index_example++;
      }
      lector.close();
      double errorT = 0.0;
      //Retorna numero de epocas
      int rep = this->Entrenar(pentrada, psalida, errorT, this->minimal_error, this->epocas);
      stringstream temp_asnwer;
      temp_asnwer << "[Entrenamiento Finalizado]  MinE: " << this->minimal_error << " MinMax: "<<this->minimal_maximo <<" Epo: "<<this->epocas
                  << " ActualEpo: "<< rep << " FinError: "<<errorT<< endl;

      string answer = temp_asnwer.str();
      return answer;
    }
    else{
      string answer = "No se ha podido abrir el documento \n";
      return answer;
    }

  }
  //Extra Configuration para razones de entrenamiento
  void SetExternalConfiguration(double _min, double _min_max, int _epo){
    this->minimal_error = _min;
    this->minimal_maximo = _min_max;
    this->epocas = _epo;
  }
};

#endif
