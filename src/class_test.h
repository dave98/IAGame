#ifndef CLASS_TEST_H
#define CLASS_TEST_H

#include <iostream>

using namespace std;

class class_test{
public:
    int pointer_a;

    class_test();
    ~class_test();

    void first_method();
};


class_test::class_test(){
  pointer_a  = 1;
}


class_test::~class_test(){
}

void class_test::first_method(){
  pointer_a = 10;
}




#endif
