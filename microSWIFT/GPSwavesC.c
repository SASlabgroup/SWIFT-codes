/* ************************************************************************ */
/*                                                                          */
/*                                                                          */
/* ***********************************************************************  */
/* Include files */
#include "rt_nonfinite.h"
#include "GPSwaves_terminate.h"
#include "GPSwaves_emxAPI.h"
#include "GPSwaves_initialize.h"
#include "GPSwaves_emxutil.h"
#include "GPSwaves_types.h"
#include "GPSwaves.h"
#include "/usr/local/include/boost/python.hpp"
#include "/usr/local/include/boost/python/module.hpp"
#include "/usr/local/include/boost/python/def.hpp"
#include "/usr/local/include/boost/python/extract.hpp"
#include "/usr/local/include/boost/python/numpy.hpp"
#include "/usr/local/include/boost/python/numpy/ndarray.hpp"
#include "/usr/local/include/boost/python/args.hpp"
#include <iostream>
#include <vector>

using namespace boost::python;
namespace np = boost::python::numpy;

/* Function Declarations */
tuple main_GPSwaves(int nsize, np::ndarray ui,np::ndarray vi, np::ndarray zi,
                  double fsi)
{

  int i;
  double fs;
  double Hs, Tp, Dp;
  emxArray_real_T *D  = emxCreate_real_T(1, nsize);
  emxArray_real_T *E  = emxCreate_real_T(1, nsize);
  emxArray_real_T *f  = emxCreate_real_T(1, nsize);
  emxArray_real_T *a1 = emxCreate_real_T(1, nsize);
  emxArray_real_T *b1 = emxCreate_real_T(1, nsize);
  emxArray_real_T *a2 = emxCreate_real_T(1, nsize);
  emxArray_real_T *b2 = emxCreate_real_T(1, nsize);
  emxArray_real_T *u  = emxCreate_real_T(1, nsize);
  emxArray_real_T *v  = emxCreate_real_T(1, nsize);
  emxArray_real_T *z  = emxCreate_real_T(1, nsize);
  emxInitArray_real_T(&E, 2);
  emxInitArray_real_T(&f, 2);
  emxInitArray_real_T(&a1, 2);
  emxInitArray_real_T(&b1, 2);
  emxInitArray_real_T(&a2, 2);
  emxInitArray_real_T(&b2, 2);
  std::vector<double> usd; 
  std::vector<double> vsd; 
  std::vector<double> zsd;

  for (i=0;i<nsize;i++) 
  {
    usd.push_back(extract<double>(ui[i]));
    vsd.push_back(extract<double>(vi[i]));
    zsd.push_back(extract<double>(zi[i])); 
  }


  /* Initialize function 'GPSwaves' input arguments. */
  emxArray_real_T *us = emxCreateWrapper_real_T(&usd[0], 1, nsize);
  emxArray_real_T *vs = emxCreateWrapper_real_T(&vsd[0], 1, nsize);
  emxArray_real_T *zs = emxCreateWrapper_real_T(&zsd[0], 1, nsize);

  /* Call the entry-point 'GPSwaves'. */
  GPSwaves(us, vs, zs, fsi, &Hs, &Tp, &Dp, E, f, a1, b1, a2, b2);
  
  nsize = 42;

  boost::python::tuple shape = boost::python::make_tuple(nsize, 1);
  np::dtype dtype = np::dtype::get_builtin<double>();
  np::ndarray Eo = np::zeros(shape, dtype);
  np::ndarray fo = np::zeros(shape, dtype);
  np::ndarray ao1 = np::zeros(shape, dtype);
  np::ndarray bo1 = np::zeros(shape, dtype); 
  np::ndarray ao2 = np::zeros(shape, dtype);
  np::ndarray bo2 = np::zeros(shape, dtype);

  for (i=0;i<nsize;i++) {
      Eo[i]= E->data[i];
      fo[i]= f->data[i]; 
      ao1[i]= a1->data[i];
      bo1[i]= b1->data[i];
      ao2[i]= a2->data[i];
      bo2[i]= b2->data[i];
  };
  return make_tuple(Hs, Tp, Dp, Eo, fo, ao1, bo1, ao2, bo2);

};


/* Define your module name within BOOST_PYTHON_MODULE */
BOOST_PYTHON_MODULE(GPSwavesC) {

  /* Initialise np */
  Py_Initialize();
  np::initialize();
  def("main_GPSwaves",main_GPSwaves);
};

