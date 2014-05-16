--------------------------------------------------------------------------------
npcequipment = {
  isDirty = false,
  delay = 0
}

if delegate ~= nil then delegate.create("npcequipment") end
--------------------------------------------------------------------------------
function npcequipment.init()  
    if storage.npceq ~= nil then
        npcequipment.unequip()
    else
        npcequipment.store()
    end
end
--------------------------------------------------------------------------------
function npcequipment.main(args)
    npcequipment.delay = npcequipment.delay + entity.dt()
    
    if npcequipment.delay > 0.25 then
        npcequipment.delay = 0
        local p = entity.position()
        if world.isVisibleToPlayer({p[1]-2, p[2]-2, p[1]+2, p[2]+2}) then
            if npcequipment.isDirty then
              delegate.delayCallback("npcequipment", "update", nil, 0)
            end
        else
            if not npcequipment.isDirty then
              delegate.delayCallback("npcequipment", "unequip", nil, 0)
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
    entity.setItemSlot("head", nil)
    entity.setItemSlot("chest", nil)
    entity.setItemSlot("legs", nil)
    entity.setItemSlot("back", nil)
    npcequipment.isDirty = true
end
--------------------------------------------------------------------------------
function npcequipment.update()
    local eq = storage.npceq
    if eq == nil then return end
    
    entity.setItemSlot("head", eq.head)
    entity.setItemSlot("chest", eq.chest)
    entity.setItemSlot("legs", eq.legs)
    entity.setItemSlot("back", eq.back)
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

--[[function equipment.generate()
--TODO fix equipment to match any species
--TODO add safty checks
    local npcItem = "items." .. entity.species() .. "[0][1][0]"
    if storage.equipment.head == nil then
        storage.equipment.head = entity.randomizeParameter(npcItem .. ".head")
    end
    if storage.equipment.chest == nil then
        storage.equipment.chest = entity.randomizeParameter(npcItem .. ".chest")
    end
    if storage.equipment.legs == nil then
        storage.equipment.legs = entity.randomizeParameter(npcItem .. ".legs")
    end
    if storage.equipment.back == nil then
        storage.equipment.back = entity.randomizeParameter(npcItem .. ".back")
    end
end]]--