# game-speed

Runs the game faster by what is on screen, with one factor per area:

| Area | When | Default |
| --- | --- | --- |
| Exploration | walking a quest map (`rq.dungeon.exploring()`) | 2x |
| Transitions | fades and screen effects (`_EFFECT`, `SYS_画面更新`, `効果_マップ転移`, `効果_戦闘準備`) and the way into and out of a fight (`Ｒ８戦闘_前処理`, `Ｒ８戦闘_後処理`) | 2x |
| Fight | the fight itself (`Ｒ８戦闘`), on top of the game's own battle speed | 2x |
| Level up | the result screen (`戦闘リザルト_表示`): EXP bars and level up animations | 2x |

The innermost area on screen wins: a fade inside a fight uses the transition factor. Everywhere else the clock is real.

- **F4** turns the mod off and on, with a note at the top of the screen. It starts **off**, and remembers.
- Hold **F3** for the **Game Speed** page: **1** to **4** step an area through 1x, 2x, 3x, 4x; **0** is the same as F4.
- Settings live in the mod's `rq.store`, next to the active save profile.

Sound and music stay at normal speed, and so does the play time on the save. The level up status screen still waits for you.

The mod sets the clock only when its own choice changes, so a factor another mod sets with `rq.speed.set` stays until the screen changes.

## Needs

Loader 1.2.0 (`rq.speed`).

## Test

`rqmod\agent-lab.ps1 run gamespeed`: exploration, F4 off and on, the way into a fight, the fight, the F3 page, the result screen, the way out.

Local-only git. No remote.
