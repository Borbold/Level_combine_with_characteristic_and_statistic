function UpdateSave()
  self.setName((Player[DenoteSth()].steam_name or DenoteSth()) .. ": " .. (characteristicName or ""))
  local dataToSave = { ["characteristic"] = characteristic, ["characteristicBonus"] = characteristicBonus,
    ["minCharacteristic"] = minCharacteristic, ["GUIDLevelIndex"] = self.UI.getValue("GUIDLevel"),
    ["levelNumber"] = levelNumber, ["inputGUID"] = inputGUID, ["inputCPM"] = inputCPM, ["inputLM"] = inputLM,
    ["levelBonusN"] = levelBonusN, ["countField"] = countField, ["dataHeight"] = dataHeight,
    ["ConnectedCharacteristic"] = ConnectedCharacteristic, ["gameCharacterGUID"] = gameCharacterGUID,
    ["idForGameCharacter"] = idForGameCharacter, ["pureCharacteristicBonus"] = pureCharacteristicBonus
  }
  savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function CreateGlobalVariables()
  usual, combat, peace, empty = "обычная", "боевая", "мирная", "пустая"
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
  GUIDLevelIndex, characteristicName = "", ""
  minCharacteristic, characteristic = 0, 0
  characteristicBonus, pureCharacteristicBonus = 0, 0
  levelBonusN, levelNumber = 0, 1
  Wait.frames(PerformParameterCheck, 5)
end

function PerformParameterCheck()
  if(not CheckGMNot("Характеристика")) then
    self.setGMNotes("Характеристика " .. usual)
  elseif(not CheckGMNot(usual)) then
    local locType, locTypeText = 0, self.getGMNotes():sub(16)
    if(CheckGMNot(combat)) then locType = 1
    elseif(CheckGMNot(peace)) then locType = 2
    else locType = 3 end
    CheckOption(locType)
    self.UI.setAttribute("selectionType", "value", locType)
    self.UI.setAttribute("selectionType", "text", locTypeText)
  end
end

function Confer(loadedData)
  GUIDLevelIndex = loadedData.GUIDLevelIndex or ""
  minCharacteristic = loadedData.minCharacteristic or 0
  characteristic = loadedData.characteristic or 0
  characteristicBonus = loadedData.characteristicBonus or 0
  pureCharacteristicBonus = loadedData.pureCharacteristicBonus or 0
  countField = loadedData.countField or 1
  dataHeight = loadedData.dataHeight or 510
  ConnectedCharacteristic = loadedData.ConnectedCharacteristic or {}
  gameCharacter = getObjectFromGUID(loadedData.gameCharacterGUID) or nil
  idForGameCharacter = loadedData.idForGameCharacter or 0
  local indexString = string.find(self.getName(), ":")
  characteristicName = string.sub(self.getName(), indexString + 2, string.len(self.getName()))
  levelNumber = loadedData.levelNumber or 1
  levelBonusN = loadedData.levelBonusN or 0
  inputGUID, inputCPM, inputLM = loadedData.inputGUID or {}, loadedData.inputCPM or {}, loadedData.inputLM or {}
  originalXml = self.UI.getXml()
end

function FunctionCall()
	Wait.frames(RebuildAssets, 10)
  Wait.frames(AddNewFieldForConnection, 13)
  Wait.frames(|| ChangeColorText(0), 15)
end

function onLoad(savedData)
  CreateGlobalVariables()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    Wait.frames(|| Confer(loadedData), 8)
  end
  FunctionCall()
end

function AddNewFieldForConnection()
	local allXml = originalXml

  local searchString = "<NewRow />"
  local searchStringLength = #searchString

  local indexVisibility = allXml:find(searchString)
  
  local startXml = allXml:sub(1, indexVisibility + searchStringLength)
  local endXml = allXml:sub(indexVisibility + searchStringLength + 1)

  local newFields = ""
  for fieldIndex = 1, countField do
    newFields = newFields .. [[
      <Row preferredHeight='90'>
        <Cell>
          <InputField id='GUID_]]..fieldIndex..[[' class='fieldForConnectGUID' placeholder='GUID' />
        </Cell>
        <Cell>
          <InputField id='CPM_]]..fieldIndex..[[' class='fieldForConnect' placeholder='CPM' />
        </Cell>
        <Cell>
          <InputField id='LM_]]..fieldIndex..[[' class='fieldForConnect' placeholder='LM' />
        </Cell>
        <Cell>
          <Button class='buttonForConnect' />
        </Cell>
      </Row>
    ]]
  end

  startXml = startXml .. newFields .. endXml
  self.UI.setXml(startXml)
  EnlargeHeightPanel(countField)
end
function EnlargeHeightPanel(count)
  if(CheckGMNot(usual)) then
    --220 название и выбор + текст
    --preferredHeight=90 cellSpacing=10
    dataHeight = 220 + count * 90 + count * 10
    Wait.frames(|| self.UI.setAttribute("panelTable", "height", dataHeight), 5)
  else
    Wait.frames(|| self.UI.setAttribute("panelTable", "height", 160), 5)
  end
  Wait.frames(SetUIValue, 10)
end

function ChangeName(player, input)
	characteristicName = input or ""
  SetUIValue()
  UpdateSave()
end
function SetUIValue()
  self.UI.setAttribute("name", "text", characteristicName)
	self.UI.setValue("textCharacteristic", characteristic)
  self.UI.setValue("textCharacteristicBonus", characteristicBonus)
  self.UI.setValue("GUIDLevel", GUIDLevelIndex)
  for i = 1, #inputGUID do
    self.UI.setAttribute("GUID_"..i.."", "text", inputGUID[i])
    self.UI.setAttribute("CPM_"..i.."", "text", inputCPM[i])
    self.UI.setAttribute("LM_"..i.."", "text", inputLM[i])
  end
end

function PanelTool()
  if(self.UI.getAttribute("panelTool", "active") == "true") then
	  self.UI.hide("panelTool")
  else
    self.UI.show("panelTool")
  end
end

function ChangeText(id, text)
  self.UI.setAttribute(id, "text", text)
  self.UI.setAttribute(id, "color", "#ffffff00")
  self.UI.setAttribute(id, "textColor", "#ffffff")
end

function DeactivateUI(id)
	self.UI.setAttribute(id, "active", false)
end
function ActivateUI(id)
	self.UI.setAttribute(id, "active", true)
end

function ChangeCharacteristicInGameCharacter()
	if(gameCharacter ~= nil) then
    gameCharacter.call("ChangeCharacteristic", idForGameCharacter)
  end
end

function ChangeColorText(value)
  local id = "textCharacteristicBonus"
  pureCharacteristicBonus = pureCharacteristicBonus + value
  if(pureCharacteristicBonus > 0) then
    self.UI.setAttribute(id, "color", "Green")
  elseif(pureCharacteristicBonus < 0) then
    self.UI.setAttribute(id, "color", "Red")
  else
    self.UI.setAttribute(id, "color", "White")
  end
  UpdateSave()
end

function Plus(player, id)
  ChangeCharacteristic(player.color, id, 1, true)
end
function Minus(player, id)
  ChangeCharacteristic(player.color, id, -1, true)
end
function ChangeCharacteristic(playerColor, id, value, button)
  local givenValue = 0
  givenValue = tonumber(self.UI.getValue(id)) + value
  if(CheckPlayer(playerColor)) then
	  if(ExceptionIdCharacteristic(id) and CheckCharacteristic(givenValue, value)) then
      self.UI.setValue(id, givenValue)
      characteristic = givenValue
    elseif(ExceptionIdBonus(id)) then
      self.UI.setValue(id, givenValue)
      Wait.frames(|| ChangeColorText(value), 3)
      characteristicBonus = givenValue
    end
    EnableCharacteristic("NotChangeHeight", value, button)
    Wait.frames(ChangeCharacteristicInGameCharacter, 3)
  end
end
function CheckCharacteristic(givenValue, value)
  local objectLevel = getObjectFromGUID(self.UI.getValue("GUIDLevel"))
  if(ExceptionObject(objectLevel) == false) then
    print("Характеристике не задан Уровень")
    return false
  end
  
  local givenFreeValue = GetFreeValue(objectLevel) - value
  if(not CheckValue(givenValue, givenFreeValue)) then return false end

  SetFreeValue(objectLevel, givenFreeValue)
  WriteMessagePlayerToColor("У вас осталось: " .. givenFreeValue .. " свободных характеристик")
  return true
end
function GetFreeValue(objectLevel)
  if(CheckGMNot(usual)) then
    return tonumber(objectLevel.UI.getValue("freeCharacteristicUsual"))
  elseif(CheckGMNot(combat)) then
    return tonumber(objectLevel.UI.getValue("freeCharacteristicCombat"))
  elseif(CheckGMNot(peace)) then
    return tonumber(objectLevel.UI.getValue("freeCharacteristicPeace"))
  end
  return 0
end
function SetFreeValue(objectLevel, givenFreeValue)
  if(CheckGMNot(usual)) then
    objectLevel.UI.setValue("freeCharacteristicUsual", givenFreeValue)
  elseif(CheckGMNot(combat)) then
    objectLevel.UI.setValue("freeCharacteristicCombat", givenFreeValue)
  elseif(CheckGMNot(peace)) then
    objectLevel.UI.setValue("freeCharacteristicPeace", givenFreeValue)
  end
end
function CheckGMNot(type)
	if(string.match(self.getGMNotes(), type)) then
    return true
  end
  return false
end

function CheckValue(givenValue, givenFreeValue)
  ShowUI("buttonPlus") ShowUI("buttonMinus")
  if(givenFreeValue < 0) then
    HideUI("buttonPlus")
    return false
  end
  if(givenValue < minCharacteristic) then
    HideUI("buttonMinus")
    return false
  end
  return true
end
function ShowUI(id)
  self.UI.setAttribute(id, "visibility", "")
end
function HideUI(id)
	self.UI.setAttribute(id, "visibility", "Black")
end

function ExceptionIdCharacteristic(id)
	if(id == "textCharacteristic") then
    return true
  end
  return false
end
function ExceptionIdBonus(id)
	if(id == "textCharacteristicBonus") then
    return true
  end
  return false
end
function ExceptionObject(object)
  if(object == nil) then
    return false
  end
  return true
end

function WriteMessagePlayerToColor(message)
  if(Player[DenoteSth()].steam_name ~= nil) then
    printToColor(message, DenoteSth())
  end
end

function DropdownChange(player, option)
  self.setGMNotes("Характеристика " .. option)
  self.UI.setAttribute("selectionType", "text", option)
  CheckOption(option)
end
function CheckOption(option)
  if(option == usual) then
    self.UI.setAttribute("panelTable", "height", dataHeight)
  else
    self.UI.setAttribute("panelTable", "height", 160)
  end
end

function CheckPlayer(playerColor)
	if(CheckPlayerOrGM(playerColor)) then
    return true
  end
  broadcastToAll("Эта дощечка не вашего цвета!")
  return false
end
function CheckPlayerOrGM(playerColor)
	if(DenoteSth() == playerColor or playerColor == "Black") then
    return true
  end
  return false
end

function ResetCharacteristic()
  minCharacteristic, characteristic, characteristicBonus = 0, 0
  characteristicBonus, pureCharacteristicBonus = 0, 0
  levelNumber, inputCPM, inputLM = 1, 0, 0
  inputGUID, inputCPM, inputLM = {}, {}, {}
  countField = 1
  self.UI.setValue("textCharacteristic", 0)
  self.UI.setValue("textCharacteristicBonus", 0)
  ShowUI("textCharacteristic") ShowUI("textCharacteristicBonus")
  EnableCharacteristic("Reset")
  Wait.frames(AddNewFieldForConnection, 13)
end
function EnableCharacteristic(check, value, button)
  for i,_ in ipairs(inputGUID) do
    local inputObj = getObjectFromGUID(inputGUID[i])
    if(inputObj ~= nil) then
      params = { CPM = RecalculationEquals(i) or 0, LM = inputLM[i] or 0,
                 LN = levelNumber or 0,
                 LBN = levelBonusN or 0, GUID = self.getGUID() }
	    inputObj.call("RecalculationBonusPoints", params)
    else
      if(inputGUID[i] and check ~= "Reset") then
        broadcastToAll("Плашки с таким GUID нету", "Red")
      end
    end
  end
  
  if(CheckGMNot(usual) and (not check or check ~= "NotChangeHeight")) then
    if(check ~= "Reset" and #inputGUID >= countField) then
      countField = countField + 1
    end
    AddNewFieldForConnection()
  end
  UpdateSave()
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
  
  for _,p in pairs(ConnectedCharacteristic) do
    if(p ~= nil) then
      local locVC = p.CPM
      local locLN = p.LM*p.LN
      characteristicBonus = pureCharacteristicBonus + locVC + locLN
    end
  end
	self.UI.setValue("textCharacteristicBonus", Round(characteristicBonus))
  UpdateSave()
end

function NewLevel()
  minCharacteristic = characteristic
  levelNumber = levelNumber + 1
  UpdateSave()
end

function EditInput(player, input, id)
  local index = id:find("_")
  local number = tonumber(id:sub(index + 1))
	if(id:match("GUID")) then
    inputGUID[number] = input
  elseif(id:match("CPM")) then
    local equals = RecalculationEquals(number, input)
  elseif(id:match("LM")) then
    inputLM[number] = tonumber(input) or 0
  end
end
function RecalculationEquals(id, input)
  if(input) then
    inputCPM[id] = input
    local equals = (characteristic or 0) + (characteristicBonus or 0)
    local signFound = {["+"] = false, ["-"] = false, ["*"] = false, ["/"] = false}
    for S in input:gmatch("%S+") do
      for sign, found in pairs(signFound) do
        if(sign == "+" and found) then
          equals = equals + S
          signFound[sign] = false
          break
        elseif(sign == "-" and found) then
          equals = equals - S
          signFound[sign] = false
          break
        elseif(sign == "*" and found) then
          equals = equals * S
          signFound[sign] = false
          break
        elseif(sign == "/" and found) then
          equals = equals / S
          signFound[sign] = false
          break
        end
      end

      if(S == "+" or S == "-" or S == "*" or S == "/") then
        signFound[S] = true
      end
    end
    return equals
  else
    input = inputCPM[id]
    local equals = (characteristic or 0) + (characteristicBonus or 0)
    local signFound = {["+"] = false, ["-"] = false, ["*"] = false, ["/"] = false}
    for S in input:gmatch("%S+") do
      for sign, found in pairs(signFound) do
        if(sign == "+" and found) then
          equals = equals + S
          signFound[sign] = false
          break
        elseif(sign == "-" and found) then
          equals = equals - S
          signFound[sign] = false
          break
        elseif(sign == "*" and found) then
          equals = equals * S
          signFound[sign] = false
          break
        elseif(sign == "/" and found) then
          equals = equals / S
          signFound[sign] = false
          break
        end
      end

      if(S == "+" or S == "-" or S == "*" or S == "/") then
        signFound[S] = true
      end
    end
    return equals
  end
end

function RecalculationLevelFromStatisticBonusPoint(LBN)
	levelBonusN = LBN
  UpdateSave()
end
--Игровой персонаж
function SetGameCharacter(parametrs)
  gameCharacterGUID = parametrs.gameChar.getGUID()
	gameCharacter = parametrs.gameChar
  idForGameCharacter = parametrs.id
  UpdateSave()
end

function DenoteSth()
	local color = ""
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