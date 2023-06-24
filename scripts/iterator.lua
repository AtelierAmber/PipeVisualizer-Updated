local flib_queue = require("__flib__/queue")

--- @alias PlayerIndex uint
--- @alias FluidSystemID uint
--- @alias PlayerIterators table<PlayerIndex, table<FluidSystemID, Iterator>>

--- @class Iterator
--- @field color Color?
--- @field completed table<uint, boolean>
--- @field id FluidSystemID
--- @field in_overlay boolean
--- @field objects RenderObjectID[]
--- @field player LuaPlayer
--- @field queue Queue<LuaEntity>

--- @param starting_entity LuaEntity
--- @param player LuaPlayer
--- @param in_overlay boolean
local function request(starting_entity, player, in_overlay)
  if not global.iterator then
    return
  end

  local fluidbox = starting_entity.fluidbox
  -- if not fluidbox then
  --   return
  -- end
  for i = 1, #fluidbox do
    --- @cast i uint
    local id = fluidbox.get_fluid_system_id(i)
    if not id then
      goto continue
    end

    local player_iterators = global.iterator[player.index]
    if not player_iterators then
      player_iterators = {}
      global.iterator[player.index] = player_iterators
    end
    local iterator = player_iterators[id]
    if iterator then
      if in_overlay and not iterator.completed[starting_entity.unit_number] then
        flib_queue.push_back(iterator.queue, starting_entity)
      end
      goto continue
    end

    local queue = flib_queue.new()
    flib_queue.push_back(queue, starting_entity)

    local color = { r = 0.3, g = 0.3, b = 0.3 }
    local contents = fluidbox.get_fluid_system_contents(i)
    if contents and next(contents) then
      color = global.fluid_colors[next(contents)]
    end

    --- @type Iterator
    player_iterators[id] = {
      completed = {},
      color = color,
      id = id,
      in_overlay = in_overlay,
      objects = {},
      player = player,
      queue = queue,
    }

    ::continue::
  end
end

--- @param iterator Iterator
--- @param entity LuaEntity
local function iterate_entity(iterator, entity)
  if iterator.completed[entity.unit_number] then
    return
  end

  local players_array = { iterator.player.index }

  local fluidbox = entity.fluidbox
  -- if not fluidbox then
  --   return
  -- end
  for i = 1, #fluidbox do
    --- @cast i uint
    local id = fluidbox.get_fluid_system_id(i)
    if id ~= iterator.id then
      goto continue
    end

    local connections = fluidbox.get_connections(i)
    for _, connection in pairs(connections) do
      if iterator.completed[connection.owner.unit_number] then
        goto inner_continue
      end

      iterator.objects[#iterator.objects + 1] = rendering.draw_line({
        color = {},
        width = 6,
        surface = entity.surface_index,
        from = entity,
        to = connection.owner,
        players = players_array,
      })
      iterator.objects[#iterator.objects + 1] = rendering.draw_line({
        color = iterator.color,
        width = 3,
        surface = entity.surface_index,
        from = entity,
        to = connection.owner,
        players = players_array,
      })

      if not iterator.in_overlay then
        flib_queue.push_back(iterator.queue, connection.owner)
      end

      ::inner_continue::
    end

    ::continue::
  end

  iterator.completed[entity.unit_number] = true
end

local entities_per_tick = 10
--- @param iterator Iterator
local function iterate(iterator)
  for _ = 1, entities_per_tick do
    local entity = flib_queue.pop_front(iterator.queue)
    if not entity then
      return
    end
    iterate_entity(iterator, entity)
  end
end

--- @param iterator Iterator
local function clear(iterator)
  for _, id in pairs(iterator.objects) do
    rendering.destroy(id)
  end
  local player_iterators = global.iterator[iterator.player.index]
  player_iterators[iterator.id] = nil
  if not next(player_iterators) then
    global.iterator[iterator.player.index] = nil
  end
end

--- @param player LuaPlayer
local function clear_all(player)
  if not global.iterator then
    return
  end
  local player_iterators = global.iterator[player.index]
  if not player_iterators then
    return
  end
  for _, iterator in pairs(player_iterators) do
    clear(iterator)
  end
end

--- @param starting_entity LuaEntity
--- @param player LuaPlayer
local function request_or_clear(starting_entity, player)
  if not global.iterator then
    return
  end
  local player_iterators = global.iterator[player.index]
  if not player_iterators then
    request(starting_entity, player, false)
    return
  end
  local did_clear = false
  for _, iterator in pairs(player_iterators) do
    if iterator.completed[starting_entity.unit_number] then
      did_clear = true
      clear(iterator)
    end
  end
  if not did_clear then
    request(starting_entity, player, false)
  end
end

local function on_tick()
  if not global.iterator then
    return
  end
  for _, iterators in pairs(global.iterator) do
    for _, iterator in pairs(iterators) do
      iterate(iterator)
    end
  end
end

--- @param e EventData.CustomInputEvent
local function on_toggle_hover(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local entity = player.selected
  if not entity then
    clear_all(player)
    return
  end
  request_or_clear(entity, player)
end

local iterator = {}

function iterator.on_init()
  --- @type PlayerIterators
  global.iterator = {}
end

iterator.events = {
  [defines.events.on_tick] = on_tick,
  ["pv-toggle-hover"] = on_toggle_hover,
}

iterator.clear_all = clear_all
iterator.request = request

return iterator