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
    if world.callScriptedEntity(stateData.targetId, "checkOwnership", entity.seed()) ~= false then
      npcequipment.swapContainer(stateData.targetId)
      if storage.npceq then
        storage.npceq.locker = world.callScriptedEntity(stateData.targetId, "claimLocker", entity.seed())
      end
    end
    return true,1
  else
    moveTo(stateData.targetPosition, dt)
  end

  return false
end

function equipState.findTarget(position)
    --TODO What shape query?
  local objectIds = world.objectQuery(position, 30, { callScript = "hasEquipment", callScriptArgs = {entity.id()} })
  for _,id in ipairs(objectIds) do
    local ownership = world.callScriptedEntity(id, "checkOwnership", entity.seed())
    local personal = world.callScriptedEntity(id, "entity.configParameter", "isPersonalStorage")
    if ownership or not personal or (ownership == nil and (storage.npceq == nil or storage.npceq.locker == nil)) then 
      return {targetId = id, targetPosition = world.entityPosition(id)}
    end
  end
  return nil
end
--------------------------------------------------------------------------------