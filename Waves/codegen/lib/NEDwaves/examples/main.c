/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
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
#include "NEDwaves.h"
#include "NEDwaves_emxAPI.h"
#include "NEDwaves_terminate.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"

/* Function Declarations */
static emxArray_real32_T *argInit_Unboundedx1_real32_T(void);

static float argInit_real32_T(void);

static double argInit_real_T(void);

static void main_NEDwaves(void);

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : emxArray_real32_T *
 */
static emxArray_real32_T *argInit_Unboundedx1_real32_T(void)
{
  emxArray_real32_T *result;
  float *result_data;
  const int i = 2;
  int idx0;
  /* Set the size of the array.
Change this size to the value that the application requires. */
  result = emxCreateND_real32_T(1, &i);
  result_data = result->data;
  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < result->size[0U]; idx0++) {
    /* Set the value of the array element.
Change this value to the value that the application requires. */
    result_data[idx0] = argInit_real32_T();
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
static void main_NEDwaves(void)
{
  emxArray_int8_T *a1;
  emxArray_int8_T *a2;
  emxArray_int8_T *b1;
  emxArray_int8_T *b2;
  emxArray_real16_T *E;
  emxArray_real32_T *down;
  emxArray_real32_T *east;
  emxArray_real32_T *north;
  emxArray_uint8_T *check;
  real16_T Dp;
  real16_T Hs;
  real16_T Tp;
  real16_T b_fmax;
  real16_T b_fmin;
  emxInitArray_real16_T(&E, 2);
  emxInitArray_int8_T(&a1, 2);
  emxInitArray_int8_T(&b1, 2);
  emxInitArray_int8_T(&a2, 2);
  emxInitArray_int8_T(&b2, 2);
  emxInitArray_uint8_T(&check, 2);
  /* Initialize function 'NEDwaves' input arguments. */
  /* Initialize function input argument 'north'. */
  north = argInit_Unboundedx1_real32_T();
  /* Initialize function input argument 'east'. */
  east = argInit_Unboundedx1_real32_T();
  /* Initialize function input argument 'down'. */
  down = argInit_Unboundedx1_real32_T();
  /* Call the entry-point 'NEDwaves'. */
  NEDwaves(north, east, down, argInit_real_T(), &Hs, &Tp, &Dp, E, &b_fmin,
           &b_fmax, a1, b1, a2, b2, check);
  emxDestroyArray_uint8_T(check);
  emxDestroyArray_int8_T(b2);
  emxDestroyArray_int8_T(a2);
  emxDestroyArray_int8_T(b1);
  emxDestroyArray_int8_T(a1);
  emxDestroyArray_real16_T(E);
  emxDestroyArray_real32_T(down);
  emxDestroyArray_real32_T(east);
  emxDestroyArray_real32_T(north);
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
  main_NEDwaves();
  /* Terminate the application.
You do not need to do this more than one time. */
  NEDwaves_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
