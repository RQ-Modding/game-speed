# game-speed

Runs the game faster by what is on screen, with one factor per area:

| Area | When | Default |
| --- | --- | --- |
| Exploration | walking a quest map (`rq.dungeon.exploring()`) | 2x |
| Transitions | fades and screen effects (`_EFFECT`, `SYS_画面更新`, `効果_マップ転移`, `効果_戦闘準備`) and the way into and out of a fight (`Ｒ８戦闘_前処理`, `Ｒ８戦闘_後処理`) | 2x |
| Fight | the fight itself (`Ｒ８戦闘`), on top of the game's own battle speed | 2x |
| Level up | the result screen (`戦闘リザルト_表示`): EXP bars and level up animations | 2x |

The innermost area on screen wins: a fade inside a fight uses the transition factor. Everywhere else the clock is real.

- **F8** turns the mod off and on, with a note at the top of the screen. It starts **off**, and remembers. (Not F4: the game uses F1 to F7 for the town and Config tabs.)
- Hold **F3** for the **Game Speed** page: **1** to **4** step an area through 1x, 1.5x, 2x, 3x, 4x; **0** is the same as F8.
- With loader 1.8.0, **Config → Mods → Game Speed** has the same settings: a checkbox for on and off, and a row of steps for each area.
- Settings live in the mod's `rq.store`, next to the active save profile.

Sound and music stay at normal speed, and so does the play time on the save. The level up status screen still waits for you.

The mod sets the clock only when its own choice changes, so a factor another mod sets with `rq.speed.set` stays until the screen changes.

## Needs

Loader 1.2.0 (`rq.speed`).

## Test

`rqmod\agent-lab.ps1 run gamespeed`: exploration, F8 off and on, the way into a fight, the fight, the F3 page, the result screen, the way out.

Local-only git. No remote.
