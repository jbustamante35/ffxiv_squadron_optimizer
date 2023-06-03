%% Empty script to use FFXIv squadron optimizer
% Optimizer metaparameters
[~ , sprA , sprB] = jprintf(' ', 0, 0, 80);
nopts = 10000;
tolf  = 1e-2;
tolx  = 1e-2;
% tlb   = [1 , 3 , 3 , 9]; % 1 Tank , 2 DPS , 1 Healer
% tub   = [2 , 8 , 8 , 9]; % 1 Tank , 2 DPS , 1 Healer
tlb   = [1 , 1 , 1 , 1]; % No class limits
tub   = [9 , 9 , 9 , 9]; % No class limits
nteam = 4;
vis   = 0;
sdir  = fileparts(which('computeSquadron'));

% Inputs
tidx  = [2 , 5 , 8 , 9]; % Sample starting team comp
init  = [200 , 0 , 200]; % Sample initial starting point

% Total Trainings
nregs = 10;

% Mission Goals
% mgoal = [235 , 245 , 255]; % Easy mission
% mgoal = [370 , 355 , 345]; % Medium mission
% mgoal = [590 , 305 , 430]; % Hard mission
mgoal = [430 , 295 , 600]; % Most useful mission

% Run Optimizer
fprintf('\n\n%s\n', sprA);
[gopt , Y] = optimizeSquadron(tidx, init, mgoal, nregs, ...
    'nopts', nopts, 'tolf', tolf, 'tolx', tolx, 'tlb', tlb, 'tub', tub, ...
    'nteam', nteam, 'vis', vis, 'sdir', sdir);
fprintf('%s\n\n', sprA);

% Show Output
fprintf('Optimized Solution:\n\n');
disp(Y);
fprintf('%s\n\n', sprB);