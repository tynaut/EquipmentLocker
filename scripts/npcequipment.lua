--------------------------------------------------------------------------------
npcequipment = {
  isDirty = false,
  delay = 0.25,
  timer = 0,
  lockerTimer = 0,
  lockerDelay = 300
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
  if storage.npceq then
    npcequipment.timer = npcequipment.timer - entity.dt()
    if npcequipment.timer < 0 then
      npcequipment.timer = npcequipment.delay
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
    
    npcequipment.lockerTimer = npcequipment.lockerTimer - entity.dt()
    if npcequipment.lockerTimer < 0 then
      npcequipment.lockerTimer = npcequipment.lockerDelay
      npcequipment.checkLocker()
    end
  end
end
--------------------------------------------------------------------------------
function npcequipment.die()
--TODO if companion, drop stuff
  local locker = npcequipment.checkLocker()
  if locker then world.callScriptedEntity(locker, "claimLocker", nil) end
end
--------------------------------------------------------------------------------
function npcequipment.store()
  local eq = {
    head = entity.getItemSlot("head"),
    chest = entity.getItemSlot("chest"),
    legs = entity.getItemSlot("legs"),
    back = entity.getItemSlot("back"),
    primary = entity.getItemSlot("primary"),
    alt = entity.getItemSlot("alt")
  }
  storage.npceq = eq
end
--------------------------------------------------------------------------------
function npcequipment.unequip()
  if storage.npceq ~= nil then
    entity.setItemSlot("head", nil)
    entity.setItemSlot("chest", nil)
    entity.setItemSlot("legs", nil)
    entity.setItemSlot("back", nil)
    entity.setItemSlot("primary", nil)
    entity.setItemSlot("alt", nil)
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
    entity.setItemSlot("primary", eq.primary)
    entity.setItemSlot("alt", eq.alt)
  end
  npcequipment.isDirty = false
end
--------------------------------------------------------------------------------
function npcequipment.swapContainer(storageId)
  if storage.npceq == nil then npcequipment.store() end
  local eq = storage.npceq
  eq.head = world.callScriptedEntity(storageId, "swapItemAt", eq.head, "headarmor")
  eq.chest = world.callScriptedEntity(storageId, "swapItemAt", eq.chest, "chestarmor")
  eq.legs = world.callScriptedEntity(storageId, "swapItemAt", eq.legs, "legsarmor")
  eq.back = world.callScriptedEntity(storageId, "swapItemAt", eq.back, "backarmor")
  
  if self.hasMeleeWeapon then
    eq.primary = world.callScriptedEntity(storageId, "swapItemAt", eq.primary, "sword")
  end
  if self.hasRangedWeapon then
    eq.primary = world.callScriptedEntity(storageId, "swapItemAt", eq.primary, "gun")
  end
  if self.hasShield then
    eq.alt = world.callScriptedEntity(storageId, "swapItemAt", eq.alt, "shield")
  end
  storage.npceq = eq
  npcequipment.update()
end
--------------------------------------------------------------------------------
function npcequipment.checkLocker()
  local eq = storage.npceq
  if eq == nil or eq.locker == nil then return false end
  world.loadRegion({eq.locker[1] - 3, eq.locker[2] - 3, eq.locker[1] + 3, eq.locker[2] + 3})
  local objectIds = world.objectQuery(eq.locker, 5, {callScript = "checkOwnership", callScriptArgs = {entity.seed()}})  
  if objectIds[1] == nil then
    storage.npceq.locker = nil
    return nil
  end
  
  return objectIds[1]
end