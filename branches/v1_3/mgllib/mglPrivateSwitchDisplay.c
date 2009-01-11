#ifdef documentation
=========================================================================

     program: mglPrivateSwitchDisplay.c
          by: Christopher Broussard
        date: 04/03/06
   copyright: (c) 2006 Justin Gardner, Jonas Larsson (GPL see mgl/COPYING)
     purpose: Switches witch display/window is active.

$Id$
=========================================================================
#endif

/////////////////////////
//   include section   //
/////////////////////////
#include "mgl.h"


//////////////
//   main   //
//////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int displayNumber;
  
  if (nrhs != 0) {
    usageError("mglSwitchDisplay");
    return;
  }
	
  displayNumber = (int)mglGetGlobalDouble("displayNumber");
	
  if (displayNumber > 0) {
    CGLContextObj contextObj;
    unsigned int c;
    
    c = (unsigned int)mglGetGlobalDouble("context");
    contextObj = (CGLContextObj)c;
    
    CGLSetCurrentContext(contextObj);
  }
}