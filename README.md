# FFXIV Squadron Optimizer
Software tool for Final Fantasy 14's Squadrons that implements Nelder-Mead
minimization to find the most optimal team composition and training regimes to
meet the requirements for a squadron mission.

## Requirements
- MATLAB R20xx [written using R2022b, but should presumably be usable on any
version that can run the Optimization Toolbox. \\

## Setup
1) Add this directory to MATLAB's path \\

2) Open ffxiv_squadron_script.m \\

3) Edit the following lines: \\
    [16] tidx = [2 , 5 , 8 , 9] \\
            - This is the starting point for the starting point for an initial
              team composition. You can keep this as is or change them to
              indices for your own starting team. See below for the indices
              that correspond to the different classes. \\

    [17] init = [200 , 0 , 200] \\
            - The training attributes to initialize the algorithm. The three
              digits correspond to starting the Physical, Mental, and Tactical
              attributes. By default this is [100 , 100 , 100], but most
              players would have changed this with previous training. \\

    [20] nregs = 3 \\
            - The total number of training regimes to use. The default is 3,
              since that's a reasonable number to use in a play session.
              Increasing this number will improve the algorithm's ability to
              find an optimal result, but would be more difficult to implement
              for the user. \\

    [26] mgoal = [430 , 295 , 600] \\
            - The required attributes for the selected mission. By default I
              used the values for what I found to be the most useful mission
              [Imposter Alert, Level 50] that rewards 10 [Priority Aetheryte
              Passes|ffxiv.consolegameswiki.com/wiki/Priority_Aetheryte_Pass],
              but you can changed this to any mission's values. See [the wiki
              page|ffxiv.consolegameswiki.com/wiki/Squadron_Missions] for all
              the different values. \\

4) Run the script! MATLAB's default is ctrl+enter \\

## Advanced Usage
The metaparameters are barely optimized and could use quite a bit of
fine-tuning, even if the algorithm generally works. The total iterations,
tolerance values, and input bounds were selected pretty loosely and results may
vary based on starting team composition and initial training attributes. \\

To improve results, you can change the values for the following: \\

    [04] nopts = 10000 \\
            - The maximum iterations for the algorithm. The default value of
              10000 is very high for something as relatively simple as this.
              Lowering this valute might not change to results much, but could
              make it generally faster. \\

    [05] tolf = 1e-2 \\
            - The termination tolerance on the function value. Keep this as a
              positive scalar. \\

    [05] tolx = 1e-2 \\
            - The termination tolerance on the input value. Keep this as a
              positive scalar. \\

## Class and Training Regime Indices
Team classes and training regimes have a coded number associated with them: \\

*Team Classes*
| Index | Class       |
| ---   | ---         |
| 1     | Marauder    |
| 2     | Paladin     |
| 3     | Pugilist    |
| 4     | Lancer      |
| 5     | Rogue       |
| 6     | Archer      |
| 7     | Arcanist    |
| 8     | Thaumaturge |
| 9     | Conjurer    |

*Training Regimes*
| Index | Regime                 |
| ---   | ---                    |
| 1     | PA - Physical          |
| 2     | MA - Mental            |
| 3     | TA - Tactical          |
| 4     | PM - Physical-Mental   |
| 5     | PT - Physical-Tactical |
| 6     | MT - Mental-Tactical   |
| 7     | NN - Neutral           |


