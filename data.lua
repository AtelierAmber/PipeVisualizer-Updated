data:extend({
  {
    type = "custom-input",
    name = "pv-visualize-selected",
    key_sequence = "H",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "pv-toggle-overlay",
    key_sequence = "SHIFT + H",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "pv-color-by-fluid-system",
    key_sequence = "CONTROL + H",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "pv-toggle-hover",
    key_sequence = "",
    action = "lua",
  },
  {
    type = "shortcut",
    name = "pv-toggle-overlay",
    icon = {
      filename = "__PipeVisualizer__/graphics/overlay-dark-x32.png",
      size = 32,
      mipmap_count = 2,
      flags = { "gui-icon" },
    },
    disabled_icon = {
      filename = "__PipeVisualizer__/graphics/overlay-light-x32.png",
      size = 32,
      mipmap_count = 2,
      flags = { "gui-icon" },
    },
    small_icon = {
      filename = "__PipeVisualizer__/graphics/overlay-dark-x24.png",
      size = 24,
      mipmap_count = 2,
      flags = { "gui-icon" },
    },
    disabled_small_icon = {
      filename = "__PipeVisualizer__/graphics/overlay-light-x24.png",
      size = 24,
      mipmap_count = 2,
      flags = { "gui-icon" },
    },
    associated_control_input = "pv-toggle-overlay",
    action = "lua",
    toggleable = true,
  },
})

local storage_tank = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
storage_tank.name = "cursed-storage-tank"
storage_tank.fluid_box.pipe_connections[1].max_underground_distance = 5
storage_tank.fluid_box.pipe_connections[3].max_underground_distance = 5
data:extend({ storage_tank })

data:extend({
  {
    type = "sprite",
    name = "pv-entity-box",
    filename = "__PipeVisualizer__/graphics/entity-box.png",
    size = 64,
    scale = 0.5,
    flags = { "icon" },
    draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-underground-connection",
    filename = "__PipeVisualizer__/graphics/underground-connection.png",
    size = 64,
    scale = 0.5,
    flags = { "icon" },
    draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow",
    filename = "__PipeVisualizer__/graphics/fluid-arrow.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow-output",
    filename = "__PipeVisualizer__/graphics/fluid-arrow-output.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow-input",
    filename = "__PipeVisualizer__/graphics/fluid-arrow-input.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow-input-output",
    filename = "__PipeVisualizer__/graphics/fluid-arrow-input-output.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    draw_as_glow = true,
  },
})

for i = 0, 15 do
  data:extend({
    {
      type = "sprite",
      name = "pv-pipe-connections-" .. i,
      filename = "__PipeVisualizer__/graphics/pipe-connections.png",
      x = i * 64,
      size = 64,
      scale = 0.5,
      flags = { "icon" },
      draw_as_glow = true,
    },
  })
end
