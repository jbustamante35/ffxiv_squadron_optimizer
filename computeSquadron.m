function [mdst , Y] = computeSquadron(tidx, ridx, init, mgoal, nteam, nregs, vis, sdir)
%% computeSquadron: calculate best possible team for a mission
%
% Usage:
%   [mchk , Y] = computeSquadron(tidx, ridx, tinit, mgoal, ...
%       nteam, nregs, vis, sdir)
%
% Input:
%   tidx: initial team index [default []]
%   ridx: initial regime index [default []]
%   init: initial starting point [default [100 , 100 , 100]]
%   mgoal: mission goal requirements [default [430 , 295 , 600]
%   nteam: team size [default 4]
%   nregs: total training regimes [default 3]
%   vis: show output (1), debug (3), or none (0) [default 0]
%   sdir: directory to database
%
% Output:
%   mdst: distance of team+regime score to mission score
%   Y: data structure of solution

if nargin < 1; tidx  = [];                                  end
if nargin < 2; ridx  = [];                                  end
if nargin < 3; init  = repmat(100, 1, 3);                   end
if nargin < 4; mgoal = [430 , 295 , 600];                   end
if nargin < 5; nteam = 4;                                   end
if nargin < 6; nregs = 3;                                   end
if nargin < 7; vis   = 0;                                   end
if nargin < 8; sdir  = fileparts(which('computeSquadron')); end

%% Load database of team attributes and training regimes
tin = sprintf('%s/squads.csv', sdir);
rin = sprintf('%s/training.csv', sdir);
T   = readtable(tin);
R   = readtable(rin);

% Run through pipeline
if vis; [~ , sprA] = jprintf(' ', 0, 0, 80); fprintf('%s\n', sprA); end

init                  = round(init);
[ttot , tclas , tidx] = pickTeam(T, tidx, nteam, vis);
[rtot , rclas , ridx] = commenceRegimes(R, init, nregs, ridx, vis);
[mtot , mdif  , mdst] = simulateMission(ttot, rtot, mgoal, vis);

% Store outputs
Y.Team         = tclas;
Y.Regimes      = rclas;
Y.TeamIndex    = tidx;
Y.RegimeIndex  = ridx;
Y.TeamScore    = ttot;
Y.RegimeScore  = rtot;
Y.MissionScore = mtot;
Y.MissionDiff  = mdif;
Y.MissionDist  = mdst;

fprintf(['| %.02f | %d,%d,%d,%d | [%s] | [I] %03d %03d %03d | ' ...
    '[M] %03d %03d %03d | [D] %03d %03d %03d |\n'], ...
    mdst, tidx, num2str(ridx), init, mtot, mdif);
end

function [mtot , mdif , mdst , mchk] = simulateMission(ttot, rtot, mgoal, vis)
%% simulateMission: run mission
if nargin < 3; vis = 0; end

mtot = ttot + rtot;
mdif = mtot - mgoal;
mval = mdif >= 0;
mchk = sum(mval);

% Set good scores to goal and double negative scores
mcmp        = mtot;
mcmp(mval)  = mgoal(mval);
mcmp(~mval) = mtot(~mval) + (mdif(~mval) * 2);
mdst        = pdist([mcmp ; mgoal]);

if vis == 3
    [~ , sprA , sprB] = jprintf(' ', 0, 0, 80);
    fprintf(['Simulating Mission\n%s\n'       ...
        '| Sets  | Phys | Men | Tac |\n'      ...
        '| ---   | ---  | --- | --- |\n'      ...
        '| Team  | %03d  | %03d | %03d |\n'   ...
        '| Reg   | %03d  | %03d | %03d |\n'   ...
        '| ---   | ---  | --- | --- |\n'      ...
        '| Full  | %03d  | %03d | %03d |\n'   ...
        '| Goal  | %03d  | %03d | %03d |\n'   ...
        '| Diff  | %03d  | %03d | %03d |\n'   ...
        '| Chk   |  %d |\n%s\n'
        ], sprB, ttot, rtot, mtot, mgoal, mdif, mchk, sprA);
end
end

function [rtot , rclas , ridx] = commenceRegimes(R, init, nregs, ridx, vis)
%% commenceTraining: perform training
if nargin < 2; init  = repmat(100, 1, 3); end
if nargin < 3; nregs = 3;                 end
if nargin < 4; ridx  = [];                end
if nargin < 5; vis   = 0;                 end


if vis == 3
    [~ , sprA , sprB] = jprintf(' ', 0, 0, 80);
    fprintf('Commencing Training [%d sessions]\n%s\n', nregs, sprB);
end

% Choose random set of regimes if empty input
rtyp = R.Training;
if isempty(ridx)
    [rclas , ridx] = pullRandom(rtyp, nregs, 1);
else
    ridx  = round(ridx);
    rclas = rtyp(ridx);
end

init = round(init);

% Commence training! Retry random if attributes < 0
ri = 1;
while ri <= nregs
    tfld  = rclas{ri};
    tstat = R(strcmpi(tfld, R.Training),:);
    ttmp  = init + [tstat.Phys , tstat.Men , tstat.Tac];

    if any(ttmp < 0)
        rtmp = cell2mat(pullRandom(rtyp, 1, 1));
        if vis == 3
            fprintf(2, ['| %d | %s | %03d | %03d | %03d | ' ...
                'Can''t go lower than 0! Attempting %s\n'], ...
                ri, tfld, init, rtmp);
        end
        rclas{ri} = rtmp;
    else
        init = ttmp;
        if vis == 3
            fprintf('| %d | %s | %03d | %03d | %03d |\n', ...
                ri, tfld, init);
        end
        ri = ri + 1;
    end
end

rtot  = init;
rclas = rclas';

if vis == 3
    fprintf('%s\nTraining Total [Phy %03d | Men %03d | Tac %03d |\n%s\n', ...
        sprB, rtot, sprA);
end
end

function [ttot , tclas , tidx] = pickTeam(T, tidx, nteam, vis)
%% pickTeam: select team members
if nargin < 2; tidx  = []; end
if nargin < 3; nteam = 4; end
if nargin < 4; vis   = 0; end

% Choose random team comp if empty input
ttyp = T.Class;
if isempty(tidx)
    [tclas , tidx] = pullRandom(ttyp, nteam, 1);
else
    tidx  = round(tidx);
    tclas = ttyp(tidx);
end

% Store team and sum attributes
tclas = tclas';
steam = T(tidx,:);
ttot  = sum([steam.Phy , steam.Men , steam.Tac]);

if vis == 3
    [~ , sprA , sprB] = jprintf(' ', 0, 0, 80);
    fprintf('\n%s\nTeam Selected\n%s\n', sprA, sprB);
    disp(steam);
    fprintf('%s\nStarting Total [Phy %03d | Men %03d | Tac %03d]\n%s\n', ...
        sprB, ttot, sprB);
end
end