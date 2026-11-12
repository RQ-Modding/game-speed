# Game Speed

Runs the game faster, with its own speed for each part of the game.

## What it changes

| Area | When | Default |
| --- | --- | --- |
| Exploration | walking a quest map | 2x |
| Transitions | fades and screen effects, and the way into and out of a fight | 2x |
| Fight | the fight itself, on top of the game's own battle speed | 2x |
| Level up | the result screen: EXP bars and level up animations | 2x |

A fade inside a fight uses the Transitions speed. Everywhere else (town, menus, scenes) the game
runs at normal speed. Sound and music stay at normal speed, and so does the play time on the save.
The level up status screen still waits for you.

**3x and 4x in dialogue:** a scene's background changes run at the Transitions speed, and at 3x
and 4x one can end with a black background. 2x or less is safe; the Mods tab page says so too.

## Keys and settings

- **F8** turns the mod on and off, with a note at the top of the screen (on a quest's map, under
  the encounter bar). It starts **off**, and remembers.
- Hold **F3** for the **Game Speed** page: **1** to **4** step an area through 1x, 1.5x, 2x, 3x and
  4x; **0** is the same as F8.
- **Config → Mods → Game Speed** has the same settings: a checkbox for on and off, and a row of
  speeds for each area. **Reset** puts back off and 2x everywhere.

## Saves

The settings are kept in the mod's store, beside the active save. The game's save is not changed.

## Works with

Another mod that sets the game clock (`rq.speed.set`) keeps its speed until the screen changes; this
mod sets the clock only when its own choice changes.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.35.0** or newer. Extract the release zip into the game's `mods` folder, so that you have
`mods/game-speed/mod.json`.

## How it works

Each area is a set of the game's functions: `_EFFECT`, `SYS_画面更新`, `効果_マップ転移`,
`効果_戦闘準備`, `Ｒ８戦闘_前処理` and `Ｒ８戦闘_後処理` for Transitions, `Ｒ８戦闘` for Fight,
`戦闘リザルト_表示` for Level up, and `rq.dungeon.exploring()` for Exploration. The innermost one
running wins.

## License

MIT, see [LICENSE](LICENSE).
