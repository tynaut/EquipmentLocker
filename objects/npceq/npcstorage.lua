function init(virtual)
    if storage.history == nil then storage.history = {} end
end

function swapItemAt(item, slot)
    local cId = entity.id()
    local stored = nil
    local size = world.containerSize(cId)
    local index = nil
    
    for i = 0,size,1 do
        local it = world.containerItemAt(cId, i)
        if it and world.itemType(it.name) == slot then
          stored = item
          index = i
          break
        end
    end
    
    if stored == nil or stored.name == nil then return item end
    --if not isSlotType(stored.name, index) then return item end
    if isCompanionAdded(stored, index) then return item end
    storage.history[index+1] = item
    stored = world.containerTakeAt(cId, index)
    if item ~= nil and item.name ~= nil then
        local result = world.containerPutItemsAt(cId, item, index)
        if result then
            world.spawnItem(result.name, entity.position(), result.count, result.data)
        end
    end
    return stored
end

function isSlotType(name, index)
    if index == 0 then
        return world.itemType(name) == "headarmor"
    elseif index == 1 then
        return world.itemType(name) == "chestarmor"
    elseif index == 2 then
        return world.itemType(name) == "legsarmor"
    elseif index == 3 then
        return world.itemType(name) == "backarmor"
    end
    return false
end

function isCompanionAdded(item, index)
    if storage.history == nil then return nil end
    if storage.history[index+1] == nil then return nil end
    if item == nil then return nil end
    --TODO deep compare?
    return storage.history[index+1].name == item.name
end

function hasCapability(capability)
  if capability == 'equipment' then
    local cId = entity.id()
    local size = world.containerSize(cId)
    local newItem = false
    for i = 0,size,1 do
        --TODO make this shit work
        local item = world.containerItemAt(cId, i)
        local isCAdded = isCompanionAdded(item, i)
        if isCAdded ~= true then storage.history[i+1] = nil end
        if isCAdded == false then newItem = true end
    end
    return true
  else
    return false
  end
end