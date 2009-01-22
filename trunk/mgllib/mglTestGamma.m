% mglTestGamma.m
%
%        $Id$
%      usage: mglTestGamma()
%         by: justin gardner
%       date: 06/30/06
%  copyright: (c) 2006 Justin Gardner, Jonas Larsson (GPL see mgl/COPYING)
%    purpose: 
%
function retval = mglTestGamma(screenNumber)

% check arguments
if ~any(nargin == [0 1])
  help mglTestGamma
  return
end

% check for screenNum
if exist('screenNumber')~=1,screenNumber = [];,end

% display GUI
mglTestGammaGUI

% make sure the gui is visible before continuing
if isempty(screenNumber) || (screenNumber ~= 0)
%  uiwait(msgbox('Move mglTestGammaGUI so it will be visible','modal'));
end

% open up screen
mglOpen(screenNumber);
mglDisplayCursor(1);
mglVisualAngleCoordinates(57,[40 30]);

% change the gamma of the monitor
thisGamma = 1;
mglSetGammaTable(0,1,thisGamma,0,1,thisGamma,0,1,thisGamma);

% create a background of desired grayscale level
backgroundColor = 128;
backgroundBuffer(1:mglGetParam('screenHeight'),1:mglGetParam('screenWidth')) = backgroundColor;
backgroundTex = mglCreateTexture(backgroundBuffer);
% and draw it to the screen
mglBltTexture(backgroundTex,[0 0]);

% size of textures in degrees
texWidth = 8;
texHeight = 8;

% get size in pixels
texWidthPixels = round(texWidth*mglGetParam('xDeviceToPixels'));
texHeightPixels = round(texHeight*mglGetParam('yDeviceToPixels'));

% create the pattern
fineGrating(1:texHeightPixels,1:texWidthPixels) = -1;
fineGrating(:,1:2:texWidthPixels) = 1;

% contrasts to display
contrasts = [16 32 64];
% create the mgl texture, which desired contrast
for contrastNum = 1:length(contrasts)
  thisFineGrating = fineGrating;
  thisFineGrating(thisFineGrating==-1) = backgroundColor-contrasts(contrastNum);
  thisFineGrating(thisFineGrating==1) = backgroundColor+contrasts(contrastNum);
  fineGratingTex(contrastNum) = mglCreateTexture(thisFineGrating);
end

% calculate position
horizontalSpacing = (mglGetParam('deviceWidth')-texWidth*length(contrasts))/(length(contrasts)+1);

% now draw them to the screen
for contrastNum = 1:length(contrasts)
  mglBltTexture(fineGratingTex(contrastNum),[-mglGetParam('deviceWidth')/2+horizontalSpacing*contrastNum+texWidth*(contrastNum-1) 0],-1,0);
end

% flush the screen  
mglFlush;

% now mgTestGammaGUI takes care of the user interface and
% closing the screen
