function UpdateSave()
  local dataToSave = { ["maxWeight"] = maxWeight,
    ["allObjectGUID"] = allObjectGUID, ["gameCharacterGUID"] = gameCharacterGUID,
    ["allFeatureGUID"] = allFeatureGUID
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  allObjectGUID = {}
  currentWeight, maxWeight = 0, 20
  if(savedData != "") then
    local loadedData = JSON.decode(savedData)
    maxWeight = loadedData.maxWeight or 20
    allObjectGUID = loadedData.allObjectGUID or {}
    gameCharacterGUID = loadedData.gameCharacterGUID or nil
    allFeatureGUID = loadedData.allFeatureGUID or nil
  end
  Wait.time(SetNumber, 0.5)
  Wait.time(CreateAllFeatureObj, 0.6)
end

function CreateAllFeatureObj()
  allFeatureObj = {}
  for _,guid in ipairs(allFeatureGUID or {}) do
    table.insert(allFeatureObj, getObjectFromGUID(guid))
  end
end

function SetNumber()
  local textWeight = "Weight: " .. currentWeight .. "/" .. maxWeight
	self.UI.setValue("weight", textWeight)
  UpdateSave()
end

function InputChangeWeight(player, input)
  maxWeight = tonumber(input ~= "" and input or "0")
  local textWeight = "Weight: " .. currentWeight .. "/" .. maxWeight
	self.UI.setValue("weight", textWeight)
  UpdateSave()
end

function ReturnOriginal()
	self.UI.setAttribute("inputMaxWeight", "text", 99)
end

function onCollisionEnter(obj)
  if(obj.collision_object.getName() == "" and obj.collision_object.getPosition().y > self.getPosition().y) then
    broadcastToAll("Добавте предмету название!")
    return
  end
  if(currentWeight and obj.collision_object.getName() ~= "") then
    table.insert(allObjectGUID, obj.collision_object.getGUID())
    WeightCalculation()
    CreateTimerForRecreate(obj.collision_object.getDescription(), obj.collision_object.getGUID())
  end
end

function onCollisionExit(obj)
  if(currentWeight and obj.collision_object.getName() ~= "") then
    local locGUID = obj.collision_object.getGUID()
    for i,v in ipairs(allObjectGUID) do
      if(v == locGUID) then
        table.remove(allObjectGUID, i)
        break
      end
    end
    WeightCalculation()
    CreateTimerForRecreate(nil, obj.collision_object.getGUID())
  end
end

function CreateTimerForRecreate(itemDesc, guidItem)
  Wait.time(|| FeatureRecalculation(itemDesc, guidItem), 0.05)

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
end
function FeatureRecalculation(itemDesc, guidItem)
  for i,charObj in ipairs(allFeatureObj) do
    local tableName = {}
    for S in charObj.getName():gmatch("%S+") do
      table.insert(tableName, S)
    end

    if(not itemDesc) then
      local param = {guid = guidItem, input = nil}
      charObj.call("RecalculationValueInInventory", param)
    elseif(tableName[2] and itemDesc:find(tableName[2])) then
      local findCharac = itemDesc:find(tableName[2])
      local clipping = itemDesc:sub(findCharac)
      clipping = clipping:sub(0, clipping:find(")"))
      local param = {guid = guidItem, input = clipping:match("%((.+)%)")}
      charObj.call("RecalculationValueInInventory", param)
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

function WeightCalculation()
  currentWeight = 0
  for i,v in ipairs(allObjectGUID) do
    if(not getObjectFromGUID(v)) then table.remove(allObjectGUID, i) break end
    local allDesctiption = getObjectFromGUID(v).getDescription()
    local isFlag = false
    for S in allDesctiption:gmatch("%S+") do
      if(isFlag) then
        S = S:gsub(",", ".")
        currentWeight = currentWeight + tonumber(S)
        break
      end
      if(S == "вес:" or S == "weight:") then
        isFlag = true
      end
    end
  end
  SetNumber()
end

function Reset()
	currentWeight = 0
  SetNumber()
end