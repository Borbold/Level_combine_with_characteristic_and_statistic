﻿function UpdateSave()
  local dataToSave = {
    ["allObjectGUID"] = allObjectGUID, ["gameCharacterGUID"] = gameCharacterGUID,
    ["allFeatureGUID"] = allFeatureGUID
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  replacementTable = {["(+"] = "(-", ["(-"] = "(+", ["(/"] = "(*", ["(*"] = "(/", ["-"] = "+", ["/"] = "*", ["*"] = "/"}
  allObjectGUID = {}
  creatingUI = true
  if(savedData != "") then
    local loadedData = JSON.decode(savedData)
    allObjectGUID = loadedData.allObjectGUID or {}
    gameCharacterGUID = loadedData.gameCharacterGUID or nil
    allFeatureGUID = loadedData.allFeatureGUID or nil
  end
  Wait.time(CreateAllFeatureObj, 0.6)
end

function CreateAllFeatureObj()
  allFeatureObj = {}
  for _,guid in ipairs(allFeatureGUID or {}) do
    table.insert(allFeatureObj, getObjectFromGUID(guid))
  end
end

function ReturnOriginal()
	self.UI.setAttribute("inputMaxWeight", "text", 99)
end

function onCollisionEnter(obj)
  if(obj.collision_object.getName() == "" and obj.collision_object.getPosition().y > self.getPosition().y) then
    broadcastToAll("Добавте таланту название!")
    return
  end
  if(creatingUI and obj.collision_object.getName() ~= "") then
    table.insert(allObjectGUID, obj.collision_object.getGUID())
    CreateTimerForRecreate(obj.collision_object.getDescription(), obj.collision_object.getGUID())
  end
end

function onCollisionExit(obj)
  if(creatingUI and obj.collision_object.getName() ~= "") then
    local locGUID = obj.collision_object.getGUID()
    for i,v in ipairs(allObjectGUID) do
      if(v == locGUID) then
        table.remove(allObjectGUID, i)
        break
      end
    end
    local newDescription = ""
    for S in obj.collision_object.getDescription():gmatch("%S+") do
      newDescription = newDescription .. (replacementTable[S] or S) .. " "
    end
    CreateTimerForRecreate(newDescription, obj.collision_object.getGUID())
  end
end

function CreateTimerForRecreate(itemDesc, guidItem)
  Wait.time(|| FeatureRecalculation(itemDesc, guidItem), 0.1)

  local locIdentifier = "RecreatePanel"..self.getGUID()
  Timer.destroy(locIdentifier)
  Timer.create({
    identifier     = locIdentifier,
    function_name  = "RecreatePanel",
    delay          = 2,
    repetitions    = 1
  })
end
function RecreatePanel()
  if(gameCharacterGUID) then
    -- Пересоздать панель
    getObjectFromGUID(gameCharacterGUID).call("CreateFields")
  end
  UpdateSave()
end
function FeatureRecalculation(itemDesc, guidItem)
  for i,charObj in ipairs(allFeatureObj) do
    local tableName = {}
    for S in charObj.getName():gmatch("%S+") do
      table.insert(tableName, S)
    end

    if(tableName[2] and itemDesc:find(tableName[2])) then
      local findCharac = itemDesc:find(tableName[2])
      local clipping = itemDesc:sub(findCharac)
      clipping = clipping:sub(0, clipping:find(")"))
      charObj.call("RecalculationValueInInventory", {input = clipping:match("%((.+)%)")})
    end
  end
end

function GetAllObjectGUID()
  return allObjectGUID
end

function SetGameCharacter(param)
  gameCharacterGUID = param.charGUID
  allFeatureGUID = param.allFeatGUID
  CreateAllFeatureObj()
  UpdateSave()
end