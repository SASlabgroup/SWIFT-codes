/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 03-Dec-2025 20:33:49
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/

/* Include Files */
#include "main.h"
#include "XYZaccelerationspectra.h"
#include "XYZaccelerationspectra_emxAPI.h"
#include "XYZaccelerationspectra_terminate.h"
#include "XYZaccelerationspectra_types.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"

/* Function Declarations */
static emxArray_real32_T *argInit_1xUnbounded_real32_T(void);

static float argInit_real32_T(void);

static double argInit_real_T(void);

static void main_XYZaccelerationspectra(void);

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : emxArray_real32_T *
 */
static emxArray_real32_T *argInit_1xUnbounded_real32_T(void)
{
  emxArray_real32_T *result;
  float *result_data;
  int idx0;
  int idx1;
  /* Set the size of the array.
Change this size to the value that the application requires. */
  result = emxCreate_real32_T(1, 2);
  result_data = result->data;
  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 1; idx0++) {
    for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
      /* Set the value of the array element.
Change this value to the value that the application requires. */
      result_data[idx1] = argInit_real32_T();
    }
  }
  return result;
}

/*
 * Arguments    : void
 * Return Type  : float
 */
static float argInit_real32_T(void)
{
  return 0.0F;
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_XYZaccelerationspectra(void)
{
  emxArray_real16_T *XX;
  emxArray_real16_T *YY;
  emxArray_real16_T *ZZ;
  emxArray_real32_T *x;
  emxArray_real32_T *y;
  emxArray_real32_T *z;
  real16_T b_fmax;
  real16_T b_fmin;
  emxInitArray_real16_T(&XX, 2);
  emxInitArray_real16_T(&YY, 2);
  emxInitArray_real16_T(&ZZ, 2);
  /* Initialize function 'XYZaccelerationspectra' input arguments. */
  /* Initialize function input argument 'x'. */
  x = argInit_1xUnbounded_real32_T();
  /* Initialize function input argument 'y'. */
  y = argInit_1xUnbounded_real32_T();
  /* Initialize function input argument 'z'. */
  z = argInit_1xUnbounded_real32_T();
  /* Call the entry-point 'XYZaccelerationspectra'. */
  XYZaccelerationspectra(x, y, z, argInit_real_T(), &b_fmin, &b_fmax, XX, YY,
                         ZZ);
  emxDestroyArray_real16_T(ZZ);
  emxDestroyArray_real16_T(YY);
  emxDestroyArray_real16_T(XX);
  emxDestroyArray_real32_T(z);
  emxDestroyArray_real32_T(y);
  emxDestroyArray_real32_T(x);
}

/*
 * Arguments    : int argc
 *                char **argv
 * Return Type  : int
 */
int main(int argc, char **argv)
{
  (void)argc;
  (void)argv;
  /* The initialize function is being called automatically from your entry-point
   * function. So, a call to initialize is not included here. */
  /* Invoke the entry-point functions.
You can call entry-point functions multiple times. */
  main_XYZaccelerationspectra();
  /* Terminate the application.
You do not need to do this more than one time. */
  XYZaccelerationspectra_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
