function [myscreen] = eyeCalibrationEyelink(myscreen)
% eyeCalibrationEyelink - initializes a the myscreen and tracker for use
%
%

% eyeCalibrationEyelink.m
%
%        $Id: eyeCalibrationEyelink.m 203 2007-03-19 15:41:00Z justin $
%      usage: myscreen = eyeCalibrationEyelink(myscreen)
%         by: eric dewitt
%       date: 2009-03-10
%  copyright: (c) 2006 Justin Gardner (GPL see mgl/COPYING)
%             (c) Copyright 2009 Eric DeWitt. All Rights Reserved. 
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

    if ~myscreen.eyetracker.dummymode
        fprintf(2,'(eyeCalibrationEyelink) Calibrating Eyelink.\n');
        mglPrivateEyelinkCalibration;
    else
        fprintf(2,'(eyeCalibrationEyelink) Skipping calibration in dummy mode.\n');
    end
end