﻿local allIndex = {
  ["SU"] = "startCharacteristicUsual",
  ["SC"] = "startCharacteristicCombat",
  ["SP"] = "startCharacteristicPeace",
  ["PLU"] = "characteristicPerLevelUsual",
  ["PLC"] = "characteristicPerLevelCombat",
  ["PLP"] = "characteristicPerLevelPeace",
  ["LPU"] = "levelPassUsual",
  ["LPC"] = "levelPassCombat",
  ["LPP"] = "levelPassPeace"
}

function UpdateSave(levelUP)
  ChecLevelPass(levelUP)
  self.setName(Player[DenoteSth()].steam_name or DenoteSth())
  local dataToSave = { ["savedExp"] = exp, ["savedLastLevel"] = level, ["nextLevelExperience"] = nextLevelExperience,
    ["allFeatureGUID"] = allFeatureGUID, ["allStatisticGUID"] = allStatisticGUID,
    ["startCharacteristic"] = startCharacteristic,
    ["characteristicPerLevel"] = characteristicPerLevel,
    ["levelPass"] = levelPass, ["localLevelPass"] = localLevelPass,
    ["listCharacteristicPerLevel"] = listCharacteristicPerLevel,
    ["maxLevel"] = maxLevel, ["LBN"] = LBN, ["showUIPanel"] = showUIPanel
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function ChecLevelPass(levelUP)
  local locIndex = allIndex["LPU"]
  if(CheckLevelPass(localLevelPass[locIndex])) then
    self.UI.setValue("freeCharacteristicUsual", (startCharacteristic[allIndex["SU"]] + GetSumAllCharacteristicPerLevel(usual)) - GetSumAllCharacteristic(usual))
    EnableFeatureChange(usual, levelUP)
    localLevelPass[locIndex] = levelPass[locIndex]
  end
  locIndex = allIndex["LPC"]
  if(CheckLevelPass(localLevelPass[locIndex])) then
    self.UI.setValue("freeCharacteristicCombat", (startCharacteristic[allIndex["SC"]] + GetSumAllCharacteristicPerLevel(combat)) - GetSumAllCharacteristic(combat))
    EnableFeatureChange(combat, levelUP)
    localLevelPass[locIndex] = levelPass[locIndex]
  end
  locIndex = allIndex["LPP"]
  if(CheckLevelPass(localLevelPass[locIndex])) then
    self.UI.setValue("freeCharacteristicPeace", (startCharacteristic[allIndex["SP"]] + GetSumAllCharacteristicPerLevel(peace)) - GetSumAllCharacteristic(peace))
    EnableFeatureChange(peace, levelUP)
    localLevelPass[locIndex] = levelPass[locIndex]
  end
end

function CheckLevelPass(levelPass)
	if(levelPass < 0 or (exp == 0 and level == 1)) then
    return true
  end
  return false
end

function CreateGlobalVariables()
  colorPlayer = {
    ["White"] = {r = 1, g = 1, b = 1},
    ["Red"] = {r = 0.86, g = 0.1, b = 0.09},
    ["Blue"] = {r = 0.12, g = 0.53, b = 1},
    ["Green"] = {r = 0.19, g = 0.7, b = 0.17},
    ["Yellow"] = {r = 0.9, g = 0.9, b = 0.17},
    ["Orange"] = {r = 0.96, g = 0.39, b = 0.11},
    ["Brown"] = {r = 0.44, g = 0.23, b = 0.09},
    ["Purple"] = {r = 0.63, g = 0.12, b = 0.94},
    ["Pink"] = {r = 0.96, g = 0.44, b = 0.81},
    ["Teal"] = {r = 0.13, g = 0.69, b = 0.61},
    ["Black"] = {r = 0.25, g = 0.25, b = 0.25}
  }
  RetraceValues()
  lockDistributionCharacteristic = false
  allFeatureGUID, allStatisticGUID, allFeatureObject = {}, {}, {}
  listCharacteristicPerLevel = CreateNewVariable("PL", {})
  showUIPanel = true
  nextLevelExperience = {} rangeValues = {50, 100, 150, 200}
  usual = "обычная" combat = "боевая" peace = "мирная"
end

function Confer(savedData)
  local loadedData = JSON.decode(savedData)
  maxLevel = loadedData.maxLevel or 20
  startCharacteristic = loadedData.startCharacteristic or CreateNewVariable("S", 0)
  characteristicPerLevel = loadedData.characteristicPerLevel or CreateNewVariable("PL", 0)
  levelPass = loadedData.levelPass or CreateNewVariable("LP", 1)
  localLevelPass = loadedData.localLevelPass or CreateNewVariable("LP", 1)
  listCharacteristicPerLevel = loadedData.listCharacteristicPerLevel or CreateNewVariable("PL", {})
  allFeatureGUID = loadedData.allFeatureGUID or {}
  allStatisticGUID = loadedData.allStatisticGUID or {}
  LBN = loadedData.LBN or 0
  exp = loadedData.savedExp or 0
  level = loadedData.savedLastLevel or 1
  showUIPanel = loadedData.showUIPanel
  if(loadedData.nextLevelExperience ~= nil) then nextLevelExperience = loadedData.nextLevelExperience
  else CreateLevelsExperience() end
end

function CreateNewVariable(type, val)
	local table = {
    [allIndex[type .. "U"]] = val,
    [allIndex[type .. "C"]] = val,
    [allIndex[type .. "P"]] = val
	}
  return table
end

function FunctionCall()
  Wait.time(RebuildAssets, 0.3)
  Wait.time(UpdateExperience, 0.8)
  Wait.time(SetObjectFeature, 0.85)
  Wait.time(SetCharacteristic, 0.9)
end

function SetCharacteristic()
  self.UI.setAttribute("maxLevel", "text", maxLevel)
  if(LBN > 0) then
    self.UI.setAttribute("idLBN", "text", LBN)
  end

  for index,value in pairs(allIndex) do
    Wait.time(|| ChangeInputValue(index, value), 0.2)
  end
  
  Wait.time(|| SetTextCharacteristic(allIndex["SU"], allIndex["PLU"], allIndex["LPU"]), 0.8)
  Wait.time(|| SetTextCharacteristic(allIndex["SC"], allIndex["PLC"], allIndex["LPC"]), 0.8)
  Wait.time(|| SetTextCharacteristic(allIndex["SP"], allIndex["PLP"], allIndex["LPP"]), 0.8)
end

function ChangeInputValue(id, value)
	self.UI.setAttribute(id, "value", value)
  if(value ~= 0 and CheckIndex(id, "start")) then
    self.UI.setAttribute(id, "interactable", false)
  end
end

function SetTextCharacteristic(idStart, idPerLevel, idLevelPass)
  if(GetSumAllCharacteristic(usual) ~= 0) then
    self.UI.setAttribute(idStart, "text", startCharacteristic[idStart])
    self.UI.setAttribute(idPerLevel, "text", characteristicPerLevel[idPerLevel])
    self.UI.setAttribute(idLevelPass, "text", levelPass[idLevelPass])
  elseif(GetSumAllCharacteristic(combat) ~= 0) then
    self.UI.setAttribute(idStart, "text", startCharacteristic[idStart])
    self.UI.setAttribute(idPerLevel, "text", characteristicPerLevel[idPerLevel])
    self.UI.setAttribute(idLevelPass, "text", levelPass[idLevelPass])
  elseif(GetSumAllCharacteristic(peace) ~= 0) then
    self.UI.setAttribute(idStart, "text", startCharacteristic[idStart])
    self.UI.setAttribute(idPerLevel, "text", characteristicPerLevel[idPerLevel])
    self.UI.setAttribute(idLevelPass, "text", levelPass[idLevelPass])
  else
    self.UI.setAttribute(idStart, "text", "")
    self.UI.setAttribute(idPerLevel, "text", "")
    self.UI.setAttribute(idLevelPass, "text", 1)
  end
end

function onLoad(savedData)
  Wait.time(function()
    CreateGlobalVariables()
    if(savedData != "") then
      Confer(savedData)
    end
    FunctionCall()
    Wait.time(SetInteracteble, 0.5)
    Wait.time(|| ShowOrHideUIConnectedStrips(_, _, _, _, true), 3)
  end, 1.4)
end

function SetInteracteble()
  for index,value in pairs(allIndex) do
    if(CheckIndex(value, "start") and startCharacteristic[value] ~= 0) then
      self.UI.setAttribute(value, "interactable", false)
    end
  end
end

function SetInputValue(player, input, id)
  SetValue(id, input)
end

function SetValue(id, input)
  if(input == "") then return end
    
  input = tonumber(input)
  if(CheckIndex(id, "start")) then
    if(sumAllInitialCharacteristics) then
      startCharacteristic[id] = input + sumAllInitialCharacteristics[id]
    else
      startCharacteristic[id] = input
    end
  elseif(CheckIndex(id, "PerLevel")) then
    characteristicPerLevel[id] = input
    SetUpListCharacteristicPerLevel()
  elseif(CheckIndex(id, "Pass")) then
    levelPass[id] = input
  end
  ChangeInputValue(id, input)
  UpdateSave()
end
function CheckIndex(index, type)
	if(index:find(type) ~= nil) then
    return true
  end
  return false
end

function GetSumAllCharacteristic(type)
  local sum = 0
  for _,feature in pairs(allFeatureObject) do
    if(string.match(feature.getGMNotes(), type)) then
	    sum = sum + tonumber(feature.UI.getValue("textCharacteristic"))
    end
  end
  return sum
end

function GetSumAllCharacteristicPerLevel(type)
    local sum = 0
    local list = GetValueListCheckType(type)
    for _,value in pairs(list) do
	    sum = sum + value
    end
    return sum
end

function GetValueListCheckType(type)
	if(type == usual) then
    return listCharacteristicPerLevel[allIndex["PLU"]]
  elseif(type == combat) then
    return listCharacteristicPerLevel[allIndex["PLC"]]
  elseif(type == peace) then
    return listCharacteristicPerLevel[allIndex["PLP"]]
  end
  return {}
end

function CreateLevelsExperience()
  local randomRange = {0.25, 0.25, 0.25, 0.25}
  local expectedValue = {
    rangeValues[1] * randomRange[1],
    rangeValues[2] * randomRange[2],
    rangeValues[3] * randomRange[3],
    rangeValues[4] * randomRange[4]
  }
  nextLevelExperience[1] = SumMx(expectedValue)
	for i = 2, (maxLevel - 1) do
    local Dx = Round(SumDx(expectedValue, rangeValues, randomRange))
    nextLevelExperience[i] = nextLevelExperience[i - 1] + Dx * i
  end
end

function ChangeValueExperience(player, input, idInput)
  local maxLevelScatter = 4
	for i = 1, maxLevelScatter do
    if(idInput == ("value" .. i) and input ~= "") then
      rangeValues[i] = tonumber(input or 0)
      CreateLevelsExperience()
      UpdateExperience()
      break
    end
  end
end

function PanelTool()
  self.UI.hide("panelToolFeature")
  if(self.UI.getAttribute("panelTool", "active") == "false") then
    self.UI.show("panelTool")
  else
    self.UI.hide("panelTool")
  end
end

function SumMx(expectedValue)
  local sum = 0
	for i = 1, #expectedValue do
    sum = sum + expectedValue[i]
  end
  return sum
end

function SumDx(expectedValue, rangeValues, randomRange)
	local sum = 0
  for i = 1, #expectedValue do
    sum = sum + ((rangeValues[i] - expectedValue[i]) ^ 2) * randomRange[i]
  end
  sum = sum ^ 0.5
  return sum
end

function InputChangeExperience(player, input)
  if(AllowChange()) then
    if(CheckPlayer(player.color)) then
      exp = exp + ((input ~= "" and input) or 0)
      exp = (exp >= 0 and exp) or 0
      UpdateExperience()
    end
  end
end

function AllowChange()
  local featureDistribution = string.lower(self.UI.getAttribute("closeDistributionCharacteristic", "interactable"))
	if((#allFeatureObject > 0 and featureDistribution == "false") or #allFeatureObject == 0) then
    return true
  end
  broadcastToAll((Player[DenoteSth()].steam_name or DenoteSth()) .. " не закончил(а) распределение характеристик")
  return false
end

function UpdateExperience()
  local expLeft = exp
  local levelUP = false

  if(nextLevelExperience[level] <= expLeft) then
    expLeft = expLeft - nextLevelExperience[level]
    level = level + 1 levelUP = true
    ElevateLevel()
    self.UI.setAttribute("inputExperience", "text", expLeft)
    expLeft, exp = 0, 0
  else
    self.UI.setAttribute("inputExperience", "text", "")
  end

  if(SetLevelUIAndCheckMaxLevel(expLeft, nextLevelExperience[level]) == false) then
    UpdateSave(levelUP)
  end
end

function SetLevelUIAndCheckMaxLevel(expLeft, nextLevelExp)
  local isLevelMax = false
  local per = expLeft / nextLevelExp * 100
  local strPer = expLeft
  if(level <= maxLevel) then
    strPer = expLeft .. "/" .. nextLevelExp
    if(level == maxLevel) then
      per = 100
      strPer = "End level"
      isLevelMax = true
    end
  else
    per = 100
    strPer = "End level"
    isLevelMax = true
  end
  self.UI.setAttribute("bar", "percentage", per)
  self.UI.setValue("textBar", strPer)
  self.UI.setValue("level", "{ru}Ваш уровень: {en}Your level: " .. level)
  return isLevelMax
end

function ElevateLevel()
  MinusLevelPass()
  SetUpListCharacteristicPerLevel()
  SetMinCharacteristic()
  local message = ""
  if(level < maxLevel) then
    message = "[b]" .. self.getName() .. "[/b] поднял(а) уровень!\nТеперь он(а) имеет " .. level .. " лвл"
  elseif(level == maxLevel) then
    message = "Поздравляем!\n[b]"..self.getName().."[/b] достиг максимального уровня!"
  end
  broadcastToAll(message)
end

function MinusLevelPass()
  for index,_ in pairs(localLevelPass) do
    localLevelPass[index] = localLevelPass[index] - 1
  end
end

function SetUpListCharacteristicPerLevel()
  if(CheckLevelPass(localLevelPass[allIndex["LPU"]])) then
    listCharacteristicPerLevel[allIndex["PLU"]][level] = characteristicPerLevel[allIndex["PLU"]]
  end
  if(CheckLevelPass(localLevelPass[allIndex["LPC"]])) then
    listCharacteristicPerLevel[allIndex["PLC"]][level] = characteristicPerLevel[allIndex["PLC"]]
  end
  if(CheckLevelPass(localLevelPass[allIndex["LPP"]])) then
    listCharacteristicPerLevel[allIndex["PLP"]][level] = characteristicPerLevel[allIndex["PLP"]]
  end
end

function ResetLevel(player)
	if(player.color == "Black") then
    RetraceValues()
    -- Оставь так, ибо обычным CreateNewVariable обработка идет некорректно
    listCharacteristicPerLevel[allIndex["PLU"]] = {}
    listCharacteristicPerLevel[allIndex["PLC"]] = {}
    listCharacteristicPerLevel[allIndex["PLP"]] = {}
    EnableFeatureChange("reset")
    ResetCharacteristic()
    ResetStatistic()
    UpdateExperience() UpdateSave()
    for _,value in pairs(allIndex) do
      if(CheckIndex(value, "start")) then
        self.UI.setAttribute(value, "interactable", true)
      end
    end
    Wait.time(|| SetTextCharacteristic(allIndex["SU"], allIndex["PLU"], allIndex["LPU"]), 0.3)
    Wait.time(|| SetTextCharacteristic(allIndex["SC"], allIndex["PLC"], allIndex["LPC"]), 0.3)
    Wait.time(|| SetTextCharacteristic(allIndex["SP"], allIndex["PLP"], allIndex["LPP"]), 0.3)
  else
    WriteMessagePlayerToColor("Вы не ГМ, вам нельзя обнулять уровни!")
  end
end

function RetraceValues()
  level = 1 exp = 0
  startCharacteristic = CreateNewVariable("S", 0)
  characteristicPerLevel = CreateNewVariable("PL", 0)
  levelPass = CreateNewVariable("LP", 1) localLevelPass = levelPass
end

function EnableFeatureChange(type, levelUP)
  levelUP = (exp == 0 and level == 1) or levelUP
  local list = GetFeatureListCheckType(type)
  if((list == nil or levelUP == false) and type ~= "reset") then return end

  self.UI.setAttribute("closeDistributionCharacteristic", "interactable", true)
  self.UI.setAttribute("closeDistributionCharacteristic", "color", "Green")
  for _,feature in pairs(list) do
	  feature.UI.setAttribute("buttonMinus", "visibility", "")
    feature.UI.setAttribute("buttonPlus", "visibility", "")
  end
end

function GetFeatureListCheckType(type)
  local list = {}
	if(type == "reset") then
    return allFeatureObject
  elseif(type ~= nil) then
    for id,feature in pairs(allFeatureObject) do
      if(string.match(feature.getGMNotes(), type)) then
        list[id] = feature
      end
    end
  end
  return list
end

function ResetCharacteristic()
	for _,feature in pairs(allFeatureObject) do
    if(feature == nil) then
      broadcastToAll("Есть удаленная характеристика. Переподключите их и сбросте уровень")
    else
	    feature.call("ResetCharacteristic")
    end
  end
end

function ResetStatistic()
	for _,stat in pairs(allStatisticGUID) do
    local statObj = getObjectFromGUID(stat)
    if(statObj == nil) then
      broadcastToAll("Есть удаленная статистика. Переподключите их и сбросте уровень")
    else
	    statObj.call("ResetStatistic")
    end
  end
end

function CloseDistributionCharacteristic(player)
  local freeValue = tonumber(self.UI.getValue("freeCharacteristicUsual", "value"))
  freeValue = freeValue + tonumber(self.UI.getValue("freeCharacteristicCombat", "value"))
  freeValue = freeValue + tonumber(self.UI.getValue("freeCharacteristicPeace", "value"))
	if(CheckPlayer(player.color) and CheckFreeValue(freeValue)) then
    broadcastToAll((Player[DenoteSth()].steam_name or DenoteSth()) .. " завершил(а) распределение ОХ", DenoteSth())
    SetMinCharacteristic()
    DisableFeatureChange()
  end
end

function CheckFreeValue(freeValue)
	if(freeValue == 0) then
    return true
  end
  WriteMessagePlayerToColor("У вас остались нераспределенные характеристики: " .. freeValue)
  return false
end

function SetMinCharacteristic()
	for _,feature in pairs(allFeatureObject) do
	  feature.call("NewLevel")
  end
end

function DisableFeatureChange()
  self.UI.setAttribute("closeDistributionCharacteristic", "interactable", false)
  self.UI.setAttribute("closeDistributionCharacteristic", "color", "Red")
	for _,feature in pairs(allFeatureObject) do
	  feature.UI.setAttribute("buttonMinus", "visibility", "Black")
    feature.UI.setAttribute("buttonPlus", "visibility", "Black")
  end
end

function WriteMessagePlayerToColor(message)
  if(Player[DenoteSth()].steam_name ~= nil) then
    printToColor(message, DenoteSth())
  end
end

function Connect()
  allFeatureGUID, allStatisticGUID = {}, {}
  local gameCharacter, gameInventoryGUID, gameTalentsGUID
  for _,object in pairs(getAllObjects()) do
    if(object) then
      if(object.getColorTint() == self.getColorTint()) then
        local GMNotesObj = object.getGMNotes()
        if(string.match(GMNotesObj, "Характеристика")) then
	        table.insert(allFeatureGUID, object.getGUID())
          broadcastToAll(object.getName() .. " добавлена к уровню")
        elseif(string.match(GMNotesObj, "Статистика")) then
	        table.insert(allStatisticGUID, object.getGUID())
          broadcastToAll(object.getName() .. " добавлена к существующему персонажу")
        elseif(string.match(GMNotesObj, "Игровой персонаж")) then
	        gameCharacter = object
          broadcastToAll("Игровой персонаж существует")
        elseif(GMNotesObj:match("GameEquipment")) then
	        gameInventoryGUID = object.getGUID()
          broadcastToAll("Игровой инвентарь существует")
        elseif(GMNotesObj:match("GameTalents")) then
	        gameTalentsGUID = object.getGUID()
        end
      end
    end
  end
  if(#allFeatureGUID == 0) then broadcastToAll("Характеристики не были найдены/добавлены на стол") end
  if(#allStatisticGUID == 0) then broadcastToAll("Статистика не была найдена/добавлена на стол") end
  SetObjectFeature()
  UpdateSave()
  if(gameCharacter and (allStatisticGUID or allFeatureGUID)) then
    SetGUIDInGameCharacter(gameCharacter, gameInventoryGUID, gameTalentsGUID)
  end
end
function SetObjectFeature()
  for id,guid in pairs(allFeatureGUID) do
    local obj = getObjectFromGUID(guid)
    if(obj ~= nil) then
      obj.call("SetGUIDLevel", self.getGUID())
      allFeatureObject[id] = obj
    end
  end
end

function SetGUIDInGameCharacter(gameCharacter, gameInventoryGUID, gameTalentsGUID)
  local params = {statisticsGUID = allStatisticGUID, characteristicsGUID = allFeatureGUID,
                  gameInventoryGUID = gameInventoryGUID, gameTalentsGUID = gameTalentsGUID}
	gameCharacter.call("SetGUID", params)
  SetObjectsStatistics(gameCharacter)
  SetObjectsCharacteristics(gameCharacter)
  SetObjectsInventory(gameCharacter, gameInventoryGUID)
  SetObjectsTalents(gameCharacter, gameTalentsGUID)
end
function SetObjectsStatistics(gameCharacter)
  local parametrs = {
    gameChar = gameCharacter,
    id = 1
  }
  for index,stat in pairs(allStatisticGUID) do
    parametrs.id = index
    --Задать Игровому персонажу
	  getObjectFromGUID(stat).call("SetGameCharacter", parametrs)
  end
end
function SetObjectsCharacteristics(gameCharacter)
  local parametrs = {
    gameChar = gameCharacter,
    id = 1
  }
  for index,charac in pairs(allFeatureGUID) do
    parametrs.id = index
    local charObj = getObjectFromGUID(charac)
	  charObj.call("SetGameCharacter", parametrs)
    Wait.time(|| RecheckConnectedDataInLevel(charObj), 1.6)
  end
end
function RecheckConnectedDataInLevel(charObj)
  local allStrips = {}
  for _,guidF in ipairs(allFeatureGUID) do
    table.insert(allStrips, guidF)
  end
  for _,guidS in ipairs(allStatisticGUID) do
    table.insert(allStrips, guidS)
  end
  charObj.call("RecheckConnectedData", {allStripsGUID = allStrips})
end
function SetObjectsInventory(gameCharacter, gameInventoryGUID)
  if(gameInventoryGUID) then
	  getObjectFromGUID(gameInventoryGUID).call("SetGameCharacter", {charGUID = gameCharacter.getGUID(), allFeatGUID = allFeatureGUID})
  end
end
function SetObjectsTalents(gameCharacter, gameTalentsGUID)
  if(gameTalentsGUID) then
	  getObjectFromGUID(gameTalentsGUID).call("SetGameCharacter", {charGUID = gameCharacter.getGUID(), allFeatGUID = allFeatureGUID})
  end
end

function CheckPlayer(playerColor)
	if(DenoteSth() == playerColor or playerColor == "Black") then
    return true
  end
  broadcastToAll("Эта дощечка не вашего цвета!")
  return false
end

function ChangeStatisticBonus(player, input)
  if(input == "") then return end
  input = tonumber(input)
  LBN = (input >= 0 and input) or 0

  if(#allFeatureObject > 0) then
    for _,feature in pairs(allFeatureObject) do
      feature.call("RecalculationLevelFromStatisticBonusPoint", LBN)
    end
  end
  if(#allStatisticGUID > 0) then
    for _,stat in pairs(allStatisticGUID) do
      getObjectFromGUID(stat).call("ChangeMaximumStatisticValue", LBN)
    end
  end

  UpdateSave()
end

function ChangeCharacteristiBonus(player, input, id)
  if(input == "") then return end
  input = tonumber(input)
  sumAllInitialCharacteristics = {}
  sumAllInitialCharacteristics["startCharacteristicUsual"] = 0
  sumAllInitialCharacteristics["startCharacteristicCombat"] = 0
  sumAllInitialCharacteristics["startCharacteristicPeace"] = 0

  for _,charac in pairs(allFeatureObject) do
    if(charac.call("CheckGMNot", id)) then
      if(id == "обычная") then
        sumAllInitialCharacteristics["startCharacteristicUsual"] = 
                          sumAllInitialCharacteristics["startCharacteristicUsual"] + input
      elseif(id == "боевая") then
        sumAllInitialCharacteristics["startCharacteristicCombat"] = 
                          sumAllInitialCharacteristics["startCharacteristicCombat"] + input
      elseif(id == "мирная") then
        sumAllInitialCharacteristics["startCharacteristicPeace"] =
                          sumAllInitialCharacteristics["startCharacteristicPeace"] + input
      end
      charac.call("ChangeMinCharacteristic", input)
    end
  end
end

function ChangeMaxLevel(player, input)
  input = (input ~= "" and tonumber(input) > 1 and input) or 20
	maxLevel = tonumber(input)
  UpdateSave()
end

function DenoteSth()
	local color = "Black"
  for iColor,_ in pairs(colorPlayer) do
    if(CheckColor(iColor)) then
	    color = iColor
      break
    end
  end
  return color
end
function CheckColor(color)
  local colorObject = {
    ["R"] = Round(self.getColorTint()[1], 2),
    ["G"] = Round(self.getColorTint()[2], 2),
    ["B"] = Round(self.getColorTint()[3], 2)
  }
	if(colorObject.R == colorPlayer[color].r and
     colorObject.G == colorPlayer[color].g and
     colorObject.B == colorPlayer[color].b) then
    return true
  else
    return false
  end
end
function Round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function ShowOrHideUIConnectedStrips(_, _, _, _, isLoad)
  if(not isLoad) then showUIPanel = not showUIPanel end
  if #allFeatureGUID ~= 0 and #allStatisticGUID then
    HideOrShowUI(showUIPanel)
  else
    Wait.time(|| HideOrShowUI(showUIPanel), 3)
  end
  UpdateSave()
end
function HideOrShowUI(showUIPanel)
  for i,v in ipairs(allStatisticGUID) do
    if(getObjectFromGUID(v)) then
      getObjectFromGUID(v).call("ShowOrHideMainPanel", showUIPanel)
    end
  end
  for i,v in ipairs(allFeatureGUID) do
    if(getObjectFromGUID(v)) then
      getObjectFromGUID(v).call("ShowOrHideMainPanel", showUIPanel)
    end
  end
end

function RebuildAssets()
  local root = 'https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/'
  local assets = {
    {name = 'uiGear', url = root .. 'gear.png'},
    {name = 'uiMinus', url = root .. 'minus.png'}
  }
  self.UI.setCustomAssets(assets)
end