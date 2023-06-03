function [Z , Y] = computeSquadron_brute(tinit, mgoal, ntrain, vis, sdir)
%% computeSquadron_brute: calculate best possible team for a mission
%
% Usage:
%   [Z , Y] = computeSquadron_brute(tinit, mgoal, ntrain, vis, sdir)
%
% Input:
%   tinit: initial attributes
%   mgoal: mission attributes goal
%   ntrain: training regime sessions [default 3]
%   vis: no output (0), minimal output (1), debug (3) [default 1]
%   sdir: location of databases
%
% Output:
%   Z: Perfect team compositions
%   Y: OK team compositions

if nargin < 1; tinit  = repmat(100, 1, 3);                   end
if nargin < 2; mgoal  = [430 , 295 , 600];                   end
if nargin < 3; ntrain = 3;                                   end
if nargin < 4; vis    = 0;                                   end
if nargin < 5; sdir   = fileparts(which('computeSquadron')); end

[~ , sprA , sprB] = jprintf(' ', 0, 0, 80);

%% Load database of squads
sin = sprintf('%s/squads.csv', sdir);
tin = sprintf('%s/training.csv', sdir);
S   = readtable(sin);
T   = readtable(tin);

styp = S.Class;
ttyp = T.Training;

%% Do a ton of simulations
% All Team Combinations
svec = 1 : numel(styp);
scmb = combvec(svec,svec,svec,svec)';
scmb(any(diff(sort(scmb,2),[],2) == 0,2),:) = [];

% All Training Combinations
tvec = 1 : numel(ttyp);
xstr = ['tvec' , repmat(',tvec', 1, ntrain - 1)];
tcmb = sortrows(eval(sprintf('combvec(%s)''', xstr)));

% Concatenate all training combos onto all team combos
nsc  = size(scmb,1);
ntc  = size(tcmb,1);
acmb = arrayfun(@(x) [repmat(scmb(x,:), ntc, 1) , tcmb], ...
    1 : nsc, 'UniformOutput', 0)';
acmb = cat(1, acmb{:});
nac  = size(acmb,1);

% Run a million combinations in parallel
[stot , scls , atot , ttot , sgud , sdif , ttrn , nchk] = deal(cell(nac,1));

X = struct('ClassIndex', [], 'ClassOrder', [], ...
    'ClassScore', [], 'TrainingScore', [], ...
    'TrainingOrder', [], 'PassSum', []);
Y = repmat(X, nac, 1);

%%
t = tic;
if vis; fprintf('%s\n', sprA); end
parfor si = 1 : nac
    nteam = acmb(si,1:4);
    tord  = acmb(si,5:end);

    [stot{si} , scls{si}] = pickTeam(S, nteam, vis);
    [ttot{si} , ttrn{si}] = commenceTraining( ...
        T, tinit, ntrain, tord, vis);
    [nchk{si} , sgud{si} , sdif{si} , atot{si}] = simulateMission( ...
        stot{si}, ttot{si}, mgoal, vis);

    %
    npass = nchk{si};
    Y(si).ClassIndex    = si;
    Y(si).ClassOrder    = scls{si};
    Y(si).ClassScore    = stot{si};
    Y(si).TrainingScore = atot{si};
    Y(si).TrainingOrder = ttrn{si};
    Y(si).PassDiff      = sdif{si};
    Y(si).PassSum       = npass;

    %
    if vis
        switch npass
            case 1
                sg = sgud{si};
                fprintf(['| Run %03d | Team %s | Train %s | ' ...
                    'Phys %d | Men %d | Tac %d | Good %d |\n'], ...
                    si, num2str(nteam), num2str(tord), sg, npass);
            case 3
                sg = sgud{si};
                fprintf(2, ['| Run %03d | Team %s | Train %s | ' ...
                    'Phys %d | Men %d | Tac %d | Perfect %d |\n'], ...
                    si, num2str(nteam), num2str(tord), sg, npass);
        end
    else
        fprintf(['| Run %03d | Team %s | Train %s | ' ...
            'Init | Phys %d | Men %d | Tac %d | Perfect %d |\n'], ...
            si, num2str(nteam), num2str(tord), tinit, npass);
    end
end

%%
Y = Y(arrayfun(@(x) x.PassSum > 0, Y));
Z = Y(arrayfun(@(x) x.PassSum == 3, Y));
if vis
    fprintf(['%s\n[%.02f min] %d Perfect Teams (%d OK) | ' ...
        'Init Phys %03d | Men %03d | Tac %03d\n%s\n'], ...
        sprB, mytoc(t, 'min'), numel(Z), numel(Y), tinit, sprA);
else
    fprintf(['[%.02f min] %d Perfect Teams (%d OK) | ' ...
        'Init Phys %03d | Men %03d | Tac %03d\n'], ...
        mytoc(t, 'min'), numel(Z), numel(Y), tinit);
end
end

function [nCheck , isGood , sdif , atot] = simulateMission(stot, ttot, mgoal, vis)
%% simulateMission: run mission
if nargin < 3; vis = 0; end

[~ , sprA , sprB] = jprintf(' ', 0, 0, 80);

%
atot   = stot + ttot;
sdif   = atot - mgoal;
isGood = sdif >= 0;
nCheck = sum(isGood);

%
switch nCheck
    case 1;    nCheck = 0; % No Good
    case 2;    nCheck = 1; % Partial Pass
    case 3;    nCheck = 3; % Full Success
    otherwise; nCheck = 0; % No Success
end

if vis == 3
    fprintf(['Simulating Mission\n%s\n'       ...
        '| Sets  | Phys | Men | Tac |\n'      ...
        '| ---   | ---  | --- | --- |\n'      ...
        '| Team  | %03d  | %03d | %03d |\n'   ...
        '| Train | %03d  | %03d | %03d |\n'   ...
        '| ---   | ---  | --- | --- |\n'      ...
        '| Full  | %03d  | %03d | %03d |\n'   ...
        '| Goal  | %03d  | %03d | %03d |\n'   ...
        '| Diff  | %03d  | %03d | %03d |\n'   ...
        '| Chk   |  %d   |  %d  |  %d  |\n%s\n'
        ], sprB, stot, ttot, atot, mgoal, sdif, isGood, sprA);
end
end

function [ttot , training_order] = commenceTraining(T, ttot, ntrain, training_order, vis)
%% commenceTraining: perform training
if nargin < 2; ttot           = repmat(100, 1, 3); end
if nargin < 3; ntrain         = 6;                 end
if nargin < 4; training_order = [];                end

ttyp = T.Training;
if isempty(training_order); training_order = pullRandom(ttyp, ntrain, 1); end
if ~iscell(training_order); training_order = ttyp(training_order); end

%
[~ , sprA , sprB] = jprintf(' ', 0, 0, 80);
if vis == 3
    fprintf('Commencing Training [%d sessions]\n%s\n', ntrain, sprB);
end
ti = 1;
while ti <= ntrain
    tfld  = training_order{ti};
    tstat = T(strcmpi(tfld, T.Training),:);
    ttmp  = ttot + [tstat.Phys , tstat.Men , tstat.Tac];

    if any(ttmp < 0)
        rtyp = cell2mat(pullRandom(ttyp, 1, 1));
        if vis == 3
            fprintf(2, ['| %d | %s | %03d | %03d | %03d | ' ...
                'Can''t go lower than 0! Attempting %s\n'], ...
                ti, tfld, ttot, rtyp);
        end
        training_order{ti} = rtyp;
    else
        ttot = ttmp;
        if vis == 3
            fprintf('| %d | %s | %03d | %03d | %03d |\n', ...
                ti, tfld, ttot);
        end
        ti = ti + 1;
    end
end

training_order = training_order';

if vis == 3
    fprintf('%s\nTraining Total [Phy %03d | Men %03d | Tac %03d |\n%s\n', ...
        sprB, ttot, sprA);
end
end

function [stot , team_classes] = pickTeam(S, nteam, vis)
%% pickTeam: select team members
if nargin < 2; nteam = 4; end
if nargin < 3; vis   = 0; end

[~ , sprA , sprB] = jprintf(' ', 0, 0, 80);

%
styp  = S.Class;

if numel(nteam) > 1
    % Use selected
    sidx  = nteam(1,:);
    steam = S(sidx,:);
else
    % Choose random n
    sflds = pullRandom(styp, nteam, 1);
    ss    = cellfun(@(x) strcmpi(x, styp), sflds, 'UniformOutput', 0);
    s     = cellfun(@(x) S(x,:), ss, 'UniformOutput', 0);
    steam = cat(1, s{:});
end

%
team_classes = steam.Class';
stot         = sum([steam.Phy , steam.Men , steam.Tac]);

%
if vis == 3
    fprintf('\n%s\nTeam Selected\n%s\n', sprA, sprB);
    disp(steam);
    fprintf('%s\nStarting Total [Phy %03d | Men %03d | Tac %03d]\n%s\n', ...
        sprB, stot, sprB);
end
end