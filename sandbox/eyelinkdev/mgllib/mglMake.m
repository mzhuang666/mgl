% mglMake.m
%
%        $Id$
%      usage: mglMake(rebuild)
%         by: justin gardner
%       date: 05/04/06
%  copyright: (c) 2006 Justin Gardner, Jonas Larsson (GPL see mgl/COPYING)
%    purpose: rebuilds mex file, with no arguments checks
%             dates to see whether it should rebuild. With
%             rebuild set to 1 removes all mex files for
%             the current platform and ebuilds; rebuild can also
%             specify 'carbon' or 'cocoa' or the defines. additional
%             arguments are treated as mex arguments
%    
%
function retval = mglMake(rebuild, varargin)

    % check arguments
    if any(nargin > 10) % arbitrary...
        help mglMake
        return
    end

    % interpret rebuild argument
    digio = 0;
    if ~exist('rebuild','var')
        rebuild=0;
        if isequal(computer,'MAC')
            varargin = {'-D__carbon__', varargin{:}};
        end            
    else
        if isequal(rebuild,1) || isequal(rebuild,'rebuild')
            rebuild = 1;
        elseif isequal(rebuild,'carbon')
            varargin = {'-D__carbon__', varargin{:}};
            rebuild = 1;
        elseif isequal(rebuild,'cocoa')
            varargin = {'-D__cocoa__', varargin{:}};
            rebuild = 1;
        elseif isequal(rebuild,'digio')
            rebuild = 0;
            digio = 1;
        elseif ischar(rebuild) && isequal(rebuild(1), '-')
            varargin = {rebuild, varargin{:}};
            rebuild=0;
        else
            help mglMake
            return
        end
    end
    for nArg = 1:numel(varargin)
        if ischar(varargin{nArg}) && isequal(varargin{nArg}(1), '-')
            arg(nArg).name = varargin{nArg};
        else
            error('Attempted to pass an argument that is not a mex option.');
        end
    end
                
    
    % if we find the mglPrivateListener, then shut it down
    % to avoid crashing
    if exist('mglPrivateListener')==3
        mglPrivateListener(0);
    end
    if exist('mglPrivatePostEvent')==3
        mglPrivatePostEvent(0);
    end

    % close all open displays
    mglSwitchDisplay(-1);

    % clear the MGL global
    clear global MGL;
    
    lastPath = pwd;
    % make sure we have the mgl.h file--this will make
    % sure we are in the correct directory
    hfile = dir('mgl.h');
    if isempty(hfile)
        % try to switch to the diretory where mglOpen lives
        mgldir = mglGetParam('mgllibDir');
        if ~isempty(mgldir) && exist(fullfile(mgldir,'mgl.h'), 'file') % test for header
            cd(mgldir);
            hfile = dir('mgl.h');
        else
            return
        end
    else
        mgldir = pwd;
    end

    % get mgldirs
    mglsubdir = dir(fullfile(mgldir,'mgl*'));
    mglsubdir = mglsubdir([mglsubdir.isdir]==1);

    % set directories to check for mex files to compile
    mexdir{1} = mgldir;
    for nDir = 1:numel(mglsubdir)
        mexdir{nDir+1} = fullfile(mgldir,mglsubdir(nDir).name);
    end

    for nDir = 1:numel(mexdir)
        % get the files in the mexdir
        cd(mexdir{nDir});
        sourcefile = dir('*.c');
        for i = 1:length(sourcefile)
            if (~strcmp('.#',sourcefile(i).name(1:2))) % what is this check for???
                % see if it is already compiled
                mexname = [stripext(sourcefile(i).name) '.' mexext];
                mexfile = dir(mexname);
                % mex the file if either there is no mexfile or
                % the date of the mexfile is older than the date of the source file
                if (rebuild || length(mexfile)<1) || ...
                    (datenum(sourcefile(i).date) > datenum(mexfile(1).date)) || ...
                    (datenum(hfile(1).date) > datenum(mexfile(1).date))
                    command = sprintf('mex ');
                    if exist('arg', 'var') && isfield(arg, 'name');
                        command = [command sprintf('%s ',arg.name)];
                    end
                    command = [command sprintf('%s',sourcefile(i).name)];
                    % display the mex command
                    disp(command);
                    % now run it, catching an errors
                    try
                        eval(command);
                    catch err
                        disp(['Error compiling ' sourcefile(i).name]);
                        disp(err.message);
                        disp(err.identifier);
                    end
                else
                    disp(sprintf('%s is up to date',sourcefile(i).name));
                end    
            end
        end
    end
    if digio
        makeDigIO(rebuild);
    end
    cd(lastPath);
end

%%%%%%%%%%%%%%%%%%%
%%   makeDigIO   %%
%%%%%%%%%%%%%%%%%%%
function makeDigIO(rebuild)

    % check for compiled digIO stuff
    if ~isdir('/Library/Frameworks/nidaqmxbase.framework')
        if strcmp(questdlg('You do not have the directory /Library/Frameworks/nidaqmxbase.framework, which suggests that you do not have the NIDAQ libraries installed. To run mglDigIO, you will need to install NI-DAQmx Base from http://sine.ni.com/nips/cds/view/p/lang/en/nid/14480 and then mglDigIO should work with your NI card. If you think you are getting this warning in error, then hit ''Ignore and mex mglDigIO anyway'' and the program will try to compile the dig io code, but will likely crash because the libraries are not installed on your system','NI-DAQmx Base is missing','Cancel','Ignore and mex mglDigIO anyway','Cancel'),'Cancel')
            return
        end
    end

    % make sure we have the mgl.h file--this will make
    % sure we are in the correct directory
    % fing the mgl digio directory
    mgldir = mglGetParam('mglDigioDir');
    if ~isempty(mgldir)
        cd(fullfile(mgldir));
        hfile = dir('mgl.h');
    else
        return
    end

    % get the files in the utils dir
    mgldir = dir('*.c');

    for i = 1:length(mgldir)
        if (~strcmp('.#',mgldir(i).name(1:2)))
            % see if it is already compiled
            mexname = [stripext(mgldir(i).name) '.' mexext];
            mexfile = dir(mexname);
            % mex the file if either there is no mexfile or
            % the date of the mexfile is older than the date of the source file
            if (rebuild || length(mexfile)<1) || (datenum(mgldir(i).date) > datenum(mexfile(1).date)) || (datenum(hfile(1).date) > datenum(mexfile(1).date))
                command = sprintf('mex %s',mgldir(i).name);
                % display the mex command
                disp(command);
                % now run it, catching an errors
                try
                    eval(command);
                catch
                    disp(['Error compiling ' mgldir(i).name]);
                end
            else
                disp(sprintf('%s is up to date',mgldir(i).name));
            end    
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removes file extension if it exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function retval = stripext(filename,delimiter)

    if ~any(nargin == [1 2])
        help stripext;
        return
    end
    % dot delimits end
    if exist('delimiter', 'var')~=1
        delimiter='.';
    end

    retval = filename;
    dotloc = findstr(filename,delimiter);
    if ~isempty(dotloc)
        retval = filename(1:dotloc(length(dotloc))-1);
    end

end
