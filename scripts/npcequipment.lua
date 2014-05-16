--------------------------------------------------------------------------------
npcequipment = {
  isDirty = false,
  delay = 0.25,
  timer = 0
}

if delegate ~= nil then delegate.create("npcequipment") end
--------------------------------------------------------------------------------
function npcequipment.init()  
    if storage.npceq == nil then
      storage.npceq = entity.configParameter("npceq", nil)
    end
    npcequipment.isDirty = true
end
--------------------------------------------------------------------------------
function npcequipment.main(args)
    npcequipment.timer = npcequipment.timer + entity.dt()
    
    if npcequipment.timer > npcequipment.delay then
        npcequipment.timer = 0
        local p = entity.position()
        if world.isVisibleToPlayer({p[1]-2, p[2]-2, p[1]+2, p[2]+2}) then
            if npcequipment.isDirty then
              npcequipment.update()
            end
        else
            if not npcequipment.isDirty then
              npcequipment.unequip()
            end
        end
    end
end
--------------------------------------------------------------------------------
function npcequipment.die()
--TODO if companion, drop stuff
end
--------------------------------------------------------------------------------
function npcequipment.store()
  local eq = entity.configParameter("npceq", nil)
  if eq == nil then
    eq = {
      head = entity.getItemSlot("head"),
      chest = entity.getItemSlot("chest"),
      legs = entity.getItemSlot("legs"),
      back = entity.getItemSlot("back")
    }
  end
  storage.npceq = eq
end
--------------------------------------------------------------------------------
function npcequipment.unequip()
  if storage.npceq ~= nil then
    entity.setItemSlot("head", nil)
    entity.setItemSlot("chest", nil)
    entity.setItemSlot("legs", nil)
    entity.setItemSlot("back", nil)
  end
  npcequipment.isDirty = true
end
--------------------------------------------------------------------------------
function npcequipment.update()
  local eq = storage.npceq
  if eq ~= nil then    
    entity.setItemSlot("head", eq.head)
    entity.setItemSlot("chest", eq.chest)
    entity.setItemSlot("legs", eq.legs)
    entity.setItemSlot("back", eq.back)
  end
  npcequipment.isDirty = false
end
--------------------------------------------------------------------------------
function npcequipment.swapContainer(storageId)
    local eq = storage.npceq
    eq.head = world.callScriptedEntity(storageId, "swapItemAt", eq.head, "headarmor")
    eq.chest = world.callScriptedEntity(storageId, "swapItemAt", eq.chest, "chestarmor")
    eq.legs = world.callScriptedEntity(storageId, "swapItemAt", eq.legs, "legsarmor")
    eq.back = world.callScriptedEntity(storageId, "swapItemAt", eq.back, "backarmor")
    storage.npceq = eq
    npcequipment.update()
end