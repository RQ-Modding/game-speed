-- Game Speed: runs the game clock faster by what is on screen.
--   Exploration: walking a quest map.
--   Transitions: fades and screen effects, the way into and out of a fight.
--   Fight:       the fight itself, on top of the game's own battle speed.
--   Level up:    the EXP bars and the level up animations. The status screen still waits for you.
-- F8 turns it off and on; it starts off, and remembers. Hold F3 for the Game Speed page: 1-4 change each area, 0 is F8.
-- Config has the same settings in its Mods tab: the loader's rq.config.settings (1.2.2, loader 2.35.0),
-- kept in rq.store (the profile's) under "on" and each area's id, as before, with a warning on 3x and
-- 4x in dialogue (1.2.3).
-- Sound stays at normal speed, and so does the play time on the save.

local STEPS = { 1, 1.5, 2, 3, 4 }
-- The game takes F1 to F7 (town and Config tabs), the engine F9, F11 and F12.
local TOGGLE = rq.input.code("f8")
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

local names = {}
for i, s in ipairs(STEPS) do names[i] = s .. "x" end
local page_rows = {
  { kind = "checkbox", key = "on", label = "Faster game clock (F8)", default = false },
  { kind = "space", h = 8 },
}
for _, a in ipairs(AREAS) do
  page_rows[#page_rows + 1] = { kind = "choice", key = a.id, label = a.label, options = names, values = STEPS,
    default = 2, dir = "row", gap = 18 }
end
-- 1.2.3: at 3x and 4x a scene's background change can end black (Transitions runs the scenes'
-- screen effects). The cause is not found yet (notes/ideas-later.md, "Phase Q, batch 1, left").
page_rows[#page_rows + 1] = { kind = "space", h = 8 }
page_rows[#page_rows + 1] = { kind = "label", size = 16, color = { 255, 170, 110 },
  text = "3x and 4x can break the scene changes in dialogue: the background may turn black." }
page_rows[#page_rows + 1] = { kind = "label", size = 16, color = { 255, 170, 110 },
  text = "2x or less is safe. Transitions is the area that runs them." }
page_rows[#page_rows + 1] = { kind = "space", h = 12 }
page_rows[#page_rows + 1] = { kind = "label", dim = true, size = 15,
  text = "Sound and music stay at normal speed, and so does the play time." }
page_rows[#page_rows + 1] = { kind = "label", dim = true, size = 15,
  text = "The level up status screen still waits for you." }
local settings = rq.config.settings{
  id = "game-speed",
  title = "Game Speed",
  keep = "profile",
  label_w = 150,
  rows = page_rows,
}

local factor = {}
for _, a in ipairs(AREAS) do factor[a.id] = settings.get(a.id) end
local on = settings.get("on")
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

-- F8, the F3 page and Config all change the values through the settings, and this follows them.
local function set_on(value)
  settings.set("on", value)
end

function rows.toggle()
  rq.debug.action{
    id = "game-speed-on",
    label = "Game speed (F8): " .. (on and "On" or "Off"),
    key = "0",
    page = "Game Speed",
    onPress = function() set_on(not on) end,
  }
end

local area_row

local function set_factor(a, f)
  settings.set(a.id, f)
end

function area_row(a)
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
      set_factor(a, next_f)
      show(summary())
    end,
  }
end

rows.toggle()
for _, a in ipairs(AREAS) do area_row(a) end

settings.on_change(function(key, value)
  if key == "on" then
    on = value
    rows.toggle()
    apply()
    show(summary())
    return
  end
  for _, a in ipairs(AREAS) do
    if a.id == key then
      factor[key] = value
      area_row(a)
      apply()
    end
  end
end)

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
      -- On a quest's map: centered on the 3D view (8 to 807), under the encounter bar (y 9, 12 high).
      local cx, y = w // 2, 8
      if rq.dungeon.exploring() then cx, y = 408, 26 end
      rq.hud.rect(cx - tw // 2 - 10, y, tw + 20, 28, 0, 0, 0, 170)
      rq.hud.text(cx - tw // 2, y + 4, note, { size = 18 })
    end
  end
end)

rq.log(summary())
