function [gopt , Y] = optimizeSquadron(tidx, init, mgoal, nregs, varargin)
%% optimizeSquadron: run optimizer to find best team comp and regime order
%
% Sample starting team comp
% tidx  = [2 , 5 , 8 , 9];
%
% Sample initial starting point
% init  = [200 , 0 , 200]
%
% Sample goals
% mgoal = [235 , 245 , 255] % Easy mission
% mgoal = [370 , 355 , 345] % Medium mission
% mgoal = [590 , 305 , 430] % Hard mission
% mgoal = [430 , 295 , 600] % Most difficult mission
%
% Usage:
%   [gopt , Y] = optimizeSquadron(tidx, init, mgoal, nregs, ...
%       'nopts', nopts, 'tolf', tolf, 'tolx', tolx, 'tlb', tlb, 'tub', tub, ...
%       'nteam', nteam, 'vis', vis, 'sidir', sdir)
%
% Input:
%   tidx: initial team index [default [1 , 3 , 6 , 9]]
%   init: initial starting point [default [100 , 100 , 100]]
%   mgoal: mission goal requirements [default [430 , 295 , 600]
%   nregs: total training regimes [default 3]
%   varargin: various inputs (see below)
%       nopts: maximum iterations [default 10000]
%       tolf: tolerance for function values [default 1e-1]
%       tolx: tolerance for x-values [default 1e-1]
%       tlb: lower bound for team indices [default [1 , 3 , 3 , 9]]
%       tub: upper bound for team indices [default [2 , 8 , 8 , 9]]
%       nteam: team size [default 4]
%       vis: show output (1), debug (3), or none (0) [default 0]
%       sdir: directory to database
%
% Output:
%   gopt: optimal solution
%   Y: data structure of optimal solution

if nargin < 1;  tidx  = [2 , 5 , 8 , 9];                     end
if nargin < 2;  init  = [100 , 100 , 100];                   end
if nargin < 3;  mgoal = [430 , 295 , 600];                   end
if nargin < 4;  nregs = 3;                                   end

%% Parse optional inputs
args = parseInputs(varargin);
for fn = fieldnames(args)'
    feval(@() assignin('caller', cell2mat(fn), args.(cell2mat(fn))));
end

%% Optimize full set with varying goal but only training and classes
% Set bounds
rlb = ones(1, nregs);
rub = repmat(6, 1, nregs);

% Set metaparameters
glb  = [tlb , rlb];
gub  = [tub , rub];
gto  = optimset('Display', 'off', 'MaxIter', nopts, ...
    'TolFun', tolf, 'TolX', tolx);

% Set initial parameters
ridx  = repmat(7, 1, nregs);
ginn  = [tidx , ridx];

% Run optimizer
fg   = @(m)@(x) squadronWrapper([x , init], m, nteam, nregs, vis, sdir);
gopt = patternsearch(fg(mgoal), ginn, [], [], [], [], glb, gub, gto);
% gopt = ga(fg(mgoal), ginn, ones(1, size(ginn,2)));

% Check optimized solution
ff      = fg(mgoal);
[~ , Y] = ff(gopt);
end


function args = parseInputs(varargin)
%%
p = inputParser;

% Optional Inputs
p.addOptional('nopts', 10000);
p.addOptional('tolf', 1e-1);
p.addOptional('tolx', 1e-1);
p.addOptional('nteam', 4);
p.addOptional('vis', 0);
p.addOptional('sdir', fileparts(which('computeSquadron')));
p.addOptional('tlb', [1 , 3 , 3 , 9]);
p.addOptional('tub', [2 , 8 , 8 , 9])

% Parse arguments and output into structure
p.parse(varargin{1}{:});
args = p.Results;
end
