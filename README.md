Last Update: 2017:09:08 4:34 CEST  (UTC +1)

- CommitID: 1
- Branch: BikeQuest
- Features:
    - BikeQuest
        - catching Ditto
        - retrieving Ditto from PC
        - retrieving Bike Voucher
        - all steps after are as before | **need testing** if relevant:
            - map link names got updated
            - maps have been changed (npc's at different positions etc)
    - automated Surfer retrieve from PC
        - SoulBadgeQuest
        - ToCinnabarQuest
    - Rods should have been working before, slight changes
    - Merged Bugfixes from Master
    - New config values in *config.lua* file
    - Deactivated AutoEvolving for faster EXP | **need testing** wheater:
        - auto evolving should be enabled again (maybe not strong enough to beat gyms)
        - gym levels need adjustment 
        - further changes are unnecessary

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

For the time being I don't intend add:

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