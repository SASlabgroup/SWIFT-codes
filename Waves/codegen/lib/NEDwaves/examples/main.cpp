//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// main.cpp
//
// Code generation for function 'main'
//

/*************************************************************************/
/* This automatically generated example C++ main file shows how to call  */
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

// Include files
#include "main.h"
#include "NEDwaves.h"
#include "NEDwaves_terminate.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Declarations
static coder::array<float, 1U> argInit_Unboundedx1_real32_T();

static float argInit_real32_T();

static double argInit_real_T();

static void main_NEDwaves();

// Function Definitions
static coder::array<float, 1U> argInit_Unboundedx1_real32_T()
{
  coder::array<float, 1U> result;
  // Set the size of the array.
  // Change this size to the value that the application requires.
  result.set_size(2);
  // Loop over the array to initialize each element.
  for (int idx0{0}; idx0 < result.size(0); idx0++) {
    // Set the value of the array element.
    // Change this value to the value that the application requires.
    result[idx0] = argInit_real32_T();
  }
  return result;
}

static float argInit_real32_T()
{
  return 0.0F;
}

static double argInit_real_T()
{
  return 0.0;
}

static void main_NEDwaves()
{
  coder::array<double, 2U> E;
  coder::array<double, 2U> a1;
  coder::array<double, 2U> a2;
  coder::array<double, 2U> b1;
  coder::array<double, 2U> b2;
  coder::array<double, 2U> check;
  coder::array<double, 2U> f;
  coder::array<float, 1U> down;
  coder::array<float, 1U> east;
  coder::array<float, 1U> north_tmp;
  double Dp;
  double Hs;
  double Tp;
  // Initialize function 'NEDwaves' input arguments.
  // Initialize function input argument 'north'.
  north_tmp = argInit_Unboundedx1_real32_T();
  // Initialize function input argument 'east'.
  east = north_tmp;
  // Initialize function input argument 'down'.
  down = north_tmp;
  // Call the entry-point 'NEDwaves'.
  NEDwaves(north_tmp, east, down, argInit_real_T(), &Hs, &Tp, &Dp, E, f, a1, b1,
           a2, b2, check);
}

int main(int, char **)
{
  // The initialize function is being called automatically from your entry-point
  // function. So, a call to initialize is not included here. Invoke the
  // entry-point functions.
  // You can call entry-point functions multiple times.
  main_NEDwaves();
  // Terminate the application.
  // You do not need to do this more than one time.
  NEDwaves_terminate();
  return 0;
}

// End of code generation (main.cpp)
