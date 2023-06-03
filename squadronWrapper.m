function [y , Y] = squadronWrapper(xinn, mgoal, nteam, nregs, vis, sdir)
%% squadronWrapper: wrapper to handle single inputs for multiple parameters
%
% Usage:
%   [y , Y] = squadronWrapper(xinn, mgoal, nteam, nregs, vis, sdir)
%
% Input:
%   xinn: [tidx , ridx , init] (see below)
%       tidx: initial team index [default []]
%       ridx: initial regime index [default []]
%       init: initial starting point [default [100 , 100 , 100]]
%   mgoal: mission goal requirements [default [430 , 295 , 600]
%   nteam: team size [default 4]
%   nregs: total training regimes [default 3]
%   vis: show output (1), debug (3), or none (0) [default 0]
%   sdir: directory to database
%
% Output:
%   y: distance to target score
%   Y: data structure of solution

if nargin < 1; xinn  = [];                                  end
if nargin < 2; mgoal = [430 , 295 , 600];                   end
if nargin < 3; nteam = 4;                                   end
if nargin < 4; nregs = 3;                                   end
if nargin < 5; vis   = 0;                                   end
if nargin < 6; sdir  = fileparts(which('computeSquadron')); end

%% Extract team comp, regime order, and initial starting point
tidx = xinn(1 : nteam);
ridx = xinn(nteam + 1 : (nteam + nregs));
init = xinn(nteam + nregs + 1 : end);

% Run mission
[y , Y] = computeSquadron(tidx, ridx, init, mgoal, nteam, nregs, vis, sdir);
end