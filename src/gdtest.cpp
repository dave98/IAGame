#include "gdtest.hpp"
#include <iostream>
#include <sstream>
#include "ann_interface.h"

using namespace godot;
using namespace std;

//ann_interface* global_ann = new ann_interface;

void GDTest::_register_methods(){
  register_method("create_ann", &GDTest::create_ann);
  register_method("create_saved_ann", &GDTest::create_saved_ann);
  register_method("start_ann", &GDTest::start_ann);
  register_method("direc_test", &GDTest::direc_test);
  register_method("data_to_evaluate", &GDTest::data_to_evaluate);
  register_method("evaluate", &GDTest::evaluate);
  register_method("get_ope", &GDTest::get_ope);
  register_method("get_cons", &GDTest::get_cons);
  register_method("get_neuro", &GDTest::get_neuro);
}

void GDTest::_init(){
}

String GDTest::create_ann(){
  this->g_ann = new ann_interface(4, 17, 12, 3);
  if(this->g_ann){
    String answer = "Se ha creado la red exitosamente";
    return answer;
  }
  else{
    String answer = "Error durante la creacion de interface de red";
    return answer;
  }
}

String GDTest::create_saved_ann(String route){
  string inner_route = route.utf8().get_data();
  this->g_ann = new ann_interface(inner_route);
  if(this->g_ann){
    String answer = "Se ha cargado la red exitosamente";
    return answer;
  }
  else{
    String answer = "Error durante la carga de interface de red";
    return answer;
  }
}

String GDTest::start_ann(String route, double e_min, double min_max, int epo){
  string inner_route = route.utf8().get_data();
  String answer = this->g_ann->start_ann(inner_route, e_min, min_max, epo).c_str();
  //String answer = this->g_ann->start_ann("non_sintetic.txt", 0.01, 0.005, 1000).c_str();
  return answer;
}

String GDTest::direc_test(){
  if(this->g_ann){
    if(this->g_ann->internal_ann){
      stringstream temp_asnwer;
      temp_asnwer << "Red Existente con "
                  << " Capas: "<< this->g_ann->internal_ann->C
                  << " Entradas: "<< this->g_ann->internal_ann->M
                  << " Intermedios: "<< this->g_ann->internal_ann->N
                  << " Salidas: " << this->g_ann->internal_ann->L
                  << " MinimalError: "<< this->g_ann->internal_ann->minimal_error
                  << " MinimoMaximo: "<< this->g_ann->internal_ann->minimal_maximo
                  << " Epocas: " << this->g_ann->internal_ann->epocas;
      String answer = temp_asnwer.str().c_str();
      return answer;
    }
    else{
      String answer = "No hay red en Interface";
      return answer;
    }
  }
  else{
    String answer = "No hay red en GDLibrary";
    return answer;
  }


}

String GDTest::data_to_evaluate(double f_1,
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
  String answer = this->g_ann->set_evaluation_data(f_1, f_2, f_3, f_4, f_5, f_6, f_7, f_8, f_9, f_10, f_11, f_12, f_13, f_14, f_15, f_16, f_17).c_str();
  return answer;
}

String GDTest::evaluate(){
  String answer = this->g_ann->evaluate().c_str();
  return answer;
}

double GDTest::get_ope(){
  double answer = this->g_ann->get_ope();
  return answer;
}

double GDTest::get_cons(){
  double answer = this->g_ann->get_cons();
  return answer;
}

double GDTest::get_neuro(){
  double answer = this->g_ann->get_neuro();
  return answer;
}
