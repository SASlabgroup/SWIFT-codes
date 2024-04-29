//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_processSIGburst_onboard_info.cpp
//
// Code generation for function 'processSIGburst_onboard'
//

// Include files
#include "_coder_processSIGburst_onboard_info.h"
#include "emlrt.h"
#include "tmwtypes.h"

// Function Declarations
static const mxArray *emlrtMexFcnResolvedFunctionsInfo();

// Function Definitions
static const mxArray *emlrtMexFcnResolvedFunctionsInfo()
{
  const mxArray *nameCaptureInfo;
  const char_T *data[7]{
      "789ced58cb6e1331149d40796c80ac58b141ea0e88d48a8260d736493b6dd2a6cd941670"
      "15e6e13443fd486d4f49f909fa192cf9842e58002b96b040427c0362"
      "cd4c3c794d6b26906890d2b98bd83727f6b98ff858b296d1cb194dd3ae6bd28e6fc9f15a"
      "e867c3f1823668513c138e9722bed6fd7e6a605d077f138e362502b6",
      "847488896177a543b14b4c228ca326d418e4141d42a78dd45d040d17c36abfb31678b8d8"
      "07759d000ae68b0d68ef573dacb106ef4588fa9d6e3d4e14f94e0d59"
      "8fa78a7a6423f8f3c2eee263b0c521e360bfee8ad760c9150dcf02e579a334bf008a1eb1"
      "854b0907d56dbd68dcb3a903fdb9bb474ce131089a8cda90f3aabe64",
      "798c8b1a2516359993c3917c5e8c98cf15653e12f13b85a149c6c67759c92711877a1682"
      "bdfcde8dc85752f20de2a7fb9567b469d1d6e9862d1af98aec8e4bf6"
      "802d9c5ad0ac5910964ab628ae5e37868c3f3af67e7fb53dfe10ef3349f2691ff8b744f9"
      "42fb5f7c2dc57ec3feff6e2af8b2115caf6f1807f9d6c16c858b22df",
      "9a5929ad54d7977b71546278e2e2d0147e52fb27768ef5d24e61771a9b029916a3544c03"
      "41290a0e32c40820d70212034d8a8eea1e01ae7f51b1e64c0e67aa82"
      "f927daa065281ad4d1f3fdf11f8f18ffdd98f83b78700fb05c3b26622239f12335050ce7"
      "32385e20de503a13175fd454f1756c5cf7682d86af8307fd5c3bbb9f",
      "bc6132e88076c5c2cf3be1d0a95f38930504a70ae84b7552bab271fb4bb23abd33ff3151"
      "bed0265da7cb7a65ee09741f3e7b549eddb429dbc0333a9b209d7eab"
      "583f6c1d9715fb6723f8283a1dce6aaf28db4ff579d0527d3e3b9f549fa5a5fafc679eb8"
      "3834859fd4fe278af5e7f5fde2a2321f89405a1f2bdfdfbe5f24769f",
      "fe53bf962081cc4486afd81cf8a5cae1a4f461fbf3d744f5f6e7af4fdf93e4ebd8a4ebed"
      "d1c1cadaeae6fa6a8117d0fd07f870ced65fa285c9d1db493bbfe9bb"
      "b0b4f45d78bc7ce9bbb0b4f45d78b8fd7f03fa10f9c7",
      ""};
  nameCaptureInfo = nullptr;
  emlrtNameCaptureMxArrayR2016a(&data[0], 7336U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties()
{
  mxArray *xEntryPoints;
  mxArray *xInputs;
  mxArray *xResult;
  const char_T *propFieldName[7]{
      "Version",      "ResolvedFunctions", "Checksum",    "EntryPoints",
      "CoverageInfo", "IsPolymorphic",     "PropertyList"};
  const char_T *epFieldName[6]{
      "Name",           "NumberOfInputs", "NumberOfOutputs",
      "ConstantInputs", "FullPath",       "TimeStamp"};
  xEntryPoints =
      emlrtCreateStructMatrix(1, 1, 6, (const char_T **)&epFieldName[0]);
  xInputs = emlrtCreateLogicalMatrix(1, 10);
  emlrtSetField(xEntryPoints, 0, "Name",
                emlrtMxCreateString("processSIGburst_onboard"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs",
                emlrtMxCreateDoubleScalar(10.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 0, "FullPath",
      emlrtMxCreateString("C:\\Users\\kfitz\\Github\\MATLAB\\Functions\\SWIFT-"
                          "codes\\Signature\\processSIGburst_onboard.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp",
                emlrtMxCreateDoubleScalar(739371.28196759254));
  xResult =
      emlrtCreateStructMatrix(1, 1, 7, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, "Version",
                emlrtMxCreateString("9.14.0.2489007 (R2023a) Update 6"));
  emlrtSetField(xResult, 0, "ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "Checksum",
                emlrtMxCreateString("PZQFgSowDqYBMHr9fmWcLC"));
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

// End of code generation (_coder_processSIGburst_onboard_info.cpp)
