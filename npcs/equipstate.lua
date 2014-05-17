equipState = {}

function equipState.enter()
  if npcequipment == nil then return nil,10 end
  local position = entity.position()
  local target = equipState.findTarget(position)
  if target ~= nil then
    return {
      targetId = target.targetId,
      targetPosition = target.targetPosition,
      timer = 10
    }
  end
  return nil,1
end

function equipState.update(dt, stateData)
  stateData.timer = stateData.timer - dt
  if stateData.timer < 0 then
    return true,1
  end

  local position = entity.position()
  local toTarget = world.distance(stateData.targetPosition, position)
  local distance = world.magnitude(toTarget)
  if distance < 3 then
    npcequipment.swapContainer(stateData.targetId)
    if storage.npceq then
      storage.npceq.locker = world.callScriptedEntity(stateData.targetId, "claimLocker", entity.seed())
    end
    return true,1
  else
    moveTo(stateData.targetPosition, dt)
  end

  return false
end

function equipState.findTarget(position)
    --TODO What shape query?
  local objectIds = world.objectQuery(position, 20, { callScript = "hasEquipment", callScriptArgs = {entity.id()} })
  for _,id in ipairs(objectIds) do
    local ownership,available = world.callScriptedEntity(id, "checkOwnership", entity.seed())
    if ownership ~= false or (available and (storage.npceq == nil or storage.npceq.locker == nil)) then 
      return {targetId = id, targetPosition = world.entityPosition(id)}
    end
  end
  return nil
end
--------------------------------------------------------------------------------