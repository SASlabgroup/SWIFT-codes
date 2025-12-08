/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: XYZaccelerationspectra_emxAPI.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 03-Dec-2025 20:33:49
 */

/* Include Files */
#include "XYZaccelerationspectra_emxAPI.h"
#include "XYZaccelerationspectra_emxutil.h"
#include "XYZaccelerationspectra_types.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"
#include <stdlib.h>

/* Function Definitions */
/*
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : emxArray_real16_T *
 */
emxArray_real16_T *emxCreateND_real16_T(int numDimensions, const int *size)
{
  emxArray_real16_T *emx;
  int i;
  int numEl;
  emxInit_real16_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = (real16_T *)calloc((unsigned int)numEl, sizeof(real16_T));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : emxArray_real32_T *
 */
emxArray_real32_T *emxCreateND_real32_T(int numDimensions, const int *size)
{
  emxArray_real32_T *emx;
  int i;
  int numEl;
  emxInit_real32_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = (float *)calloc((unsigned int)numEl, sizeof(float));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : real16_T *data
 *                int numDimensions
 *                const int *size
 * Return Type  : emxArray_real16_T *
 */
emxArray_real16_T *
emxCreateWrapperND_real16_T(real16_T *data, int numDimensions, const int *size)
{
  emxArray_real16_T *emx;
  int i;
  int numEl;
  emxInit_real16_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = data;
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  emx->canFreeData = false;
  return emx;
}

/*
 * Arguments    : float *data
 *                int numDimensions
 *                const int *size
 * Return Type  : emxArray_real32_T *
 */
emxArray_real32_T *emxCreateWrapperND_real32_T(float *data, int numDimensions,
                                               const int *size)
{
  emxArray_real32_T *emx;
  int i;
  int numEl;
  emxInit_real32_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = data;
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  emx->canFreeData = false;
  return emx;
}

/*
 * Arguments    : real16_T *data
 *                int rows
 *                int cols
 * Return Type  : emxArray_real16_T *
 */
emxArray_real16_T *emxCreateWrapper_real16_T(real16_T *data, int rows, int cols)
{
  emxArray_real16_T *emx;
  emxInit_real16_T(&emx, 2);
  emx->size[0] = rows;
  emx->size[1] = cols;
  emx->data = data;
  emx->numDimensions = 2;
  emx->allocatedSize = rows * cols;
  emx->canFreeData = false;
  return emx;
}

/*
 * Arguments    : float *data
 *                int rows
 *                int cols
 * Return Type  : emxArray_real32_T *
 */
emxArray_real32_T *emxCreateWrapper_real32_T(float *data, int rows, int cols)
{
  emxArray_real32_T *emx;
  emxInit_real32_T(&emx, 2);
  emx->size[0] = rows;
  emx->size[1] = cols;
  emx->data = data;
  emx->numDimensions = 2;
  emx->allocatedSize = rows * cols;
  emx->canFreeData = false;
  return emx;
}

/*
 * Arguments    : int rows
 *                int cols
 * Return Type  : emxArray_real16_T *
 */
emxArray_real16_T *emxCreate_real16_T(int rows, int cols)
{
  emxArray_real16_T *emx;
  int numEl;
  emxInit_real16_T(&emx, 2);
  emx->size[0] = rows;
  numEl = rows * cols;
  emx->size[1] = cols;
  emx->data = (real16_T *)calloc((unsigned int)numEl, sizeof(real16_T));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : int rows
 *                int cols
 * Return Type  : emxArray_real32_T *
 */
emxArray_real32_T *emxCreate_real32_T(int rows, int cols)
{
  emxArray_real32_T *emx;
  int numEl;
  emxInit_real32_T(&emx, 2);
  emx->size[0] = rows;
  numEl = rows * cols;
  emx->size[1] = cols;
  emx->data = (float *)calloc((unsigned int)numEl, sizeof(float));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : emxArray_real16_T *emxArray
 * Return Type  : void
 */
void emxDestroyArray_real16_T(emxArray_real16_T *emxArray)
{
  emxFree_real16_T(&emxArray);
}

/*
 * Arguments    : emxArray_real32_T *emxArray
 * Return Type  : void
 */
void emxDestroyArray_real32_T(emxArray_real32_T *emxArray)
{
  emxFree_real32_T(&emxArray);
}

/*
 * Arguments    : emxArray_real16_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void emxInitArray_real16_T(emxArray_real16_T **pEmxArray, int numDimensions)
{
  emxInit_real16_T(pEmxArray, numDimensions);
}

/*
 * Arguments    : emxArray_real32_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void emxInitArray_real32_T(emxArray_real32_T **pEmxArray, int numDimensions)
{
  emxInit_real32_T(pEmxArray, numDimensions);
}

/*
 * File trailer for XYZaccelerationspectra_emxAPI.c
 *
 * [EOF]
 */
