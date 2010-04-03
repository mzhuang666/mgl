% initScreen.m
%
%        $Id$
%      usage: myscreen = initScreen(myscreen, randstate)
%         by: justin gardner
%       date: 12/10/04
%  copyright: (c) 2006 Justin Gardner (GPL see mgl/COPYING)
%    purpose: init screen parameters (using MGL)
%
function myscreen = initScreen(myscreen,randstate)

% get globals
global MGL;

% set version number
myscreen.ver = 1.1;

% get computer name
myscreen.computer = getHostName;
myscreen.tickcode = hex2dec('35');

% default monitor gamma (used when there is no calibration file)
defaultMonitorGamma = 1.8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% database parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screenParamsList = {'computerName','displayName','screenNumber',...
		    'screenWidth','screenHeight','displayDistance',...
		    'displaySize','framesPerSecond','autoCloseScreen',...
		    'saveData','monitorGamma','calibFilename','flipHV'};
screenParams{1} = {'yoyodyne.cns.nyu.edu','projector',2,1280,1024,57,[31 23],60,1,0,defaultMonitorGamma,'yoyodyne',[0 0]};
screenParams{end+1} = {'yoyodyne.cns.nyu.edu','lcd',2,1280,1024,157.5,[43.2 32.5],60,1,0,defaultMonitorGamma,'yoyodyne',[0 0]};

screenParams{end+1} = {'Stimulus.local','projector',2,1024,768,57,[31 23],60,0,50,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'Stimulus.local','lcd',2,800,600,157.5,[43.2 32.5],60,0,50,[0 1 0.4790 0 1 0.4790 0 1 0.4790],'',[1 0]};
screenParams{end+1} = {'stimulus-g5.local','projector',2,1024,768,57,[31 23],60,0,50,defaultMonitorGamma,'stimulus-g5_projector',[0 0]};
screenParams{end+1} = {'stimulus-g5.local','lcd',2,800,600,157.5,[43.2 32.5],60,0,50,[0 1 0.4790 0 1 0.4790 0 1 0.4790],'',[0 0]};
%screenParams{end+1} = {'eigenstate','',0,1440,900,57,[31 23],60,1,0,defaultMonitorGamma,''};
screenParams{end+1} = {'eigenstate','',0,800,600,57,[31 23],60,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'eigenworld','',0,1440,900,57,[31 23],60,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'dhcp.bnf.brain.riken.jp','',0,1024,768,57,[31 23],60,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'alta','',[],1024,768,57,[31 23],60,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'dsltop','',0,400,300,57,[18 24],60,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'whistler.cns.nyu.edu','',2,1280,1024,57,[31 23],60,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'froh.cns.nyu.edu','',[],1280,1024,57,[31 23],100,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'jackson','',2,1152,870,57,[43.2 32.5],75,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'cronos.psychology.nottingham.ac.uk','',2,1280,1024,57,[31 23],100,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'hyperion.local','',0,800,600,57,[31 23],100,1,0,defaultMonitorGamma,'',[0 0]};
screenParams{end+1} = {'tejas.cns.nyu.edu', '', 2, 1680, 1050, 57, [31 23], 60, 1, 0, defaultMonitorGamma, '',[0 0]};

if isfield(myscreen,'screenParams')
  screenParams = cat(2,myscreen.screenParams,screenParams);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find matching database parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foundComputer = 0;
for pnum = 1:length(screenParams)
  if ~foundComputer && ~isempty(strfind(myscreen.computer,screenParams{pnum}{1}))
    if isempty(screenParams{pnum}{2}) || ~isfield(myscreen,'displayname') || (isfield(myscreen,'displayname') && strcmp(myscreen.displayname,screenParams{pnum}{2}))
      foundComputer = 1;
      % if we find a match then set the parameters accordingly
      if ~isempty(screenParams{pnum}{2})
	disp(sprintf('(initScreen) Monitor parameters for: %s displayName: %s',screenParams{pnum}{1},screenParams{pnum}{2}));
      else
	disp(sprintf('(initScreen) Monitor parameters for: %s',screenParams{pnum}{1}));
      end
      % setup all parameters for the monitor (if the settings are
      % already set then do nothing
      for j = 3:length(screenParams{pnum})
	if ~isfield(myscreen,screenParamsList{j})
	  eval(sprintf('myscreen.%s = screenParams{pnum}{%i};',screenParamsList{j},j));
	end
      end
      if ~isempty(myscreen.displayDistance) & ~isempty(myscreen.displaySize)
	disp(sprintf('(initScreen) %i: %ix%i(pix) dist:%0.1f (cm) size:%0.1fx%0.1f (cm) %iHz save:%i autoclose:%i flipHV:[%i %i]',myscreen.screenNumber,myscreen.screenWidth,myscreen.screenHeight,myscreen.displayDistance,myscreen.displaySize(1),myscreen.displaySize(2),myscreen.framesPerSecond,myscreen.saveData,myscreen.autoCloseScreen,myscreen.flipHV(1),myscreen.flipHV(2)));
      end
    end
  end
end

% check to make sure that we have found the computer in the table
if ~foundComputer
  disp(sprintf('(initScreen) Could not find computer %s in initScreen',myscreen.computer));
end

%%%%%%%%%%%%%%%%%
% defaults if they have not been set
%%%%%%%%%%%%%%%%%
if ~isfield(myscreen,'autoCloseScreen'),myscreen.autoCloseScreen = 1;end
if ~isfield(myscreen,'screenNumber'),myscreen.screenNumber = [];end
if ~isfield(myscreen,'screenWidth'),myscreen.screenWidth = 1024;end
if ~isfield(myscreen,'screenHeight'),myscreen.screenHeight = 768;end
if ~isfield(myscreen,'framesPerSecond'),myscreen.framesPerSecond = 60;end
if ~isfield(myscreen,'saveData'),myscreen.saveData = -1;end
if ~isfield(myscreen,'displayDistance'),myscreen.displayDistance = 57;end
if ~isfield(myscreen,'displaySize'),myscreen.displaySize = [31 23];end
if ~isfield(myscreen,'flipHV'),myscreen.flipHV = [0 0];end

% remember curent path
myscreen.pwd = pwd;

% decided where to store data
if ~isfield(myscreen,'datadir')
  myscreen.datadir = '~/data';
end

if ~isdir(myscreen.datadir)
 disp(sprintf('(initScreen) Could not find directory %s. Using current directory',myscreen.datadir));
 % use current directory instead
 myscreen.datadir = '';
end

% compute the time per frame
myscreen.frametime = 1/myscreen.framesPerSecond;

% get matlab version
matlabVersion = version;
myscreen.matlab.version = matlabVersion;
[matlabMajorVersion matlabVersion] = strtok(matlabVersion,'.');
myscreen.matlab.majorVersion = str2num(matlabMajorVersion);
myscreen.matlab.minorVersion = str2num(strtok(matlabVersion,'.'));

% decide which rand algorithim to use
if (myscreen.matlab.majorVersion>=7) && (myscreen.matlab.minorVersion>=4)
    myscreen.randstate.type = 'twister';
else
    myscreen.randstate.type = 'state';
end

% save rand number generator state
if ~exist('randstate','var') || isempty(randstate)
  % no passed in value, set to a random state
  myscreen.randstate.state = sum(100*clock);
else
  % use passed in randstate
  if ~isstruct(randstate)
    % set the state
    myscreen.randstate.state = randstate;
    % old way, in which the 'state' value was returned
    if ~isscalar(randstate)
      myscreen.randstate.type = 'state';
    end
    %new way in which a structure is saved
  else
    myscreen.randstate = randstate;
  end
end
% now set the state of the random number generator
rand(myscreen.randstate.type,myscreen.randstate.state);

% don't allow pause unless explicitly passed in
if ~isfield(myscreen,'allowpause')
  myscreen.allowpause = 0;
end
myscreen.paused = 0;

% init the MGL screen
if ~isempty(myscreen.screenNumber)
  % setting with specified screenNumber
  mglOpen(myscreen.screenNumber, myscreen.screenWidth, myscreen.screenHeight, myscreen.framesPerSecond);
else
  % otherwise open a default window
  mglOpen;
  myscreen.screenWidth = MGL.screenWidth;
  myscreen.screenHeight = MGL.screenHeight;
end

% use visual angle coordinates
% if monitor size is set, then this is a value
% in inches along the diagonal of the screen
if isempty(myscreen.displayDistance) | isempty(myscreen.displaySize)
  disp('(initScreen) Could not find display parameters');
  return
end

mglVisualAngleCoordinates(myscreen.displayDistance,myscreen.displaySize);
myscreen.imageWidth = MGL.deviceWidth;
myscreen.imageHeight = MGL.deviceHeight;

% flip the screen appropriately
if myscreen.flipHV(1)
  disp('(initScreen) Flipping coordinates horizontally');
  mglHFlip;
end
if myscreen.flipHV(2)
  disp('(initScreen) Flipping coordinates vertically');
  mglVFlip;
end
  
% set up indexes appropriately
myscreen.black = 0;myscreen.white = 1;myscreen.gray = 0.5;
myscreen.blackIndex = 0;
myscreen.whiteIndex = 255;
myscreen.grayIndex = 128;
myscreen.inc = myscreen.whiteIndex - myscreen.grayIndex;

% but first go and check if we need to load a table
gammaNotSet = 1;

if isfield(myscreen,'calibFilename') && ~isempty(myscreen.calibFilename)
  calibFilename = myscreen.calibFilename;
  % if the user specified a particular name for the calibration file.
  % this could either be an exact filename, or it could be one of a standard
  % set i.e. 0001_yoyodyne_LCD2_061013, so we check for those types
  % if we can't find the exact match
  if ~isfile(sprintf('%s.mat',calibFilename))
    calibFilename = getCalibFilename(myscreen,calibFilename);
  end
else
  calibFilename = getCalibFilename(myscreen,myscreen.computer);
end

if ~isempty(calibFilename)
  if isfile(sprintf('%s.mat',calibFilename))
    load(calibFilename);
    if exist('calib','var') && isfield(calib,'table')
      myscreen.gammaTable = calib.table;
      mglSetGammaTable(myscreen.gammaTable);
      gammaNotSet = 0;
      [calibPath calibFilename] = fileparts(calibFilename);
      disp(sprintf('(initScreen) Gamma: Set to table from calibration file %s created on %s',calibFilename,calib.date));
    end
  else
    disp(sprintf('(initScreen) Could not find montior calibration file %s',calibFilename));
  end
end

% use the table if we do not have a valid filename
if gammaNotSet
  if ~isfield(myscreen,'monitorGamma')
    myscreen.monitorGamma = defaultMonitorGamma;
  end
  % display what the settings are
  disp(sprintf('(initScreen) Correcting for monitor gamma of %0.2f',myscreen.monitorGamma));
  
  % now get current gamma table
  global MGL;
  gammaTable = MGL.initialGammaTable;
  % and use linear interpolation to correct the current table to
  % make it 1/monitor gamma.
  correctedValues = ((0:1/255:1).^(1/myscreen.monitorGamma));
  gammaTable.redTable = interp1(0:1/255:1,gammaTable.redTable,correctedValues);
  gammaTable.greenTable = interp1(0:1/255:1,gammaTable.greenTable,correctedValues);
  gammaTable.blueTable = interp1(0:1/255:1,gammaTable.blueTable,correctedValues);
  % and set the table
  mglSetGammaTable(gammaTable);
end

% choose color for background
if isfield(myscreen,'background')
  if isstr(myscreen.background) 
    if strcmp(myscreen.background,'white')
      myscreen.background = myscreen.white;
    elseif strcmp(myscreen.background,'black')
      myscreen.background = myscreen.black;
    elseif strcmp(myscreen.background,'gray')
      myscreen.background = myscreen.gray;
    else
      disp(sprintf('(initScreen) Background color %s does not exist',myscreen.background));
      myscreen.background = myscreen.black;
    end
  end
else
  myscreen.background = myscreen.black;
end

% set background color  - MGL
mglClearScreen(myscreen.background);
mglFlush();
mglClearScreen(myscreen.background);
mglFlush();

disp(sprintf('(initScreen) imageWidth: %0.2f imageHeight: %0.2f',myscreen.imageWidth,myscreen.imageHeight));

% init number of ticks
myscreen.tick = 1;
myscreen.totaltick = 1;
myscreen.totalflip = 0;
myscreen.volnum = 0;
myscreen.intick = 0;
myscreen.fliptime = inf;
myscreen.dropcount = 0;
myscreen.checkForDroppedFrames = 1;
myscreen.dropThreshold = 1.05;

% set keyboard info
myscreen.keyboard.esc = 54;
myscreen.keyboard.return = 37;
myscreen.keyboard.space = mglCharToKeycode({' '});
myscreen.keyboard.backtick = mglCharToKeycode({'`'});
if ~isfield(myscreen.keyboard,'nums')
  myscreen.keyboard.nums = mglCharToKeycode({'1' '2' '3' '4' '5' '6' '7' '8' '9' '0'});
end

%init traces
numinit = 3000;
myscreen.events.n = 0;
myscreen.events.tracenum = zeros(1,numinit);
myscreen.events.data = zeros(1,numinit);
myscreen.events.ticknum = zeros(1,numinit);
myscreen.events.volnum = zeros(1,numinit);
myscreen.events.time = zeros(1,numinit);

% first stimtrace is reserved for acq pulses
% second is for segment times
% third is for response times
% fourth is for task phase
% fifth is for fix task
myscreen.stimtrace = 6;

% save the beginning of time
myscreen.starttime = datestr(clock);
myscreen.time = mglGetSecs;

global gNumSaves;

% get the number of the next save file, so that
% we can put that into the eye tracker xdat
if (isempty(gNumSaves))
  tracknum = 1;
else
  tracknum = gNumSaves+1;
end

% get filename
thedate = [datestr(now,'yy') datestr(now,'mm') datestr(now,'dd')];
filename = sprintf('%s_stim%02i',thedate,tracknum);

% now create an output for the tracker
% with the tracknum shift up 8 bits
myscreen.fishcamp = bitshift(tracknum,1);

% set up text
mglTextSet('Helvetica',24,[1 1 1],0,0,0,0,0,0,0);

% set up eye calibration stuff
myscreen.eyecalib.prompt = 1;
%myscreen.eyecalib.x = [0 0 -5 0  0 0 5 0 0 0];
%myscreen.eyecalib.y = [0 0  0 0 -5 0 0 0 5 0];
myscreen.eyecalib.x = [0 0 -5 0  0 0 5 0 0 0 3.5 0 -3.5 0  3.5 0 -3.5 0];
myscreen.eyecalib.y = [0 0  0 0 -5 0 0 0 5 0 3.5 0 -3.5 0 -3.5 0  3.5 0];
myscreen.eyecalib.n = length(myscreen.eyecalib.x);
myscreen.eyecalib.size = [0.2 0.2];
myscreen.eyecalib.color = [1 1 0];
myscreen.eyecalib.waittime = 1;

% init stimulus names if it does not exist already
if ~isfield(myscreen,'stimulusNames')
  myscreen.stimulusNames = {};
end

% default values
myscreen.userHitEsc = 0;
myscreen.flushMode = 0;
myscreen.makeTraces = 0;
myscreen.numTasks = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% support function that gets host name using system command
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hostname = getHostName()

[retval hostname] = system('hostname');
% sometimes there is more than one line (errors from csh startup)
% so need to strip those off
hostname = strread(hostname,'%s','delimiter','\n');
hostname = hostname{end};
if (retval == 0)
  % get it again
  [retval hostname2] = system('hostname');
  hostname2 = strread(hostname2,'%s','delimiter','\n');
  hostname2 = hostname2{end};
  if (retval == 0)
    % find the matching last characers
    % this is necessary, because matlab's system command
    % picks up stray key strokes being written into
    % the terminal but puts those at the beginning of
    % what is returned by stysem. so we run the
    % command twice and find the matching end part of
    % the string to get the hostrname
    minlen = min(length(hostname),length(hostname2));
    for k = 0:minlen
      if (k < minlen)
	if hostname(length(hostname)-k) ~= hostname2(length(hostname2)-k)
	  break
	end
      end
    end
    if (k > 0)
      hostname = hostname(length(hostname)-k+1:length(hostname));
      hostname = lower(hostname);
      hostname = hostname(find(((hostname <= 'z') & (hostname >= 'a')) | '.'));
    else
      hostname = 'unknown';
    end
  else
    hostname = 'unknown';
  end
else
  hostname = 'unknown';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if it is a file
%%%%%%%%%%%%%%%%%%%%%%%%%%
function retval = isfile(filename)

if (nargin ~= 1)
  help isfile;
  return
end

% open file
fid = fopen(filename,'r');

% check to see if there was an error
if (fid ~= -1)
  fclose(fid);
  retval = 1;
else
  retval = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gets the name of the gamma calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filename = getCalibFilename(myscreen,hostname)

% get the ouptut filename, first if there are dots in
% the name get the beginning, that way we don't
% have to deal with differences between
% computername.nework.edu and computername...
if ~isempty(strfind(hostname,'.'))
  hostname = strread(hostname,'%s','delimiter','.');
  hostname = hostname{1};
end

% now look in the current directory for displays
filenames = dir(fullfile(myscreen.pwd,sprintf('displays/*%s*',hostname)));

% if we haven't found any files in current directory then look in task directory
if length(filenames) == 0
  defaultdir = sprintf('%s/displays/*%s*',fileparts(which('initScreen')),hostname);
  filenames = dir(defaultdir);
end

% init variables
maxnum = 0;
filename = '';

% now look at the files we have and choose the one with the highest
% sequence number
for i = 1:length(filenames)
  filenum = strread(filenames(i).name,'%s','delimiter','_');
  filenum = str2num(filenum{1});
  if (filenum > maxnum)
    maxnum = filenum;
    [path name] = fileparts(filenames(i).name);
    filename = sprintf('%s/task/displays/%s',fileparts(fileparts(which('initScreen'))),name);
  end
end
