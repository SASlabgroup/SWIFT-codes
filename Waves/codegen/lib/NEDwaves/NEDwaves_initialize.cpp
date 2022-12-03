//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// NEDwaves_initialize.cpp
//
// Code generation for function 'NEDwaves_initialize'
//

// Include files
#include "NEDwaves_initialize.h"
#include "NEDwaves_data.h"
#include "rt_nonfinite.h"
#include "omp.h"

// Function Definitions
void NEDwaves_initialize()
{
  omp_init_nest_lock(&NEDwaves_nestLockGlobal);
  isInitialized_NEDwaves = true;
}

// End of code generation (NEDwaves_initialize.cpp)
