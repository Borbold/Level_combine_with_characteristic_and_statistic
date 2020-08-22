function UpdateSave()
    self.setName((Player[DenoteSth()].steam_name or DenoteSth()) .. ": " .. (statisticName or ""))
    local dataToSave = { ["currentStatisticValue"] = currentStatisticValue, ["maximumStatisticValue"] = maximumStatisticValue,
        ["progressBarColor"] = progressBarColor, ["gameCharacterGUID"] = gameCharacterGUID, ["idForGameCharacter"] = idForGameCharacter,
        ["ConnectedCharacteristic"] = ConnectedCharacteristic
    }
    local savedData = JSON.encode(dataToSave)
    self.script_state = savedData
end

function onLoad(savedData)
    self.setGMNotes("����������")
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
        ["Teal"] = {r = 0.13, g = 0.69, b = 0.61}
    }
    progressBarColor = "" statisticName = ""
    currentStatisticValue, maximumStatisticValue = 0, 0
    lockChange = false
    listIdUI = {"buttonPlus", "buttonMinus", "inputValue"}
    Wait.Frames(RebuildAssets, 5)
    if(savedData != "") then
        local loadedData = JSON.decode(savedData)
        ConnectedCharacteristic = loadedData.ConnectedCharacteristic or {}
        currentStatisticValue = loadedData.currentStatisticValue or 0
        maximumStatisticValue = loadedData.maximumStatisticValue or 0
        gameCharacter = getObjectFromGUID(loadedData.gameCharacterGUID) or nil
        idForGameCharacter = loadedData.idForGameCharacter or 0
        progressBarColor = loadedData.progressBarColor or "#ffffff"
        local indexString = string.find(self.getName(), ":")
        statisticName = string.sub(self.getName(), indexString + 2, string.len(self.getName()))
    end
    Wait.Frames(UpdateValue, 8)
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
            ChangeTextButton("changeLock", "��������������")
            HideUI()
        else
            lockChange = false
            ChangeTextButton("changeLock", "�������������")
            ShowUI()
        end
    else
        broadcastToAll("[b]" .. player.steam_name .. "[/b]" .. " ������ ��-� ��������� ������ �������", "Red")
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

function Minus(player)
  ChangeStatistics(player.color, -1)
end
function Plus(player)
  ChangeStatistics(player.color, 1)
end

function InputChange(player, input, idInput)
    if(idInput == "inputValue") then
	    ChangeStatistics(player.color, input)
    elseif(idInput == "inputMaxValue") then
        ChangeMaximumStatisticValue(input)
    elseif(idInput == "inputName") then
        ChangeName(input)
    elseif(idInput == "inputColor") then
        ChangeProgressBarColor(input)
    end
end

function ChangeName(value)
    value = value or ""
    if(value == "") then value = statisticName end
    statisticName = value
    self.UI.setAttribute("name", "text", statisticName)
end

function ChangeProgressBarColor(value)
    value = value or ""
    if(value == "" or string.len(value) < 6) then value = progressBarColor end
    progressBarColor = value
    if(string.match(progressBarColor, "#") == nil) then progressBarColor = "#" .. progressBarColor end
    self.UI.setAttribute("bar", "fillImageColor", progressBarColor)
end

function ChangeMaximumStatisticValue(value)
  value = (value ~= "" and tonumber(value) > 0 and value) or maximumStatisticValue
  maximumStatisticValue = tonumber(value)
  currentStatisticValue = (maximumStatisticValue < tonumber(currentStatisticValue) and maximumStatisticValue) or currentStatisticValue
  UpdateValue()
end

function ChangeStatistics(playerColor, value)
  if(CheckPlayer(playerColor)) then
    if(lockChange == false) then
      if(value and value == "") then value = 0 end
      currentStatisticValue = currentStatisticValue + tonumber(value)
      if(currentStatisticValue < 0) then currentStatisticValue = 0 end
      if(tonumber(maximumStatisticValue) < tonumber(currentStatisticValue)) then currentStatisticValue = maximumStatisticValue end
      UpdateValue()
      Wait.Frames(ChangeStatisticInGameCharacter, 3)
    end
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

function CheckPlayer(playerColor)
	if(DenoteSth() == playerColor or playerColor == "Black") then
        return true
    end
    broadcastToAll("��� ������� �� ������ �����!")
    return false
end

function DenoteSth()
  for iColor,_ in pairs(colorPlayer) do
    if(CheckColor(iColor)) then
	    return iColor
    end
  end
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

function RecalculationBonusPoints(params)
  local isConnect = false
  for i = 1, #ConnectedCharacteristic do
    if(ConnectedCharacteristic[i].GUID == params.GUID) then
      isConnect = true
      if(getObjectFromGUID(params.GUID) == nil) then
        ConnectedCharacteristic[i] = nil
      end
    end
  end
  
  if(isConnect == false) then
    ConnectedCharacteristic[#ConnectedCharacteristic + 1] = params
  else
    for index,par in pairs(ConnectedCharacteristic) do
	    if(par.GUID == params.GUID) then
        ConnectedCharacteristic[index] = params
      end
    end
  end
  
  local locMaxChar = 0
  for _,p in pairs(ConnectedCharacteristic) do
    if(p ~= nil) then
	    locMaxChar = locMaxChar + p.LBN + (p.CPM*p.VC) + (p.LM*p.LN)
    end
  end
  
  ChangeMaximumStatisticValue(math.ceil(locMaxChar))
end
--������� ��������
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

function Round(num, idp)
    return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end