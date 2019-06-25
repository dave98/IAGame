#ifndef ANN_INTERFACE_H
#define ANN_INTERFACE_H


#include <iostream>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include "MLP2.hpp"


using  namespace std;

class ann_interface{
public:
  //Pointer to our neorunal network
  MLP* internal_ann;
  vector<double> eval;
  vector<double> results;

  double openess;
  double conscientiousness;
  double neurocitism;


  ann_interface(int, int, int, int); //DONE
  ann_interface(string);
  ~ann_interface(); //DONE

  string availability_message(); //DONE
  string start_ann(string, double, double, int); //Crea una red neuronal basada en los datos que recibe
  string set_evaluation_data(double f_1,
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
                             double f_17);


  string evaluate();
  double get_ope();
  double get_cons();
  double get_neuro();

};






#endif
