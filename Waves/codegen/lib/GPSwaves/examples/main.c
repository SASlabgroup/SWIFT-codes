/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
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
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "main.h"
#include "GPSwaves_terminate.h"
#include "GPSwaves_emxAPI.h"
#include "GPSwaves_initialize.h"

/* Function Declarations */
static emxArray_real_T *argInit_1xUnbounded_real_T(void);
static double argInit_real_T(void);
static void main_GPSwaves(void);

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : emxArray_real_T *
 */
static emxArray_real_T *argInit_1xUnbounded_real_T(void)
{
  emxArray_real_T *result;
  static int iv0[2] = { 1, 2 };

  int idx1;

  /* Set the size of the array.
     Change this size to the value that the application requires. */
  result = emxCreateND_real_T(2, iv0);

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result->data[result->size[0] * idx1] = argInit_real_T();
  }

  return result;
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
static void main_GPSwaves(void)
{
  emxArray_real_T *E;
  emxArray_real_T *f;
  emxArray_real_T *a1;
  emxArray_real_T *b1;
  emxArray_real_T *a2;
  emxArray_real_T *b2;
  emxArray_real_T *u;
  emxArray_real_T *v;
  emxArray_real_T *z;
  double Hs;
  double Tp;
  double Dp;
  emxInitArray_real_T(&E, 2);
  emxInitArray_real_T(&f, 2);
  emxInitArray_real_T(&a1, 2);
  emxInitArray_real_T(&b1, 2);
  emxInitArray_real_T(&a2, 2);
  emxInitArray_real_T(&b2, 2);

  /* Initialize function 'GPSwaves' input arguments. */
  /* Initialize function input argument 'u'. */
  u = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'v'. */
  v = argInit_1xUnbounded_real_T();

  /* Initialize function input argument 'z'. */
  z = argInit_1xUnbounded_real_T();

  /* Call the entry-point 'GPSwaves'. */
  GPSwaves(u, v, z, argInit_real_T(), &Hs, &Tp, &Dp, E, f, a1, b1, a2, b2);
  emxDestroyArray_real_T(b2);
  emxDestroyArray_real_T(a2);
  emxDestroyArray_real_T(b1);
  emxDestroyArray_real_T(a1);
  emxDestroyArray_real_T(f);
  emxDestroyArray_real_T(E);
  emxDestroyArray_real_T(z);
  emxDestroyArray_real_T(v);
  emxDestroyArray_real_T(u);
}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  GPSwaves_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_GPSwaves();

  /* Terminate the application.
     You do not need to do this more than one time. */
  GPSwaves_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
