local class = require("30log")
local themes = require("themes")

local args = {...}
local deps = args[1]
local wm = args[2]

local Workspace = class("Workspace")

function Workspace:init(screen_id)
  self.gpu = wm.hardware.gpus[screen_id]
  self.addr = self.gpu.getScreen()
  self.theme = themes.factory
  self.margin_top = themes.factory.WORKSPACE_MARGIN_TOP
  self.margin_side = themes.factory.WORKSPACE_MARGIN_SIDE
  self.margin_bottom = themes.factory.WORKSPACE_MARGIN_BOTTOM
  self.windows={}
  table.insert(wm.workspaces, self)
  self.id=#wm.workspaces
end

function Workspace:draw()
  self.gpu.setForeground(self.theme.WORKSPACE_FG)
  self.gpu.setBackground(self.theme.WORKSPACE_BG)
  local res_x, res_y = self.gpu.getResolution()
  self.gpu.fill(1, 1, res_x, res_y, self.theme.WORKSPACE_CHAR)
  return self
end

function Workspace:active()
  wm.screen_to_active_workspace[self.addr] = self.id
  return self
end

function Workspace:touchTitlebar(x, y)
  for window_id, window in ipairs(self.windows) do
    local isDifferentRow = y ~= window.pos_y
    local isBefore = x < window.pos_x
    local isAfter = x > window.pos_x + window.width
    local onTitlebar = (not isDifferentRow) and (not isBefore) and (not isAfter)
    local x_offset = x - window.pos_x
    if onTitlebar then return window, x_offset end
  end
  return nil
end

return Workspace