﻿function UpdateSave()
  self.setName((Player[DenoteSth()].steam_name or DenoteSth()) .. ": " .. (statisticName or ""))
  local dataToSave = { ["currentStatisticValue"] = currentStatisticValue, ["maximumStatisticValue"] = maximumStatisticValue,
    ["pureMaxCurrentStatisticValue"] = pureMaxCurrentStatisticValue,
    ["progressBarColor"] = progressBarColor, ["gameCharacterGUID"] = gameCharacterGUID, ["idForGameCharacter"] = idForGameCharacter,
    ["ConnectedCharacteristic"] = ConnectedCharacteristic
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function CreateGlobalVariable()
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
  progressBarColor, statisticName = "", ""
  currentStatisticValue, maximumStatisticValue = 0, 0
  pureMaxCurrentStatisticValue = 0
  lockChange = false
  ConnectedCharacteristic = {}
  listIdUI = {"buttonPlus", "buttonMinus", "inputValue"}
end

function Confer(loadedData)
  ConnectedCharacteristic = loadedData.ConnectedCharacteristic or {}
  currentStatisticValue = loadedData.currentStatisticValue or 0
  pureMaxCurrentStatisticValue = loadedData.pureMaxCurrentStatisticValue or 0
  maximumStatisticValue = loadedData.maximumStatisticValue or 1
  gameCharacter = getObjectFromGUID(loadedData.gameCharacterGUID) or nil
  idForGameCharacter = loadedData.idForGameCharacter or 0
  progressBarColor = loadedData.progressBarColor or "#ffffff"
  local indexString = string.find(self.getName(), ":")
  statisticName = string.sub(self.getName(), indexString + 2, string.len(self.getName()))
end

function onLoad(savedData)
  self.setGMNotes("Статистика")
  CreateGlobalVariable()
  Wait.time(RebuildAssets, 0.2)
  if(savedData != "") then
    local loadedData = JSON.decode(savedData)
    Confer(loadedData)
  end
  Wait.time(UpdateValue, 0.3)
end

function HideUI()
	for i = 1, #listIdUI do
    self.UI.hide(listIdUI[i])
  end
end

function ShowUI()
  for i = 1, #listIdUI do
    self.UI.show(listIdUI[i])
  end
end

function ChangeMeaningLock(player)
  if(player.color == "Black") then
    if(lockChange == false) then
      lockChange = true
      ChangeTextButton("changeLock", "Разблокировать")
      HideUI()
    else
      lockChange = false
      ChangeTextButton("changeLock", "Заблокировать")
      ShowUI()
    end
  else
    broadcastToAll("[b]" .. player.steam_name .. "[/b]" .. " только ГМ-у дозволена данная функция", "Red")
  end
end

function ChangeTextButton(id, text)
  self.UI.setAttribute(id, "text", text)
  self.UI.setAttribute(id, "color", "#ffffff00")
  self.UI.setAttribute(id, "textColor", "#000000")
end

function PanelTool()
  if(self.UI.getAttribute("panelTool", "active") == "true") then
    self.UI.hide("panelTool")
  else
    self.UI.show("panelTool")
  end
end

function UpdateValue()
  local per = currentStatisticValue / maximumStatisticValue * 100
  local strPer = currentStatisticValue .. "/" .. maximumStatisticValue
	self.UI.setAttribute("bar", "percentage", per)
  self.UI.setValue("textBar", strPer)
  self.UI.setAttribute("name", "text", statisticName)
  self.UI.setAttribute("bar", "fillImageColor", progressBarColor)
  UpdateSave()
end

function ChangeStatisticInGameCharacter()
	if(gameCharacter ~= nil) then
    gameCharacter.call("ChangeStatistic", idForGameCharacter)
  end
end

function InputChange(player, input, idInput)
  if(idInput == "inputValue") then
	  ChangeStatistics(player.color, input)
  elseif(idInput == "inputMaxValue") then
    pureMaxCurrentStatisticValue = tonumber(input)
    ChangeMaximumStatisticValue(input)
  elseif(idInput == "inputName") then
    ChangeName(input)
  elseif(idInput == "inputColor") then
    ChangeProgressBarColor(input)
  end
end

function Minus(player)
  ChangeStatistics(player.color, -1)
end
function Plus(player)
  ChangeStatistics(player.color, 1)
end
function ChangeStatistics(playerColor, value)
  if(CheckPlayer(playerColor)) then
    if(lockChange == false) then
      if(value and value == "") then value = 0 end
      currentStatisticValue = currentStatisticValue + tonumber(value)
      if(currentStatisticValue < 0) then currentStatisticValue = 0 end
      if(tonumber(maximumStatisticValue) < tonumber(currentStatisticValue)) then currentStatisticValue = maximumStatisticValue end
      UpdateValue()
      Wait.time(ChangeStatisticInGameCharacter, 0.1)
    end
  end
end
function CheckPlayer(playerColor)
	if(DenoteSth() == playerColor or playerColor == "Black") then
    return true
  end
  broadcastToAll("Эта дощечка не вашего цвета!")
  return false
end
function DenoteSth()
  local color = "Black"
  for iColor,_ in pairs(colorPlayer) do
    if(CheckColor(iColor)) then
	    return iColor
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

function ResetStatistic()
  currentStatisticValue, maximumStatisticValue = 0, 1
  pureMaxCurrentStatisticValue = 0
  ConnectedCharacteristic = {}
end

function ResetConnectedCharacteristic()
  ConnectedCharacteristic = {}
end

function RecalculationBonusPoints(params)
  ConnectedCharacteristic[tostring(params.GUID)] = params
  
  local locCorrentVal = 0
  for _,p in pairs(ConnectedCharacteristic) do
    if(p ~= nil) then
      local locVC = p.CPM
      local locLN = p.LM*p.LN
	    locCorrentVal = locCorrentVal + pureMaxCurrentStatisticValue + p.LBN + locVC + locLN
    end
  end
  ChangeMaximumStatisticValue(math.ceil(locCorrentVal))
end
function ChangeMaximumStatisticValue(value)
  value = (tonumber(value) > 0 and value) or 1
  value = (value ~= "" and value) or maximumStatisticValue
  value = tonumber(value) currentStatisticValue = tonumber(currentStatisticValue)
  currentStatisticValue = (value < currentStatisticValue and value) or currentStatisticValue
  maximumStatisticValue = value
  UpdateValue()
end

function ChangeName(value)
  value = value or ""
  if(value == "") then value = statisticName end
  statisticName = value
  self.UI.setAttribute("name", "text", statisticName)
end

function ChangeProgressBarColor(value)
  value = value or ""
  if(value == "" or value:len() < 6) then value = progressBarColor end
  progressBarColor = value
  if(string.match(progressBarColor, "#") == nil) then progressBarColor = "#" .. progressBarColor end
  self.UI.setAttribute("bar", "fillImageColor", progressBarColor)
end
--Игровой персонаж
function SetGameCharacter(parametrs)
  gameCharacterGUID = parametrs.gameChar.getGUID()
	gameCharacter = parametrs.gameChar
  idForGameCharacter = parametrs.id
  UpdateSave()
end

function RebuildAssets()
  local root = 'https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/'
  local assets = {
    {name = 'uiGear', url = root .. 'gear.png'},
    {name = 'uiClose', url = root .. 'close.png'},
    {name = 'uiPlus', url = root .. 'plus.png'},
    {name = 'uiMinus', url = root .. 'minus.png'}
  }
  self.UI.setCustomAssets(assets)
end