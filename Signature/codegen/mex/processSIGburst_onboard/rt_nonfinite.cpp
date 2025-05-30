//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// rt_nonfinite.cpp
//
// Code generation for function 'processSIGburst_onboard'
//

// Include files
#include "rt_nonfinite.h"
#include "processSIGburst_onboard_data.h"
#include "matrix.h"

real_T mex_rtInf;
real_T mex_rtMinusInf;
real_T mex_rtNaN;
real32_T mex_rtInfF;
real32_T mex_rtMinusInfF;
real32_T mex_rtNaNF;

void mex_InitInfAndNan(void)
{
  mex_rtInf = mxGetInf();
  mex_rtMinusInf = -rtInf;
  mex_rtInfF = (real32_T)rtInf;
  mex_rtMinusInfF = -rtInfF;
  mex_rtNaN = mxGetNaN();
  mex_rtNaNF = (real32_T)rtNaN;
}
// End of code generation (rt_nonfinite.cpp)
