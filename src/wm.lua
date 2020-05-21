local class = require("30log")

local args = {...}
local deps = args[1] or {}
local component = deps.component or require("component")

local WindowManager = class("WindowManager")

function WindowManager:init()
  self.hardware = {gpus = {},screens = {}}
  self.workspaces = {}
  self.screen_to_active_workspace = {}
  self.screen_to_interact = {}
  self.screen_to_vram = {}
end

function WindowManager:detectHardware()
  -- @TODO blacklist or whitelist hardware
  local hw = self.hardware
  local hw_gpus = self.hardware.gpus
  local hw_screens = self.hardware.screens
  local screens = {}
  for address, componentType in component.list() do
    if (componentType == "screen" or componentType == "gpu") then
      table.insert(hw[componentType.."s"], component.proxy(address))
    end
    if componentType == "screen" then
      table.insert(screens, address)
      self.screen_to_active_workspace[address] = nil
      self.screen_to_interact[address] = {
        window = nil,
        drag_offset_x = nil,
        resize_offset_x = nil,
      }
      -- @TODO when OC has vram this code may work :)
      -- self.screen_to_vram[address] = {
      --   interact_window = nil,
      --   still_when_interact = nil,
      -- }
    end
  end
  if #hw_screens > #hw_gpus then
    error("you must install one GPU per screen")
  end
  for i = 1, #hw_screens do
    hw_gpus[i].bind(screens[i])
  end
  return self
end

function WindowManager:setResolutions(screen_id, res_x, res_y)
  local hw_gpus = self.hardware.gpus
  local start, stop = 1, #hw_gpus
  if screen_id then start=screen_id; stop=screen_id end
  for i=start, stop do
    hw_gpus[i].setResolution(160, 50)
  end
  return self
end

function WindowManager:drawId(screen_id)
  local hw_gpus = self.hardware.gpus
  local start, stop = 1, #hw_gpus
  if screen_id then start=screen_id; stop=screen_id end
  for i=start, stop do
    local gpu = hw_gpus[i]
    gpu.setBackground(0xffffff)
    gpu.setForeground(0x000000)
    gpu.fill(1, 1, 5, 3, " ")
    gpu.set(3, 2, tostring(i).."  "..gpu.getScreen())
  end
  return self
end

-- function WindowManager:touch(address, char_x, char_y)
--   local x, y = tonumber(char_x), tonumber(char_y)
--   local workspace_id = self.screen_to_active_workspace[address]
--   local workspace = self.workspaces[workspace_id]
--   local interact = self.screen_to_interact[address]
--   return x, y, workspace, interact
-- end

return WindowManager