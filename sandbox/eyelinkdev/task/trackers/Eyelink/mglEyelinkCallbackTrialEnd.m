function [task myscreen] = mglEyelinkCallbackTrialEnd(task, myscreen)
% mglEyelinkCallbackTrialEnd - 
%
% Usage: mglEyelinkCallbackTrialEnd(task, myscreen)

%     program: mglEyelinkCallbackTrialEnd.m
%          by: eric dewitt
%        date: 04/03/06
%  copyright: (c) 2009,2006 Eric DeWitt, Justin Gardner, Jonas Larsson (GPL see mgl/COPYING)
%     purpose: open a link connection to an SR Research Eylink
%

    mglEyelinkEDFPrintF('TRIAL OK');
    
end
