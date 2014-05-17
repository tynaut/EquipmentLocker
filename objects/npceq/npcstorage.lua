function init(virtual)
    if storage.history == nil then storage.history = {} end
    if storage.isDirty == nil then storage.isDirty = false end
end

function swapItemAt(item, slot)
    local cId = entity.id()
    local stored = nil
    local size = world.containerSize(cId)
    local index = nil
    
    for i = 0,size,1 do
      local it = world.containerItemAt(cId, i)
      if slotCompare(it, slot) and isNew(it, i) then
        stored = world.containerTakeAt(cId, i)
        storage.history[i+1] = item
        if item ~= nil and item.name ~= nil then
          local result = world.containerPutItemsAt(cId, item, i)
          if result then
              world.spawnItem(result.name, entity.position(), result.count, result.data)
          end
        end
        item = stored
        break
      end
    end
    return item
end

--TODO locker claiming
--[[function claimLocker(id)
  local seed = nil
  if id then seed = world.callScriptedEntity(id, "entity.seed") end
  storage.npcseed = seed
end]]--

function slotCompare(item, slot)
  if item == nil or slot == nil then return nil end
  return world.itemType(item.name) == slot
end

function isNew(item, index)
    if storage.history == nil then return nil end
    if item == nil then return nil end
    if storage.history[index+1] == nil then return true end
    --TODO deep compare?
    return storage.history[index+1].name ~= item.name
end

function onInventoryUpdate()
  local cId = entity.id()
  local size = world.containerSize(cId)
  
  storage.isDirty = false
  for i = 0,size,1 do
    local item = world.containerItemAt(cId, i)
    if item == nil then storage.history[i+1] = nil end
    if isNew(item, i) then
      storage.isDirty = true
    end
  end
end

function hasEquipment(id)
  --[[if entity.configParameter("isPersonalStorage") then
    if storage.seed and storage.seed ~= world.callScriptedEntity(id, "entity.seed") then return false end
  end]]--
  if entity.configParameter("isSpawnerExclusive") then
    if world.callScriptedEntity(id, "entity.configParameter", "spawnedBy") ~= nil then
      return storage.isDirty
    end
  else
    return storage.isDirty
  end
end