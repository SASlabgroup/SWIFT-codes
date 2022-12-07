/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_emxAPI.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "NEDwaves_emxAPI.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include "rtwhalf.h"
#include <stdlib.h>

/* Function Definitions */
/*
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : emxArray_int8_T *
 */
emxArray_int8_T *emxCreateND_int8_T(int numDimensions, const int *size)
{
  emxArray_int8_T *emx;
  int i;
  int numEl;
  emxInit_int8_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = (signed char *)calloc((unsigned int)numEl, sizeof(signed char));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

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
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : emxArray_uint8_T *
 */
emxArray_uint8_T *emxCreateND_uint8_T(int numDimensions, const int *size)
{
  emxArray_uint8_T *emx;
  int i;
  int numEl;
  emxInit_uint8_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data =
      (unsigned char *)calloc((unsigned int)numEl, sizeof(unsigned char));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : signed char *data
 *                int numDimensions
 *                const int *size
 * Return Type  : emxArray_int8_T *
 */
emxArray_int8_T *emxCreateWrapperND_int8_T(signed char *data, int numDimensions,
                                           const int *size)
{
  emxArray_int8_T *emx;
  int i;
  int numEl;
  emxInit_int8_T(&emx, numDimensions);
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
 * Arguments    : unsigned char *data
 *                int numDimensions
 *                const int *size
 * Return Type  : emxArray_uint8_T *
 */
emxArray_uint8_T *emxCreateWrapperND_uint8_T(unsigned char *data,
                                             int numDimensions, const int *size)
{
  emxArray_uint8_T *emx;
  int i;
  int numEl;
  emxInit_uint8_T(&emx, numDimensions);
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
 * Arguments    : signed char *data
 *                int rows
 *                int cols
 * Return Type  : emxArray_int8_T *
 */
emxArray_int8_T *emxCreateWrapper_int8_T(signed char *data, int rows, int cols)
{
  emxArray_int8_T *emx;
  emxInit_int8_T(&emx, 2);
  emx->size[0] = rows;
  emx->size[1] = cols;
  emx->data = data;
  emx->numDimensions = 2;
  emx->allocatedSize = rows * cols;
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
 * Arguments    : unsigned char *data
 *                int rows
 *                int cols
 * Return Type  : emxArray_uint8_T *
 */
emxArray_uint8_T *emxCreateWrapper_uint8_T(unsigned char *data, int rows,
                                           int cols)
{
  emxArray_uint8_T *emx;
  emxInit_uint8_T(&emx, 2);
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
 * Return Type  : emxArray_int8_T *
 */
emxArray_int8_T *emxCreate_int8_T(int rows, int cols)
{
  emxArray_int8_T *emx;
  int numEl;
  emxInit_int8_T(&emx, 2);
  emx->size[0] = rows;
  numEl = rows * cols;
  emx->size[1] = cols;
  emx->data = (signed char *)calloc((unsigned int)numEl, sizeof(signed char));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
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
 * Arguments    : int rows
 *                int cols
 * Return Type  : emxArray_uint8_T *
 */
emxArray_uint8_T *emxCreate_uint8_T(int rows, int cols)
{
  emxArray_uint8_T *emx;
  int numEl;
  emxInit_uint8_T(&emx, 2);
  emx->size[0] = rows;
  numEl = rows * cols;
  emx->size[1] = cols;
  emx->data =
      (unsigned char *)calloc((unsigned int)numEl, sizeof(unsigned char));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : emxArray_int8_T *emxArray
 * Return Type  : void
 */
void emxDestroyArray_int8_T(emxArray_int8_T *emxArray)
{
  emxFree_int8_T(&emxArray);
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
 * Arguments    : emxArray_uint8_T *emxArray
 * Return Type  : void
 */
void emxDestroyArray_uint8_T(emxArray_uint8_T *emxArray)
{
  emxFree_uint8_T(&emxArray);
}

/*
 * Arguments    : emxArray_int8_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void emxInitArray_int8_T(emxArray_int8_T **pEmxArray, int numDimensions)
{
  emxInit_int8_T(pEmxArray, numDimensions);
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
 * Arguments    : emxArray_uint8_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void emxInitArray_uint8_T(emxArray_uint8_T **pEmxArray, int numDimensions)
{
  emxInit_uint8_T(pEmxArray, numDimensions);
}

/*
 * File trailer for NEDwaves_emxAPI.c
 *
 * [EOF]
 */
