% mglTestRefresh.m
%
%        $Id:$ 
%      usage: mglTestRefresh()
%         by: justin gardner
%       date: 10/06/11
%    purpose: Tests the refresh rate of the monitor. Note that with some video cards, notably
%             ATI Radeon HD 5xxx series, flushing the screen does not seem to wait for the vertical
%             blank and this will return a number very much larger than your refresh rate. See:
%
% http://gru.brain.riken.jp/doku.php/mgl/knownIssues#vertical_blanking_using_ati_videocards_radeon_hd

%
function retval = mglTestRefresh(screenNum)

% check arguments
if ~any(nargin == [0 1])
  help mglTestRefresh
  return
end


% decide which screen to open. With no arguments use initScreen
useInitScreen = false;
if nargin == 0, useInitScreen=true;end
if useInitScreen;
  myscreen = initScreen;
else
  mglOpen(screenNum);
end

% set test length
testLen = 600;
disp(sprintf('(mglTestRefresh) Testing refresh rate for %0.1f secs',testLen));

% checking refresh rate
startTime = mglGetSecs;
numRefresh = 0;
startFrameTime = mglGetSecs;
refreshTime = nan(1,120*testLen);
while(mglGetSecs(startTime) < testLen)
  if useInitScreen
    tickScreen(myscreen);
    mglClearScreen;
    mglTextDraw(sprintf('Testin refresh rate %f/%f',startFrameTime-startTime,testLen),[0 0]);
  else
    mglFlush;
  end
  numRefresh = numRefresh+1;
  % keep time it took to refresh
  endFrameTime = mglGetSecs;
  refreshTime(numRefresh) = endFrameTime-startFrameTime;
  startFrameTime = endFrameTime;
end

% toss out some of the early refresh times
refreshTime = refreshTime(10:numRefresh-1);

% close the screen
if useInitScreen
  endScreen(myscreen);
else
  mglClose;
end

% display computed refresh rate
disp(sprintf('(mglTestRefresh) Refresh rate: %f Hz',numRefresh/testLen));


hist(refreshTime*1000,100);
xlabel('Frame time (ms)');
ylabel('n');

