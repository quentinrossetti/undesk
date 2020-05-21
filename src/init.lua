package.loaded["themes"] = nil
local class = require("30log")
p=require("develop").pretty
local component = require("component")
local event = require("event")
local gpu = component.gpu -- optimize cross/application?

local WindowManager = loadfile('wm.lua')(nil)
local wm = WindowManager:new()
local Workspace = loadfile("workspace.lua")(nil, wm)
local Window = loadfile("window.lua")(nil, wm)

wm:detectHardware()
wm:setResolutions()
-- wm:drawId()
function login()
  -- workspaces
  workspace1 = Workspace:new(1):active():draw()

  -- normal
  win1 = Window:new(1)
    :setLayout("x1 y3 w6 h4")
    :setTitle("Big graph with lots of things")
    :draw()
  win2 = Window:new(1)
    :setLayout("x1 y1 w2 h2")
    :setTitle("Small monitor")
    :draw()
  win3 = Window:new(1)
    :setLayout("x3 y1 w2 h2")
    :setTitle("Keep in check")
    :draw()
  win4 = Window:new(1)
    :setLayout("x5 y1 w2 h4")
    :setTitle("Some controls")
    :draw()
end

login()

-- loop
local running = true

local handlers = setmetatable({}, { __index = function () return function () end end })

function handlers.interrupted()
  running = false
end

function handlers.drag(address, char_x, char_y)
  local x, y = tonumber(char_x), tonumber(char_y)
  local ws = wm.workspaces[wm.screen_to_active_workspace[address]]
  local interact = wm.screen_to_interact[address]
  if not interact.window then return end
  local w = interact.window
  w.pos_x = x - interact.drag_offset_x
  w.pos_y = y
  ws:draw()
  for _, win in pairs(ws.windows) do
    if win ~= w then
        win:draw()
    end
  end
  w:draw()
end

function handlers.touch(address, char_x, char_y)
  local x, y = tonumber(char_x), tonumber(char_y)
  local ws = wm.workspaces[wm.screen_to_active_workspace[address]]
  local interact = wm.screen_to_interact[address]
  interact.window, interact.drag_offset_x = ws:touchTitlebar(x, y)
  if interact.window then -- title bar is being touched
    interact.window:draw()
  end
  -- @TODO when OC has vram this code may work :)
  -- local vram = wm.screen_to_vram[address]
  -- if interact.window then
  --   for k,v in pairs(ws.gpu) do print(k,v) end
  --   vram.interact_windows = ws.gpu.allocateBuffer(w.pos_x, w.pos_y)
  --   ws.gpu.bitblt(vram.interact_windows, 1, 1, 0, w.pos_x, w.pos_y)
  -- end
end

function handlers.drop(address, char_x, char_y)
  local x, y = tonumber(char_x), tonumber(char_y)
  local ws = wm.workspaces[wm.screen_to_active_workspace[address]]
  local interact = wm.screen_to_interact[address]
  interact.window, interact.drag_offset_x = ws:touchTitlebar(x, y)
  if interact.drag_offset_x then -- 
    interact.window:draw()
  end
  interact = {} -- reset interaction state @TODO reset initial table like in wm.lua
end

function handle_events(event_id, ...)
  if event_id then
    handlers[event_id](...)
  end
end

while running do
  handle_events(event.pull())
end

-- @TODO.txt
-- resize? see how content could adjust
-- tiling wm with vim-like keybinding
-- bars and widgets
-- help page (keybindings, etc)
-- windows with special colors