function init(virtual)
    if storage.isDirty == nil then storage.isDirty = false end
end

function swapItemAt(item, slot)
    if storage.history == nil then storage.history = {} end
    
    local cId = entity.id()
    local stored = nil
    local size = world.containerSize(cId)
    local index = nil
    
    for i = 0,size,1 do
      local it = world.containerItemAt(cId, i)
      if slotCompare(it, slot) and isNew(it, i) then
        stored = world.containerTakeAt(cId, i)
        storage.history[tostring(i+1)] = item
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

function checkOwnership(seed)
  if storage.npcseed and entity.configParameter("isPersonalStorage") then
    return seed == storage.npcseed
  end
  return nil
end

function claimLocker(seed)
  if entity.configParameter("isPersonalStorage") then
    if seed == nil then
      entity.setAnimationState("switchState", "off")
    else
      entity.setAnimationState("switchState", "on")
    end
    storage.npcseed = seed
    return entity.position()
  end
  return nil
end

function slotCompare(item, slot)
  if item == nil or slot == nil then return nil end
  return world.itemType(item.name) == slot
end

function isNew(item, index)
    if storage.history == nil then return nil end
    if item == nil then return nil end
    if storage.history[tostring(index+1)] == nil then return true end
    --TODO deep compare?
    return storage.history[tostring(index+1)].name ~= item.name
end

function onInventoryUpdate()
  if storage.history == nil then storage.history = {} end
  local cId = entity.id()
  local size = world.containerSize(cId)
  
  storage.isDirty = false
  for i = 0,size,1 do
    local item = world.containerItemAt(cId, i)
    if item == nil then storage.history[tostring(i+1)] = nil end
    if isNew(item, i) then
      storage.isDirty = true
    end
  end
end

function hasEquipment(id)
  --TODO remove when fixed 
  onInventoryUpdate()
  
  if entity.configParameter("isPersonalStorage") then
    if storage.seed and storage.seed ~= world.callScriptedEntity(id, "entity.seed") then return false end
  end
  if entity.configParameter("isSpawnerExclusive") then
    if world.callScriptedEntity(id, "entity.configParameter", "spawnedBy") ~= nil then
      return storage.isDirty
    end
  else
    return storage.isDirty
  end
end