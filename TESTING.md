# Testing Game Speed

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Check `logs\rqmod.log` for `Loading game-speed` first.

## What it adds

- **Keys:** F8 turns it on and off. It starts off and the store remembers, so find out its state
  first (the log line `Game speed: ...` at start, or the F8 note) and leave it as you found it.
- **Debug page:** hold F3, page **Game Speed**: **0** on and off, **1** Exploration, **2**
  Transitions, **3** Fight, **4** Level up. Each of 1 to 4 steps through 1x, 1.5x, 2x, 3x, 4x and back.
- **Config → Mods → Game Speed** (loader 1.8.0): kit widgets in section `kit` of `rqmod-ctl ui`,
  such as `check-on` and `check-explore-4`.
- No `rq.agent.control` ids.

## How to check it

`rq.speed.get()` gives the clock's factor. On a quest map it is the Exploration factor, in a fight the
Fight factor, on the result screen the Level up factor, and in town 1.

## Test Lab

`agent-lab.ps1 run gamespeed`: exploration, F8 off and on, the way into a fight, the fight, the F3
page, the result screen and the way out. `run configmods` checks the Config page.
