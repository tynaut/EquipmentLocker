equipState = {}

function equipState.enter()
  local position = entity.position()
  local target = equipState.findTarget(position)
  if target ~= nil then
    return {
      targetId = target.targetId,
      targetPosition = target.targetPosition,
      timer = 10
    }
  end
  return nil
end

function equipState.update(dt, stateData)
  stateData.timer = stateData.timer - dt
  if stateData.timer < 0 then
    return true, entity.configParameter("work.cooldown", nil)
  end

  local position = entity.position()
  local toTarget = world.distance(stateData.targetPosition, position)
  local distance = world.magnitude(toTarget)
  if distance < entity.configParameter("work.toolRange") then
    npcequipment.swapContainer(stateData.targetId)
    return true
  else
    move(toTarget, dt)
  end

  return false
end

function equipState.findTarget(position)
    --TODO What shape query?
    local objectIds = world.objectQuery(position, 20, { callScript = "hasCapability", callScriptArgs = {"equipment"} })
    if objectIds[1] ~= nil then
        return {targetId = objectIds[1], targetPosition = world.entityPosition(objectIds[1])}
    end
    return nil
end
--------------------------------------------------------------------------------