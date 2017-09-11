- Last Update: 
    - 2017 09 11
    - 12:12 CEST  (UTC +1)
- CommitID: 12
- CommitLog: 
```
[fix] no BattleAction
- issue #15: TrainerBattle | no action executed, switch in last pkm
- issue description: https://github.com/M1L4/QuestingDebug/issues/15

- corrected a wrong reference in game.useAnyMove(): iterator i was referenced as moveId

[improvement]
- massive code reduction and improved readabiltiy:
  - combined trainer and wild battles, as they were not handled differently, appart from catching
  - canRun & canSwitch were originally reset in onPathAction, making that function unnecessary 
    complicated and confusing, moved that to onBattleMessage

[testing] removed blacklist
- temporarily removed blacklist, as I saw no meaning to it. If nurse loop now happens more 
  frequently, it is probably to this. At which point the leveling function has to be adressed,
  not a blacklist.
- allows catching following previously blacklisted pkm:
  - "Metapod",
  - "Kakuna",
  - "Doduo",
  - "Hoothoot",
  - "Zigzagoon"
- necessary for e.g. pokedex completion
```
- Branch: Master
- Characteristics:
    - most recent bugfixes
    - most stable version
    - no features of branches

Hi everyone,

**[introduction]**

this is a questing fork, with the intention to improve, expedite and update the master version to new hights.
So see this as a beta version of the next Questing update. The original project owner is still wiwi and as such,
all released versions will be found in his project: https://github.com/WiWi33/Questing.lua.

As it didn't get any attention lately, Questing contains open problems that prevent it from functioning - I'll
try to make it work again as fast as possible.

My current priority list:
1. mandatory fixes
2. some appointed features

For the time being I don't intend add:s

3. new functionallity
4. new content

**[pointers]**
- _[branches]_ As I am developing multiple features at times, multiple branches will exist. Feel free to
debug test any of them. And give me feedback. They can be found, when clicking the *branch button* top left
over the current project.
- _[issues]_ When encountering one use githubs issue system:
    - Title Format: I would prefer: "banchName | shortIssueDescription". This is due to the fact, that I couldn't find
    any options for branch correlating related issue tagging.
    - Quest: pls provide running quest - this looks like `[00:11:05] Starting new quest: Sould Badge: Fuchsia City`
    - Logs: add any form of log, you think could help narrowing down the error source. E.g.: Debug or normal textbox
    prints. Post them if unsure.
    - Detail: Provide as detailed as possible/willing. Details help a lot, when debugging.

_Side Note_: the more information (people using minus people that actually provide some) I/we get, the better it is for
identifying the error. Help me to help us all :)

Nice botting everyone ;)