//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// NEDwaves_terminate.cpp
//
// Code generation for function 'NEDwaves_terminate'
//

// Include files
#include "NEDwaves_terminate.h"
#include "NEDwaves_data.h"
#include "rt_nonfinite.h"
#include "omp.h"

// Function Definitions
void NEDwaves_terminate()
{
  omp_destroy_nest_lock(&NEDwaves_nestLockGlobal);
  isInitialized_NEDwaves = false;
}

// End of code generation (NEDwaves_terminate.cpp)
