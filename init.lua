-- Game Speed: runs the game clock faster by what is on screen.
--   Exploration: walking a quest map.
--   Transitions: fades and screen effects, the way into and out of a fight.
--   Fight:       the fight itself, on top of the game's own battle speed.
--   Level up:    the EXP bars and the level up animations. The status screen still waits for you.
-- F4 turns it off and on; it starts off, and remembers. Hold F3 for the Game Speed page: 1-4 change each area, 0 is F4.
-- Sound stays at normal speed, and so does the play time on the save.

local STEPS = { 1, 2, 3, 4 }
local TOGGLE = rq.input.code("f4")
local NOTE_MS = 2000

local AREAS = {
  { id = "explore", label = "Exploration", key = "1" },
  { id = "transition", label = "Transitions", key = "2" },
  { id = "fight", label = "Fight", key = "3" },
  { id = "levelup", label = "Level up", key = "4" },
}

-- The game functions that make up each area. The innermost one on screen wins, so a fade inside
-- a fight uses the transition factor and the level up inside the end of a fight its own.
local HOOKS = {
  { "_EFFECT", "transition" },
  { "SYS_画面更新", "transition" },
  { "効果_マップ転移", "transition" },
  { "効果_戦闘準備", "transition" },
  { "Ｒ８戦闘_前処理", "transition" },
  { "Ｒ８戦闘_後処理", "transition" },
  { "Ｒ８戦闘", "fight" },
  { "戦闘リザルト_表示", "levelup" },
}

local factor = {}
for _, a in ipairs(AREAS) do factor[a.id] = rq.store.get(a.id, 2) end
local on = rq.store.get("on", false)
local stack = {}
local note, note_until = nil, 0

local function want()
  if not on then return 1 end
  local top = stack[#stack]
  if top then return factor[top] end
  if rq.dungeon.exploring() then return factor.explore end
  return 1
end

-- Sets the clock only when this mod's own choice changes, so a factor another mod or the
-- test lab set stays until the screen changes.
local last = 1
local function apply()
  local f = want()
  if f ~= last then
    last = f
    rq.speed.set(f)
  end
end

local function show(text)
  note, note_until = text, rq.time_ms() + NOTE_MS
end

local function summary()
  if not on then return "Game speed: off" end
  local parts = {}
  for _, a in ipairs(AREAS) do parts[#parts + 1] = a.label .. " " .. factor[a.id] .. "x" end
  return "Game speed: " .. table.concat(parts, ", ")
end

for _, h in ipairs(HOOKS) do
  local area = h[2]
  rq.ain.hook(h[1], {
    before = function()
      stack[#stack + 1] = area
      apply()
    end,
    after = function()
      for i = #stack, 1, -1 do
        if stack[i] == area then
          table.remove(stack, i)
          break
        end
      end
      apply()
    end,
  })
end

local rows = {}

local function set_on(value)
  on = value
  rq.store.set("on", on)
  rows.toggle()
  apply()
  show(summary())
end

function rows.toggle()
  rq.debug.action{
    id = "game-speed-on",
    label = "Game speed (F4): " .. (on and "On" or "Off"),
    key = "0",
    page = "Game Speed",
    onPress = function() set_on(not on) end,
  }
end

local function area_row(a)
  rq.debug.action{
    id = "game-speed-" .. a.id,
    label = a.label .. ": " .. factor[a.id] .. "x",
    key = a.key,
    page = "Game Speed",
    onPress = function()
      local next_f = STEPS[1]
      for i, s in ipairs(STEPS) do
        if s == factor[a.id] then next_f = STEPS[i % #STEPS + 1] end
      end
      factor[a.id] = next_f
      rq.store.set(a.id, next_f)
      area_row(a)
      apply()
      show(summary())
    end,
  }
end

rows.toggle()
for _, a in ipairs(AREAS) do area_row(a) end

local toggle_down = false
rq.on_frame(function()
  local down = rq.input.key(TOGGLE)
  if down and not toggle_down then set_on(not on) end
  toggle_down = down
  apply()
  if note then
    if rq.time_ms() > note_until then
      note = nil
    else
      local w = rq.hud.screen()
      local tw = rq.hud.text_width(note, 18)
      rq.hud.rect((w - tw) // 2 - 10, 8, tw + 20, 28, 0, 0, 0, 170)
      rq.hud.text((w - tw) // 2, 12, note, { size = 18 })
    end
  end
end)

rq.log(summary())
