function UpdateSave()
  self.setName((Player[DenoteSth()].steam_name or DenoteSth()) .. ": " .. (characteristicName or ""))
  local dataToSave = { ["characteristic"] = characteristic, ["characteristicBonus"] = characteristicBonus,
    ["minCharacteristic"] = minCharacteristic, ["GUIDLevelIndex"] = GUIDLevelIndex,
    ["levelNumber"] = levelNumber, ["inputGUID"] = inputGUID, ["inputCPM"] = inputCPM, ["inputLM"] = inputLM,
    ["levelBonusN"] = levelBonusN, ["countField"] = countField, ["dataHeight"] = dataHeight,
    ["ConnectedCharacteristic"] = ConnectedCharacteristic, ["gameCharacterGUID"] = gameCharacterGUID,
    ["idForGameCharacter"] = idForGameCharacter, ["pureCharacteristicBonus"] = pureCharacteristicBonus,
    ["inputObjectName"] = inputObjectName, ["gameInventoryGUID"] = gameInventoryGUID, ["characteristicName"] = characteristicName,
    ["showCharacteristic"] = showCharacteristic
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
    ["Teal"] = {r = 0.13, g = 0.69, b = 0.61},
    ["Black"] = {r = 0.25, g = 0.25, b = 0.25}
  }
  GUIDLevelIndex, characteristicName = "", ""
  minCharacteristic, characteristic = 0, 0
  characteristicBonus, pureCharacteristicBonus = 0, 0
  levelBonusN, levelNumber = 0, 1
  Wait.time(PerformParameterCheck, 0.5)
end

function PerformParameterCheck()
  if(not CheckGMNot("Характеристика")) then
    self.setGMNotes("Характеристика " .. usual)
  elseif(not CheckGMNot(usual)) then
    local locType, locTypeText = 0, self.getGMNotes():sub(16)
    if(CheckGMNot(combat)) then locType = 1
    elseif(CheckGMNot(peace)) then locType = 2
    else locType = 3 end
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
  gameCharacterGUID = loadedData.gameCharacterGUID or nil
  idForGameCharacter = loadedData.idForGameCharacter or 0
  characteristicName = loadedData.characteristicName or ""
  levelNumber = loadedData.levelNumber or 1
  levelBonusN = loadedData.levelBonusN or 0
  inputGUID, inputCPM, inputLM = loadedData.inputGUID or {}, loadedData.inputCPM or {}, loadedData.inputLM or {}
  -- Запомнил имя плашки (Сила/Здоровье/т.д.) чтобы при копипасте не повторять формулы
  inputObjectName = loadedData.inputObjectName or {}
  originalXml = self.UI.getXml()
  gameInventoryGUID = loadedData.gameInventoryGUID or nil
  showCharacteristic = loadedData.showCharacteristic or "True"
end

function FunctionCall()
  Wait.time(RebuildAssets, 0.05)
  Wait.time(AddNewFieldForConnection, 1)
  Wait.time(SetUIValue, 1.5)
  Wait.time(ChangeColorText, 1.55)
end

function onLoad(savedData)
  Wait.time(function()
    CreateGlobalVariables()
    if(savedData ~= "") then
      local loadedData = JSON.decode(savedData)
      Wait.time(|| Confer(loadedData), 0.6)
    end
    Wait.time(FunctionCall, 0.65)
  end, 1.5)
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
  Wait.time(|| EnlargeHeightPanel(countField), 0.1)
end
function EnlargeHeightPanel(count)
  --220 название и выбор + текст
  --preferredHeight=90 cellSpacing=10
  dataHeight = 220 + count * 90 + count * 10
  Wait.time(|| self.UI.setAttribute("panelTable", "height", dataHeight), 0.2)
  Wait.time(SetUIValue, 0.4)
end

function ChangeName(player, input)
	characteristicName = input or ""
  SetUIValue()
end
function SetUIValue()
  self.UI.setAttribute("inputName", "text", characteristicName)
  self.UI.setAttribute("name", "text", characteristicName)
	self.UI.setValue("textCharacteristic", characteristic)
  self.UI.setValue("textCharacteristicBonus", characteristicBonus)
  self.UI.setAttribute("toggleCharacteristic", "isOn", showCharacteristic)
  for i = 1, #inputGUID do
    self.UI.setAttribute("GUID_"..i.."", "text", inputGUID[i])
    self.UI.setAttribute("CPM_"..i.."", "text", inputCPM[inputGUID[i]])
    self.UI.setAttribute("LM_"..i.."", "text", inputLM[i])
  end
  Wait.time(UpdateSave, 0.1)
end

function SetGUIDLevel(guid)
  GUIDLevelIndex = guid
  UpdateSave()
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
	if(gameCharacterGUID) then
    getObjectFromGUID(gameCharacterGUID).call("ChangeCharacteristic", idForGameCharacter)
  end
end

function ChangeColorText()
  local id = "textCharacteristicBonus"
  if(pureCharacteristicBonus > 0) then
    self.UI.setAttribute(id, "color", "Green")
  elseif(pureCharacteristicBonus < 0) then
    self.UI.setAttribute(id, "color", "Red")
  else
    self.UI.setAttribute(id, "color", "White")
  end
end

function Plus(player, id)
  ChangeCharacteristic(player.color, id, 1, "button")
end
function Minus(player, id)
  ChangeCharacteristic(player.color, id, -1, "button")
end
function ChangeCharacteristic(playerColor, id, value, changeOurselves)
  local givenValue = 0
  givenValue = tonumber(self.UI.getValue(id)) + value
  if(CheckPlayer(playerColor)) then
	  if(ExceptionIdCharacteristic(id) and CheckCharacteristic(givenValue, value)) then
      self.UI.setValue(id, givenValue)
      characteristic = givenValue
    elseif(ExceptionIdBonus(id)) then
      if(changeOurselves == "button") then
        pureCharacteristicBonus = pureCharacteristicBonus + value
        characteristicBonus = givenValue
      else
        characteristicBonus = value
      end
      self.UI.setValue(id, characteristicBonus)
      Wait.time(|| ChangeColorText(), 0.1)
    end
    Wait.time(|| EnableCharacteristic("NotChangeHeight"), 0.1)
    Wait.time(ChangeCharacteristicInGameCharacter, 0.1)
  end
end
function CheckCharacteristic(givenValue, value)
  local objectLevel = getObjectFromGUID(GUIDLevelIndex)
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

function ShowOrHideMainPanel(show)
  if(show) then
    self.UI.show("basicCharacteristic")
  else
    self.UI.hide("basicCharacteristic")
  end
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

function DoNotShowCharacteristic(player, value)
  showCharacteristic = value
  if(value == "True") then
    print("Характеристика будет видна")
  else
    print("Характеристика не будет видна")
  end
  
  if(gameCharacterGUID) then
    getObjectFromGUID(gameCharacterGUID).call("ChangeShowCharacteristic", {guid = self.getGUID(), value = value})
  end

  local locIdentifier = "RecreatePanel_ForCharacter" .. DenoteSth()
  Timer.destroy(locIdentifier)
  Timer.create({
    identifier     = locIdentifier,
    function_name  = "RecreatePanel",
    delay          = 2,
    repetitions    = 1
  })
  Wait.time(UpdateSave, 0.1)
end
function RecreatePanel()
  if(gameCharacterGUID) then
    -- Пересоздать панель
    getObjectFromGUID(gameCharacterGUID).call("CreateFields")
  end
end

function DropdownChange(player, option)
  self.setGMNotes("Характеристика " .. option)
  self.UI.setAttribute("selectionType", "text", option)
  self.UI.setAttribute("panelTable", "height", dataHeight)
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
  ConnectedCharacteristic = {}
  inputObjectName = {}
  countField = 1
  self.UI.setValue("textCharacteristic", 0)
  self.UI.setValue("textCharacteristicBonus", 0)
  ShowUI("textCharacteristic") ShowUI("textCharacteristicBonus")
  EnableCharacteristic("Reset")
  Wait.time(AddNewFieldForConnection, 0.5)
end

function EnableCharacteristic(check)
  for i,guid in pairs(inputGUID) do
    local inputObj = getObjectFromGUID(guid)
    if(inputObj ~= nil and inputObj.getColorTint() == self.getColorTint()) then
      params = { CPM = RecalculationEquals(guid) or 0, LM = inputLM[i] or 0,
                 LN = levelNumber or 0,
                 LBN = levelBonusN or 0, GUID = self.getGUID() }
	    inputObj.call("RecalculationBonusPoints", params)
    elseif(inputObj.getColorTint() ~= self.getColorTint()) then
      broadcastToAll("Вы произвели замену цвета. Произведите переподключение", "Red")
    elseif(inputObj and check ~= "Reset") then
      broadcastToAll("Плашки с таким "..guid.." GUID нету", "Red")
      guid = nil
    end
  end
  
  if(not check or check ~= "NotChangeHeight") then
    if(check ~= "Reset" and #inputGUID >= countField) then
      countField = countField + 1
    end
    AddNewFieldForConnection()
  end
  UpdateSave()
end
function RecalculationBonusPoints(params)
  ConnectedCharacteristic[tostring(params.GUID)] = params

  local locCharBonus = 0
  for _,p in pairs(ConnectedCharacteristic) do
    if(p ~= nil) then
      local locVC = p.CPM
      local locLN = p.LM*p.LN
      locCharBonus = locCharBonus + locVC + locLN
    end
  end
  ChangeCharacteristic("Black", "textCharacteristicBonus", locCharBonus)
end

function NewLevel()
  minCharacteristic = characteristic
  levelNumber = levelNumber + 1
  UpdateSave()
end

function ChangeMinCharacteristic(value)
  minCharacteristic = value
  characteristic = value
  SetUIValue()
end

function EditInput(player, input, id)
  local index = id:find("_")
  local number = tonumber(id:sub(index + 1))
	if(id:match("GUID")) then
    if(input ~= "") then
      inputGUID[number] = input
      local nameObj = getObjectFromGUID(input).getName()
      print("Была добавлена " .. nameObj)
      inputObjectName[number] = nameObj
    end
  elseif(id:match("CPM")) then
    if(inputGUID[number]) then
      RecalculationEquals(inputGUID[number], input)
    end
  elseif(id:match("LM")) then
    inputLM[number] = tonumber(input) or 0
  end
end
function RecalculationEquals(guid, input, dontUse)
  if(input and guid) then
    inputCPM[guid] = input
  elseif(guid) then
    input = inputCPM[guid]
  end
  if(input) then
    local equals = (not dontUse and characteristic) + characteristicBonus
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
  return 0
end

function RecalculationValueInInventory(param)
  ChangeCharacteristic("Black", "textCharacteristicBonus", RecalculationEquals(nil, param.input), true)
end

function RecalculationLevelFromStatisticBonusPoint(LBN)
	levelBonusN = LBN
  UpdateSave()
end
--Игровой персонаж
function SetGameCharacter(parametrs)
  gameCharacterGUID = parametrs.gameChar.getGUID()
  idForGameCharacter = parametrs.id
  UpdateSave()
end

function RecheckConnectedData(param)
  for _,objGUID in pairs(param.allStripsGUID) do
    local obj = getObjectFromGUID(objGUID)
    for i,saveName in ipairs(inputObjectName) do
      if(obj.getName():sub(obj.getName():find(":") + 1) == saveName:sub(saveName:find(":") + 1)
         and obj.getColorTint() == self.getColorTint()) then
        inputLM[i] = inputLM[i]
        inputCPM[objGUID] = inputCPM[inputGUID[i]]
        inputGUID[i] = objGUID
        local param = {
          currentGUID = self.getGUID(),
          LM = inputLM[i] or 0, LN = levelNumber or 0,
          CPM = RecalculationEquals(objGUID) or 0, LBN = levelBonusN or 0
        }
        Wait.time(function() obj.call("ResetConnectedCharacteristic", param) end, 0.3)
      end
    end
  end
  Wait.time(SetUIValue, 0.5)
end

function ResetConnectedCharacteristic(param)
  ConnectedCharacteristic[tostring(param.currentGUID)] = {LM = param.LM, LN = param.LN, CPM = param.CPM}
  local countGUID = 0
  for guid,_ in pairs(ConnectedCharacteristic) do
    countGUID = countGUID + 1
    local objConnect = getObjectFromGUID(guid)
    if(not objConnect or objConnect.getColorTint() ~= self.getColorTint()) then
      ConnectedCharacteristic[guid] = nil
    end
  end
  Wait.time(|| UpdateSave, 0.1)
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