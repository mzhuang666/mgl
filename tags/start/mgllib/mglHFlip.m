% mglHFlip.m
%
%      usage: mglHFlip()
%         by: justin gardner
%       date: 09/06/06
%    purpose: flips coordinate frame horizontally, useful for when
%             the display is viewed through a mirror
%       e.g.:
%
%mglOpen
%mglVisualAngleCoordinates(57,[16 12]);
%mglHFlip
%mglTextSet('Helvetica',32,1,0,0,0,0,0,0,0);
%mglTextDraw('Mirror reversed',[0 0]);
%mglFlush;
function mglHFlip()

% check arguments
if ~any(nargin == [0])
  help mglHFlip
  return
end

global MGL;

% flip the modelviews horizontal axis
mglTransform('GL_MODELVIEW','glScale',-1,1,1);