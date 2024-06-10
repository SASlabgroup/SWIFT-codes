//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_processSIGburst_onboard_lowmem_info.cpp
//
// Code generation for function 'processSIGburst_onboard_lowmem'
//

// Include files
#include "_coder_processSIGburst_onboard_lowmem_info.h"
#include "emlrt.h"
#include "tmwtypes.h"

// Function Declarations
static const mxArray *emlrtMexFcnResolvedFunctionsInfo();

// Function Definitions
static const mxArray *emlrtMexFcnResolvedFunctionsInfo()
{
  const mxArray *nameCaptureInfo;
  const char_T *data[5] = {
      "789ced54cd4ec24010de1a4c3cf8d39377136e1a124c8cf1681443134a4088215a83a55d"
      "6cc36e976c1785a7d0c7f0e82378f50d7c1c69bb85b6b2b6818897ce"
      "8199c9b73bdfb75fc90049512500c02e08a2ba1de41ddecb3c6f8078247129714e8a1f07"
      "9ba010bb17e22f3c1bc46170cc82c6d1319cdd3409b61ddd61edc910",
      "020a5d829ea0e9237d1bc1b68d612bdad4bd0e5f45a059e3415e7d614163d01a61402d77"
      "ae10459b991fef82f71632fa5113f82127f03ba5d6a9dc17b1ce90de"
      "a384b0a2c608413d32d620461ab27b5a8069438226fd91a3d953c3e8b05cc2528b51db79"
      "6c1315328b98ca6554ffeb8afa8f52f487b8414c484bbe2647474131",
      "55aa33c8eb409c5b71a6be47f43d2ca92f19227d61847c1f4bf285f3bb297c21ee7dcffa"
      "e2efe95a3a85a6e63bc67f0f790afde35560a0f6c3c0124ef56f2fe3"
      "7b92797e7ecbcfcd832f1f5a171fe89c7fae958fc77ff18d05f3b2fe1ff7057c72025795"
      "c6c90db44f6fcfd4e36b83d0262e2bb43ad7d148e149d30104fdbae6",
      "bf09ee67f5b12a982f27f055f634afbacf840ef2fd1c8f7c3f2f7e4fbe9f83c8f7f3ef3c"
      "693a80a0ffebf9df885ff4d1",
      ""};
  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(&data[0], 3168U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties()
{
  mxArray *xEntryPoints;
  mxArray *xInputs;
  mxArray *xResult;
  const char_T *propFieldName[7] = {
      "Version",      "ResolvedFunctions", "Checksum",    "EntryPoints",
      "CoverageInfo", "IsPolymorphic",     "PropertyList"};
  const char_T *epFieldName[6] = {
      "Name",           "NumberOfInputs", "NumberOfOutputs",
      "ConstantInputs", "FullPath",       "TimeStamp"};
  xEntryPoints =
      emlrtCreateStructMatrix(1, 1, 6, (const char_T **)&epFieldName[0]);
  xInputs = emlrtCreateLogicalMatrix(1, 10);
  emlrtSetField(xEntryPoints, 0, "Name",
                emlrtMxCreateString("processSIGburst_onboard_lowmem"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs",
                emlrtMxCreateDoubleScalar(10.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(xEntryPoints, 0, "FullPath",
                emlrtMxCreateString(
                    "C:\\Users\\Kristin "
                    "Zeiden\\GitHub\\MATLAB\\SWIFT-"
                    "codes\\Signature\\processSIGburst_onboard_lowmem.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp",
                emlrtMxCreateDoubleScalar(739413.41054398147));
  xResult =
      emlrtCreateStructMatrix(1, 1, 7, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, "Version",
                emlrtMxCreateString("9.14.0.2306882 (R2023a) Update 4"));
  emlrtSetField(xResult, 0, "ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "Checksum",
                emlrtMxCreateString("yKukzwnq1qOULn6frPzErF"));
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

// End of code generation (_coder_processSIGburst_onboard_lowmem_info.cpp)
