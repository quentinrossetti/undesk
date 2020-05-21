local class = require("30log")

local args = {...}
local deps = args[1]
local wm = args[2]

local function tonumber_m(...)
  n={}
  for k,v in pairs({...}) do
    n[k]=tonumber(v)
  end
  return table.unpack(n)
end

local Window = class("Window")

-- static methods
function Window.intersect(win1, win2)
  local cond1 = win1.pos_x < win2.pos_x+win2.width
  local cond2 = win1.pos_x+win1.width > win2.pos_x
  local cond3 = win1.pos_y < win2.pos_y+win2.height
  local cond4 = win1.pos_y+win1.height > win2.pos_y
  return (cond1 and cond2 and cond3 and cond4)
end

-- instance methods
function Window:init(workspace_id)
  self.workspace = wm.workspaces[workspace_id]
  self.gpu = wm.hardware.gpus[screen_id]
  self.theme = self.workspace.theme
  table.insert(self.workspace.windows, self)
  self.id=#self.workspace.windows
end

function Window:setTitle(title)
  self.title = title
  return self
end

function Window:setLayout(layout)
  local pattern_xywh = "^x(%d) y(%d) w(%d) h(%d)$"
  local grid_x, grid_y, grid_w, grid_h = tonumber_m(layout:match(pattern_xywh))
  -- window dimensions. 
  local ws = self.workspace
  local res_x, res_y = ws.gpu.getResolution()
  self.pos_x = math.floor(res_x / 6 * (grid_x-1) + ws.margin_side)
  self.pos_y = math.floor(res_y / 6 * (grid_y-1) + ws.margin_top + 1)
  self.width = math.floor(res_x/ 6 * grid_w - ws.margin_side)
  self.height = math.floor(res_y / 6 * grid_h - (ws.margin_top+ws.margin_bottom)/4)
  -- those previous calculation sometimes produces off dimensions, so we:
  -- adjust the first window in the row
  if grid_x == 1 then
    self.pos_x = ws.margin_side + 1
    self.width = self.width - 1
  end
  -- adjust the last window in the row
  if grid_x + grid_w == 7 then 
    self.width = math.ceil(res_x - self.pos_x) - ws.margin_side + 1
  end
  -- adjust the last window in the column
  if grid_y + grid_h == 7 then 
    self.height = math.ceil(res_y - self.pos_y) - ws.margin_bottom + 1
  end
  return self
end

function Window:draw()
  local gpu = self.workspace.gpu
  local theme = self.theme
  gpu.setBackground(theme.WINDOW_BG)
  -- background
  gpu.fill(self.pos_x, self.pos_y, self.width, self.height, " ")
  -- border
  gpu.setForeground(theme.WINDOW_BORDER)
  gpu.fill(self.pos_x+1, self.pos_y+self.height-1, self.width-2, 1, theme.WINDOW_BORDER_BOTTOM_CHAR)
  gpu.fill(self.pos_x, self.pos_y+1, 1, self.height-1, theme.WINDOW_BORDER_LEFT_CHAR)
  gpu.fill(self.pos_x+self.width-1, self.pos_y+1, 1, self.height-1, theme.WINDOW_BORDER_RIGHT_CHAR)
  -- title bar / top border
  gpu.setBackground(theme.WINDOW_TITLEBAR_BG)
  gpu.setForeground(theme.WINDOW_TITLEBAR_FG)
  gpu.fill(self.pos_x, self.pos_y, self.width, 1, theme.WINDOW_TITLEBAR_CHAR)
  -- title
  gpu.setBackground(theme.WINDOW_TITLE_BG)
  gpu.setForeground(theme.WINDOW_TITLE_FG)
  local title = " "..self.title.." "
  -- @TODO toggle? display geometry
  title = title.." x:"..self.pos_x.." y:"..self.pos_y.." w:"..self.width.." h:"..self.height
  if theme.WINDOW_TITLE_UPPER then title = title:upper() end
  if theme.WINDOW_TITLE_ALIGN == "left" then 
    gpu.set(self.pos_x+1, self.pos_y, title)
  elseif theme.WINDOW_TITLE_ALIGN == "center" then
    gpu.set(self.pos_x+self.width/2 - #title/2, self.pos_y, title)
  elseif theme.WINDOW_TITLE_ALIGN == "right" then
    gpu.set(self.pos_x+self.width-#title-1, self.pos_y, title)
  end
  -- resize icon
  gpu.set(self.pos_x+self.width-1, self.pos_y+self.height-1, theme.WINDOW_RESIZE_CHAR)
  return self
end

-- row tests
-- local win1 = Window:setLayout("x1 y1 w2 h2"):draw()
-- local win2 = Window:setLayout("x3 y1 w2 h2"):draw()
-- local win3 = Window:setLayout("x5 y1 w2 h2"):draw()

-- local win6 = Window:setLayout("x1 y3 w1 h1"):draw()
-- local win7 = Window:setLayout("x2 y3 w5 h1"):draw()

-- local win4 = Window:setLayout("x1 y4 w3 h1"):draw()
-- local win5 = Window:setLayout("x4 y4 w3 h1"):draw()

-- local win8 = Window:setLayout("x1 y5 w4 h1"):draw()
-- local win9 = Window:setLayout("x5 y5 w2 h1"):draw()

-- col tests
-- Window:setLayout("x1 y1 w1 h1"):draw()
-- Window:setLayout("x1 y2 w1 h5"):draw()

-- Window:setLayout("x2 y1 w1 h2"):draw()
-- Window:setLayout("x2 y3 w1 h4"):draw()

-- Window:setLayout("x3 y1 w1 h3"):draw()
-- Window:setLayout("x3 y4 w1 h3"):draw()

-- Window:setLayout("x4 y1 w1 h4"):draw()
-- Window:setLayout("x4 y5 w1 h2"):draw()

-- Window:setLayout("x5 y1 w1 h5"):draw()
-- Window:setLayout("x5 y6 w1 h1"):draw()

-- Window:setLayout("x6 y1 w1 h6"):draw()

-- normal
-- Window:setLayout("x1 y3 w6 h4"):setTitle("Big graph with lots of things"):draw()

-- Window:setLayout("x1 y1 w2 h2"):setTitle("Small monitor"):draw()
-- Window:setLayout("x3 y1 w2 h2"):setTitle("Keep in check"):draw()
-- Window:setLayout("x5 y1 w2 h4"):setTitle("Some controls"):draw()

return Window