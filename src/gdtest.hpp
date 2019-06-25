#ifndef GDTEST_HPP
#define GDTEST_HPP

#include <Godot.hpp>
#include <Node.hpp>
#include "ann_interface.h"

//MLP perce(4, 17, 12, 3); Standar Configuration
namespace godot{

   class GDTest : public Node{
     GODOT_CLASS(GDTest, Node)

   public:
     ann_interface* g_ann;

     static void _register_methods(); //Todas las funciones de la interface van en este lado
     void _init();

     String create_ann();
     String create_saved_ann(String);
     String start_ann(String, double, double, int); //StartEvaluation
     String direc_test(); //Examina directamente los elementos de la red
     String data_to_evaluate(double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double,
                             double);
     String evaluate();

     double get_ope();
     double get_cons();
     double get_neuro();

   };
}

#endif /* !GDTEST_HPP */
