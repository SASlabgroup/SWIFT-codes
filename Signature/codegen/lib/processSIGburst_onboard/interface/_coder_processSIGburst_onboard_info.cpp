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
  const char_T *data[6] = {
      "789ced564b6f13311076a03c2e40b87006a9372052222104b79047b3252909bb81a87595"
      "eec369acaeedd4f642fa2be06770e4c8910307f8075cb8f04bc866bd"
      "792c75376a4a90aacc21e3d117cff7cd4c7636206334320080db20b2af77237f4bc559e5"
      "af80794be219e5af26e2d8ae818db97b31fe417997518986320aa84d",
      "d0e4a6c708a63695d6c900018e04f3df216f8cf4b08f2c4c90391bec8411a9ce40932084"
      "c273a98fdc23332080f7c554a13f1b4cfaf14553efc682fde868fa91"
      "4de07b95fdd273d816880bf892632131bdbf8bb08728dcc2b21638b051b4eac517d07c6b"
      "54adc72ef39080263ea4b60c388203ce5c2484696c390117b2cba8c3",
      "6ceee5485cc7c19275dcd0d61121a30911645370517cd7b57c11e2b1c0f1d1c5cda9ade5"
      "9bc7cf985399b381c386f1a0aa0175256654c092556e46f3c1f410ba"
      "d2eb86e32a40d5b31c0120b56f7716ac23e9a7dfbf39f6bfe5b731b42a3ef05dfc5a299f"
      "b2ffc537d4e45bf477784fc3974de046af651d9787c785a69055d1ce",
      "6fd7b7cd57b5a98e660a4f9a0ea0895795ffb3e6fea27dac6bf26713f89e51ef54f63789"
      "2d7ddbe18cc94d2819f3c3e718111ffad881110607cc3fe90514e2d1"
      "8b8a0ff2399231251f3dd0166b20d9679e519ed5ff7149fd8f52f4c778f822e0b9b1266a"
      "fbd161a4d496489d2371a2420332abefe09cfa92a6d317dbe47fc539",
      "f9e2fcdd14be180fe7b973fa3c45dfe6c883e38ea9cf87cac5fd53a7a881f0af068e36f5"
      "aaf64aebc1cfd5eee94ef1c74af9945df63ddd309a4fde20fc74f759"
      "a3f0da65bc45f206bf447bfa93e6fea27dac69f26713f8327b5a9dbaef193f5aefe7795b"
      "efe7d3eb59efe7c8d6fbf96c9e341d4013ffebfc7f002dc951b8",
      ""};
  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(&data[0], 4568U, &nameCaptureInfo);
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
                emlrtMxCreateString("processSIGburst_onboard"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs",
                emlrtMxCreateDoubleScalar(10.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 0, "FullPath",
      emlrtMxCreateString("C:\\Users\\Kristin "
                          "Zeiden\\GitHub\\MATLAB\\SWIFT-"
                          "codes\\Signature\\processSIGburst_onboard.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp",
                emlrtMxCreateDoubleScalar(739387.62267361116));
  xResult =
      emlrtCreateStructMatrix(1, 1, 7, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, "Version",
                emlrtMxCreateString("9.14.0.2306882 (R2023a) Update 4"));
  emlrtSetField(xResult, 0, "ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "Checksum",
                emlrtMxCreateString("ihubGURWpOzIOqyLTTzzME"));
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

// End of code generation (_coder_processSIGburst_onboard_info.cpp)
