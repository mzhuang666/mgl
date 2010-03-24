% getTaskVarnames.m
%
%        $id:
%      usage: [varnames varnamesStr] = getTaskVarnames(task)
%         by: justin gardner
%       date: 03/14/07
%    purpose: returns all the names of the variables in the task
%             as a cell array (second optional output returns
%             a single string with the name of the variables)
%
function [varnames varnamesStr] = getTaskVarnames(task)

% check arguments
if ~any(nargin == [1])
  help getTaskVarnames
  return
end

% make into a cell array of cell arrays
task = cellArray(task,2);

varnames = {};
for taskNum = 1:length(task)
  for phaseNum = 1:length(task{taskNum})
    % look in parameter for parameter names
    fields = fieldnames(task{taskNum}{phaseNum}.parameter);
    for fieldNum = 1:length(fields)
      % real vars don't end in _
      if fields{fieldNum}(end) ~= '_'
	varnames{end+1} = fields{fieldNum};
      end
    end
    %  or in randVars
    if isfield(task{taskNum}{phaseNum},'randVars')
      fields = fieldnames(task{taskNum}{phaseNum}.randVars);
      for fieldNum = 1:length(fields)
	% real vars don't end in _
	if fields{fieldNum}(end) ~= '_'
	  varnames{end+1} = fields{fieldNum};
	end
      end
    end
  end
end

% get unique names, and remove default name
varnames = unique(varnames);
varnames = setdiff(varnames,'default');

% also return string array of variable names
if length(varnames)
  varnamesStr = varnames{1};
  for i = 2:length(varnames)
    varnamesStr = sprintf('%s, %s',varnamesStr,varnames{i});
  end
else
  varnamesStr = '';
end