#ifdef documentation
=========================================================================

     program: mglCreateTexture.c 
          by: justin gardner with add-ons by Jonas Larsson
        date: 04/09/06
     purpose: sets up a texture element to be in VRAM
              see Red book Chapter 9

=========================================================================
#endif

/////////////////////////
//   include section   //
/////////////////////////
#include "mgl.h"

////////////////////////
//   define section   //
////////////////////////
#define BYTEDEPTH 4

int sub2ind( int row, int col, int height, int elsize ) {
  // return linear index corresponding to (row,col) into Matlab array
  return ( row*elsize + col*height*elsize );
}

//////////////
//   main   //
//////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // declare some variables
  int i,j;

  // check for open window
  if (!mglIsWindowOpen()) {
    mexPrintf("(mgl) UHOH: No window is open\n");
    return;
  }

  // check input arguments
  if (nrhs > 2) {
    // if not supported, call matlab help on the file
    const int ndims = 1;
    const int dims[] = {1};
    mxArray *callInput[] = {mxCreateString("mglCreateTexture")};
    mexCallMATLAB(0,NULL,1,callInput,"help");
    return;
  }  

  // get status of global variable that sets wether to display
  // verbose information
  int verbose = (int)mglGetGlobalDouble("verbose");
  
  // check for null input pointer
  if (mxGetPr(prhs[0]) == NULL) {
    mexPrintf("UHOH: Input is empty\n");
    return;
  }

  // variables for dimensions
  const int *dims = mxGetDimensions(prhs[0]); // rows cols
  const int ndims = mxGetNumberOfDimensions(prhs[0]); 
  const int n = mxGetNumberOfElements(prhs[0]);

  // do some checks to see if the input arguments are valid
  // check if we have the right type
  if (!mxIsDouble(prhs[0])) {
    mexPrintf("UHOH: Input matrix should be of type double\n");
    return;
  }

  // check to see that we don't have too many dimensions
  if ((ndims != 2) && (ndims != 3)) {
    mexPrintf("UHOH: Input should be either nxm (grayscale), nxmx3 (color) or nxmx4 (color w/alpha)\n");
    return;
  }

  // make sure we have a valid number of pixel values
  if ((ndims == 3) && ((dims[2] != 1) && (dims[2] != 3) && (dims[2] != 4))) {
    mexPrintf("UHOH: Input should be either nxm (grayscale), nxmx3 (color) or nxmx4 (color w/alpha)\n");
    return;
  }

  // get image size and type
  int imageWidth = dims[1], imageHeight = dims[0]; // 
  
#ifndef GL_TEXTURE_RECTANGLE_EXT
  // No support for rectangular textures
  double lw=log(imageWidth)/log(2);
  double lh=log(imageHeight)/log(2);
  if (lw!=round(lw) | lh!=round(lh)) {
    mexPrintf("Sorry: only support for power-of-2 sized textures on this platform.\n");
    return;
  }
#endif
  
  int imageType;
  if (ndims == 2) imageType = 1; else imageType = dims[2];

  // if everything is ok, in verbose mode display some info
  if (verbose) {
    mexPrintf("imagesize (width x height): %ix%i (%i rows x %i columns) (%i dims) ",imageWidth,imageHeight,mxGetM(prhs[0]), mxGetN(prhs[0]),mxGetNumberOfDimensions(prhs[0]));
    switch (imageType) {
      case 1: mexPrintf("grayscale\n"); break;
      case 3: mexPrintf("color\n"); break;
      case 4: mexPrintf("color w/alpha\n"); break;
    }
  }

  // get the input image data
  double *imageData = mxGetPr(prhs[0]);

  // now create a temporary buffer for the image
  GLubyte *imageFormatted;
  imageFormatted = (GLubyte*)malloc(imageWidth*imageHeight*sizeof(GLubyte)*BYTEDEPTH);
  
  // and fill it with the image
  ////////////////////////////
  // grayscale image
  int c=0;
  if (imageType == 1) {
    for(i = 0; i < imageHeight; i++) { //rows
      for(j = 0; j < imageWidth; j++,c+=BYTEDEPTH) { //cols
	imageFormatted[c+0] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )];
	imageFormatted[c+1] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )];
	imageFormatted[c+2] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )];
	imageFormatted[c+3] = (GLubyte)255;

      }
    }
  }
  ////////////////////////////
  // color image
  else if (imageType == 3) {    
    for(i = 0; i < imageHeight; i++) { 
      for(j = 0; j < imageWidth;j++,c+=BYTEDEPTH) {
	imageFormatted[c+0] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )];
	imageFormatted[c+1] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )+imageWidth*imageHeight];
	imageFormatted[c+2] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )+imageWidth*imageHeight*2];
	imageFormatted[c+3] = (GLubyte)255;
      }
    }
  }
  ////////////////////////////
  // color+alpha image
  else if (imageType == 4) {
    for(i = 0; i < imageHeight; i++) {
      for(j = 0; j < imageWidth;j++,c+=BYTEDEPTH) {
	imageFormatted[c+0] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )];
	imageFormatted[c+1] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )+imageWidth*imageHeight];
	imageFormatted[c+2] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )+imageWidth*imageHeight*2];
	imageFormatted[c+3] = (GLubyte)imageData[sub2ind( i, j, imageHeight, 1 )+imageWidth*imageHeight*3];
      }
    }
  }

  GLuint textureNumber;

  // get a unique texture identifier name
  glGenTextures(1, &textureNumber);
  
  // bind the texture to be a 2D texture
#ifdef GL_TEXTURE_RECTANGLE_EXT
  glBindTexture(GL_TEXTURE_RECTANGLE_EXT, textureNumber);
#else
  glBindTexture(GL_TEXTURE_2D, textureNumber);
#endif

#ifdef __APPLE__
  // tell GL that the memory will be handled by us. (apple)
  glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE,0);

#ifdef GL_TEXTURE_RECTANGLE_EXT
  // now, try to store the memory in VRAM (apple)
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT,GL_TEXTURE_STORAGE_HINT_APPLE,GL_STORAGE_CACHED_APPLE);
  //  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT,GL_TEXTURE_STORAGE_HINT_APPLE,GL_STORAGE_SHARED_APPLE);
  glTextureRangeAPPLE(GL_TEXTURE_RECTANGLE_EXT,imageWidth*imageHeight*BYTEDEPTH,imageFormatted);
#else
  // now, try to store the memory in VRAM (apple)
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_STORAGE_HINT_APPLE,GL_STORAGE_CACHED_APPLE);
  //  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT,GL_TEXTURE_STORAGE_HINT_APPLE,GL_STORAGE_SHARED_APPLE);
  glTextureRangeAPPLE(GL_TEXTURE_2D,imageWidth*imageHeight*BYTEDEPTH,imageFormatted);

#endif
#endif

#ifdef GL_TEXTURE_RECTANGLE_EXT
  // some other stuff
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glPixelStorei(GL_UNPACK_ROW_LENGTH,0);

  // now place the data into the texture
  glTexImage2D(GL_TEXTURE_RECTANGLE_EXT,0,GL_RGBA,imageWidth,imageHeight,0,GL_RGBA,GL_UNSIGNED_INT_8_8_8_8,imageFormatted);
#else
  // some other stuff
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glPixelStorei(GL_UNPACK_ROW_LENGTH,0);

  // now place the data into the texture
  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,imageWidth,imageHeight,0,GL_RGBA,GL_UNSIGNED_INT_8_8_8_8,imageFormatted);

#endif    

  GLenum err=glGetError();
  if (err) {
    mexPrintf("%i\n", err);
  }
  // free temporary image storage
  free(imageFormatted);

  // create the output structure
  const char *fieldNames[] =  {"textureNumber","imageWidth","imageHeight","textureAxes" };
  int outDims[2] = {1, 1};
  plhs[0] = mxCreateStructArray(1,outDims,4,fieldNames);
  
  // now set the textureNumber field
  double *outptr;
  mxSetField(plhs[0],0,"textureNumber",mxCreateDoubleMatrix(1,1,mxREAL));
  outptr = (double*)mxGetPr(mxGetField(plhs[0],0,"textureNumber"));
  *outptr = (double)textureNumber;

  // now set the imageWidth and height and axis order
  char charptr[3];
  memset(charptr,0,3);
  if ( nrhs>1 ) {
    if (mxGetNumberOfElements( prhs[1] )==2) {
      mxGetString(prhs[1],charptr,3);
    }
  } else if (mglIsGlobal("defaultTextureAxes")) {    
    if (mxGetNumberOfElements( mglGetGlobalField("defaultTextureAxes") )==2) {
      mxGetString(mglGetGlobalField("defaultTextureAxes"),charptr,3);
    } 
  }

  if (*charptr==0) {
    mxSetField(plhs[0],0,"textureAxes",mxCreateString("yx"));  
  } else 
    mxSetField(plhs[0],0,"textureAxes",mxCreateString(charptr));  
  

  // set width and height
  mxSetField(plhs[0],0,"imageWidth",mxCreateDoubleMatrix(1,1,mxREAL));
  mxSetField(plhs[0],0,"imageHeight",mxCreateDoubleMatrix(1,1,mxREAL));

  if (strncmp(charptr,"xy",2)==0) {
    // transpose w & h
    outptr = (double*)mxGetPr(mxGetField(plhs[0],0,"imageHeight"));
    *outptr = (double)imageWidth;
    outptr = (double*)mxGetPr(mxGetField(plhs[0],0,"imageWidth"));
    *outptr = (double)imageHeight;

  } else {
    outptr = (double*)mxGetPr(mxGetField(plhs[0],0,"imageWidth"));
    *outptr = (double)imageWidth;
    outptr = (double*)mxGetPr(mxGetField(plhs[0],0,"imageHeight"));
    *outptr = (double)imageHeight;
  }

}
