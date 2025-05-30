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
#include "despikeSIG_onboard.h"
#include "despikeSIG_onboard_terminate.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Declarations
static coder::array<double, 2U> argInit_128xUnbounded_real_T();

static coder::array<char, 2U> argInit_1xUnbounded_char_T();

static char argInit_char_T();

static double argInit_real_T();

static void main_despikeSIG_onboard();

// Function Definitions
static coder::array<double, 2U> argInit_128xUnbounded_real_T()
{
  coder::array<double, 2U> result;
  // Set the size of the array.
  // Change this size to the value that the application requires.
  result.set_size(128, 2);
  // Loop over the array to initialize each element.
  for (int idx0{0}; idx0 < 128; idx0++) {
    for (int idx1{0}; idx1 < result.size(1); idx1++) {
      // Set the value of the array element.
      // Change this value to the value that the application requires.
      result[idx0 + 128 * idx1] = argInit_real_T();
    }
  }
  return result;
}

static coder::array<char, 2U> argInit_1xUnbounded_char_T()
{
  coder::array<char, 2U> result;
  // Set the size of the array.
  // Change this size to the value that the application requires.
  result.set_size(1, 2);
  // Loop over the array to initialize each element.
  for (int idx0{0}; idx0 < 1; idx0++) {
    for (int idx1{0}; idx1 < result.size(1); idx1++) {
      // Set the value of the array element.
      // Change this value to the value that the application requires.
      result[idx1] = argInit_char_T();
    }
  }
  return result;
}

static char argInit_char_T()
{
  return '?';
}

static double argInit_real_T()
{
  return 0.0;
}

static void main_despikeSIG_onboard()
{
  coder::array<double, 2U> wclean;
  coder::array<double, 2U> wraw;
  coder::array<char, 2U> filltype;
  coder::array<bool, 2U> ispike;
  double nfilt_tmp;
  // Initialize function 'despikeSIG_onboard' input arguments.
  // Initialize function input argument 'wraw'.
  wraw = argInit_128xUnbounded_real_T();
  nfilt_tmp = argInit_real_T();
  // Initialize function input argument 'filltype'.
  filltype = argInit_1xUnbounded_char_T();
  // Call the entry-point 'despikeSIG_onboard'.
  despikeSIG_onboard(wraw, nfilt_tmp, nfilt_tmp, filltype, wclean, ispike);
}

int main(int, char **)
{
  // The initialize function is being called automatically from your entry-point
  // function. So, a call to initialize is not included here. Invoke the
  // entry-point functions.
  // You can call entry-point functions multiple times.
  main_despikeSIG_onboard();
  // Terminate the application.
  // You do not need to do this more than one time.
  despikeSIG_onboard_terminate();
  return 0;
}

// End of code generation (main.cpp)
