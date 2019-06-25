#include "ann_interface.h"

//Can use external class with pointers and direct linking,  but it's impossible to define them out of the main class
ann_interface::ann_interface(int n_layers, int n_entrada, int n_intermedios, int n_salidas){
  this->internal_ann = new MLP(n_layers, n_entrada, n_intermedios, n_salidas);
  this->eval = vector<double>(17, 0.0);
  this->results = vector<double>(3, 0.0);

  this->openess = 0.0;
  this->conscientiousness = 0.0;
  this->neurocitism = 0.0;
}

ann_interface::ann_interface(string saved_on){
  this->internal_ann = new MLP(saved_on);
  this->eval = vector<double>(17, 0.0);
  this->results = vector<double>(3, 0.0);

  this->openess = 0.0;
  this->conscientiousness = 0.0;
  this->neurocitism = 0.0;
}


ann_interface::~ann_interface(){}

string ann_interface::availability_message(){
  if(this->internal_ann){
    return "Ann disponible";
  }
  else{
    return "Ann no disponible";
  }
}

string ann_interface::start_ann(string route, double e_min, double min_max, int epo){
    if(this->internal_ann){
      this->internal_ann->SetExternalConfiguration(e_min, min_max, epo);
      string answer = this->internal_ann->Leer(route);
      return answer;
    }
    else{
      return "No se pudo iniciar la lectura";
    }
}


string ann_interface::set_evaluation_data(double f_1,
                           double f_2,
                           double f_3,
                           double f_4,
                           double f_5,
                           double f_6,
                           double f_7,
                           double f_8,
                           double f_9,
                           double f_10,
                           double f_11,
                           double f_12,
                           double f_13,
                           double f_14,
                           double f_15,
                           double f_16,
                           double f_17){
   this->eval[0] = f_1;
   this->eval[1] = f_2;
   this->eval[2] = f_3;
   this->eval[3] = f_4;
   this->eval[4] = f_5;
   this->eval[5] = f_6;
   this->eval[6] = f_7;
   this->eval[7] = f_8;
   this->eval[8] = f_9;
   this->eval[9] = f_10;
   this->eval[10] = f_11;
   this->eval[11] = f_12;
   this->eval[12] = f_13;
   this->eval[13] = f_14;
   this->eval[14] = f_15;
   this->eval[15] = f_16;
   this->eval[16] = f_17;

   string answer = "Datos de evaluacion cargados correctamente";
   return answer;
}

string ann_interface::evaluate(){
  this->results = this->internal_ann->Activar(this->eval);
  this->openess = this->results[0];
  this->conscientiousness = this->results[1];
  this->neurocitism = this->results[2];

  for(unsigned int i = 0; i < this->results.size(); i++){
    this->results[i] = 0.0;
  }

  string answer = "[Evaluacion completa]";
  return answer;
}

double ann_interface::get_ope(){
  return this->openess;
}

double ann_interface::get_cons(){
  return this->conscientiousness;
}

double ann_interface::get_neuro(){
  return this->neurocitism;
}
