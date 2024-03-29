﻿function UpdateSave()
  local dataToSave = {
    ["allStatisticsGUID"] = allStatisticsGUID, ["allCharacteristicsGUID"] = allCharacteristicsGUID,
    ["gameInventoryGUID"] = gameInventoryGUID, ["showCharacteristic"] = showCharacteristic,
    ["saveHeightUI"] = saveHeightUI, ["gameTalentsGUID"] = gameTalentsGUID, ["statsAnotherWindow"] = statsAnotherWindow
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  Wait.time(function()
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
    Wait.time(|| Confer(savedData), 1)
  end, 2)
end

function Confer(savedData)
  originalXml = self.UI.getXml()
  allCharacteristics, allStatistics = {}, {}
  showCharacteristic, statsAnotherWindow = {}, {}
  RebuildAssets()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    allStatisticsGUID = loadedData.allStatisticsGUID or {}
    allCharacteristicsGUID = loadedData.allCharacteristicsGUID or {}
    gameInventoryGUID = loadedData.gameInventoryGUID
    gameTalentsGUID = loadedData.gameTalentsGUID
    showCharacteristic = loadedData.showCharacteristic or {}
    statsAnotherWindow = loadedData.statsAnotherWindow or {}
    saveHeightUI = loadedData.saveHeightUI
    Wait.time(SetStatisticObjects, 0.1)
    Wait.time(SetCharacteristicObjects, 0.3)
    Wait.time(CreateFields, 0.7)
    if(saveHeightUI) then
      Wait.time(function() self.UI.setAttribute("mainPanel", "position", "0 0 "..saveHeightUI) end, 0.75)
    end
  end
end

function SetGUID(params)
  SetStatistic(params.statisticsGUID)
  SetCharacteristic(params.characteristicsGUID)
  gameInventoryGUID = params.gameInventoryGUID
  gameTalentsGUID = params.gameTalentsGUID

  Wait.time(CreateFields, 0.6)
  Wait.time(UpdateSave, 0.7)
end
function SetStatistic(statisticsGUID)
  if(statisticsGUID) then
    allStatisticsGUID = {}
    for k,stat in pairs(statisticsGUID) do
	    allStatisticsGUID[k] = stat
    end
    SetObjects("Stat")
  end
end
function SetCharacteristic(characteristicsGUID)
  if(characteristicsGUID) then
    allCharacteristicsGUID = {}
    for k,char in pairs(characteristicsGUID) do
	    allCharacteristicsGUID[k] = char
    end
    SetObjects("Char")
  end
end
function SetObjects(what)
	if(what == "Stat") then
    SetStatisticObjects()
  elseif(what == "Char") then
    SetCharacteristicObjects()
  end
end
function SetStatisticObjects()
	for k,statisticGUID in ipairs(allStatisticsGUID) do
    local statObj = getObjectFromGUID(statisticGUID)
    if(statObj ~= nil) then
	    allStatistics[k] = statObj
      if(not statsAnotherWindow[k]) then
        statsAnotherWindow[k] = "False"
      end
    else
      broadcastToAll("Одна или несколько статистик были удалены. Произведите переподключение")
      return
    end
  end
end
function SetCharacteristicObjects()
	for k,characteristicGUID in ipairs(allCharacteristicsGUID) do
    local characObj = getObjectFromGUID(characteristicGUID)
    if(characObj ~= nil) then
	    allCharacteristics[k] = characObj
      if(not showCharacteristic[k]) then
        showCharacteristic[k] = "True"
      end
    else
      broadcastToAll("Одна или несколько характеристик были удалены. Произведите переподключение")
      return
    end
  end
end

function ChangeShowCharacteristic(params)
  for index,characteristicGUID in ipairs(allCharacteristicsGUID) do
    if(characteristicGUID == params.guid) then
      showCharacteristic[index] = params.value
    end
  end
end

function ChangeShowStatistic(params)
  for index,statisticGUID in ipairs(allStatisticsGUID) do
    if(statisticGUID == params.guid) then
      statsAnotherWindow[index] = params.value
    end
  end
end

function CreateFields()
  self.UI.setXml(originalXml)
  Wait.time(|| AddNewField(), 1.5)
  for i = 1, #allStatisticsGUID do
    Wait.time(|| ChangeStatistic(i), 2)
  end
end
function AddNewField()
  local allXml = originalXml

  local searchString = "visibility="
  local searchStringLength = #searchString

  local indexVisibility = allXml:find(searchString)

  local startXml = allXml:sub(1, indexVisibility + searchStringLength)
  local endXml = allXml:sub(indexVisibility + searchStringLength + 1)--+1 нужен для того чтобы убрать лишний "

  local colorCanSee = ""
  if(self.getGMNotes():match("color_can_see:")) then
    local isFlag = false
    for S in self.getGMNotes():gmatch("%S+") do
      if(isFlag) then
        colorCanSee = "|"..S
        break
      end
      if(S == "color_can_see:") then
        isFlag = true
      end
    end
  end

  local strVis = "Black|"..DenoteSth()..colorCanSee
  allXml = startXml .. strVis .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newCharacteristic, longestLine = "", 30
  local countCharac = 1
  if(#allCharacteristics > 0) then
    for index,char in ipairs(allCharacteristics) do
      if(showCharacteristic[index] == "True") then
        local textChar = CreateNameForCharacteristic(char)
        if(textChar) then
          if(#textChar > longestLine) then
            longestLine = #textChar
          end

          local locColor = "#ffffff"
          local typeChar = char.UI.getAttribute("selectionType", "text")
          if(typeChar ~= "обычная") then
            locColor = (typeChar == "боевая" and "#ff0000") or (typeChar == "мирная" and "#00ff00") or (typeChar == "пустая" and "#808080") or locColor
          end

          newCharacteristic = newCharacteristic .. [[
            <Row preferredHeight='50'>
              <Cell>
                <Text id='tChar]]..index..[[' class='forCharacteristic' color=']]..locColor..[[' text=']]..textChar..[['/>
              </Cell>
            </Row>
          ]]
          countCharac = countCharac + 1
        end
      end
    end
  end

  searchString = "<NewRowC />"
  searchStringLength = #searchString

  local indexEndFirstCharacteristic = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstCharacteristic + searchStringLength)
  endXml = allXml:sub(indexEndFirstCharacteristic + searchStringLength)

  allXml = startXml .. newCharacteristic .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newThings, longestLineInventory, countItem = "", 30, 1
  local inventoryObj = getObjectFromGUID(gameInventoryGUID)
  if(inventoryObj) then
    for index,itemGUID in pairs(inventoryObj.call("GetAllObjectGUID")) do
      local itemObj = getObjectFromGUID(itemGUID)
      if(itemObj) then
        if(itemObj.type ~= "Bag") then
          local textItem = itemObj.getName()
          countItem = countItem + 1
          if(#textItem > longestLineInventory) then
            longestLineInventory = #textItem
          end

          newThings = newThings .. [[
            <Row preferredHeight='50'>
              <Cell>
                <Text id='tItem]]..index..[[' class='forInventory' color='#ffffff' text=']]..textItem..[['/>
              </Cell>
            </Row>
          ]]
        else
          for i,itemBag in pairs(itemObj.getObjects()) do
            local textItem = itemBag.name
            countItem = countItem + 1
            if(#textItem > longestLineInventory) then
              longestLineInventory = #textItem
            end

            newThings = newThings .. [[
              <Row preferredHeight='50'>
                <Cell>
                  <Text id='tItem]]..(i + index)..[[' class='forInventory' color='#ffffff' text=']]..textItem..[['/>
                </Cell>
              </Row>
            ]]
          end
        end
      end
    end
  end
  
  searchString = "<NewRowI />"
  searchStringLength = #searchString

  local indexEndFirstThings = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstThings + searchStringLength)
  endXml = allXml:sub(indexEndFirstThings + searchStringLength)

  allXml = startXml .. newThings .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newTalent, longestLineTalent, countTalent = "", 30, 1
  local talentObj = getObjectFromGUID(gameTalentsGUID)
  if(talentObj) then
    for index,talentGUID in pairs(talentObj.call("GetAllObjectGUID")) do
      local itemObj = getObjectFromGUID(talentGUID)
      if(itemObj) then
        local textTalent = itemObj.getName()
        countTalent = countTalent + 1
        if(#textTalent > longestLineTalent) then
          longestLineTalent = #textTalent
        end

        newTalent = newTalent .. [[
          <Row preferredHeight='50'>
            <Cell>
              <Text id='tItem]]..index..[[' class='forInventory' color='#ffffff' text=']]..textTalent..[['/>
            </Cell>
          </Row>
        ]]
      end
    end
  end
  
  searchString = "<NewRowT />"
  searchStringLength = #searchString

  local indexEndFirstThings = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstThings + searchStringLength)
  endXml = allXml:sub(indexEndFirstThings + searchStringLength)

  allXml = startXml .. newTalent .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newStatistic, newDopStatistic = "", ""
  local countStat, countDopStat = 1, 1
  if(#allStatistics > 0) then
    for statisticIndex = 1, #allStatisticsGUID do
      if(statsAnotherWindow[statisticIndex] == "False") then
        newStatistic = newStatistic .. [[
          <Row preferredHeight='50'>
            <Cell>
              <Button image='uiMinus' onClick='Minus(]]..statisticIndex..[[)'/>
            </Cell>
            <Cell>
              <Panel>
                <ProgressBar id='bar]]..statisticIndex..[[' class='classBar'/>
                <Text id='textBar]]..statisticIndex..[[' class='textForBar'/>
              </Panel>
            </Cell>
            <Cell>
              <Button image='uiPlus' onClick='Plus(]]..statisticIndex..[[)'/>
            </Cell>
          </Row>
        ]]
        countStat = countStat + 1
      else
        newDopStatistic = newDopStatistic .. [[
          <Row preferredHeight='50'>
            <Cell>
              <Button image='uiMinus' onClick='Minus(]]..statisticIndex..[[)'/>
            </Cell>
            <Cell>
              <Panel>
                <ProgressBar id='bar]]..statisticIndex..[[' class='classBar'/>
                <Text id='textBar]]..statisticIndex..[[' class='textForBar'/>
              </Panel>
            </Cell>
            <Cell>
              <Button image='uiPlus' onClick='Plus(]]..statisticIndex..[[)'/>
            </Cell>
          </Row>
        ]]
        countDopStat = countDopStat + 1
      end
    end
  end

  if(newDopStatistic ~= "") then
    searchString = "<NewRowDS />"
    searchStringLength = #searchString

    local indexEndFirstThings = allXml:find(searchString)

    startXml = allXml:sub(1, indexEndFirstThings + searchStringLength)
    endXml = allXml:sub(indexEndFirstThings + searchStringLength)

    allXml = startXml .. newDopStatistic .. endXml
  end

  searchString = "<NewRowS />"
  searchStringLength = #searchString

  local indexEndFirstStatistic = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstStatistic + searchStringLength)
  endXml = allXml:sub(indexEndFirstStatistic + searchStringLength)

  startXml = startXml .. newStatistic .. endXml
  self.UI.setXml(startXml)

  if(saveHeightUI) then
    Wait.time(function() self.UI.setAttribute("mainPanel", "position", "0 0 "..saveHeightUI) end, 0.05)
  end

  EnlargeHeightPanel(countStat, "TLPanelStat")
  EnlargeHeightPanel(countDopStat, "TLPanelDopStat")

  EnlargeHeightPanel(countCharac, "TLPanelChar")
  EnlargeWidthPanel(longestLine, "characteristicPanel")
  
  EnlargeHeightPanel(countItem, "TLPanelInven")
  EnlargeWidthPanel(longestLineInventory, "inventoryPanel")

  EnlargeHeightPanel(countTalent, "TLPanelTalent")
  EnlargeWidthPanel(longestLineTalent, "talentPanel")
  Wait.time(UpdateSave, 0.1)
end

function CreateNameForCharacteristic(charac)
  local name = charac.UI.getAttribute("name", "text")
  local charact = charac.UI.getValue("textCharacteristic")
  local bonusChar = charac.UI.getValue("textCharacteristicBonus")
  if(name and charact and bonusChar) then
    return name .. ": ох=" .. charact .. ",обх=" .. bonusChar
  end
end

function EnlargeHeightPanel(countIndex, id)
  if(countIndex > 4) then
    --preferredHeight=50 cellSpacing=5
    local newHeightPanel = countIndex * 50 + countIndex * 5
    Wait.time(|| self.UI.setAttribute(id, "height", newHeightPanel), 0.2)
  end
end
function EnlargeWidthPanel(lengthText, id)
  lengthText = lengthText - 30
  if(not locWidth) then
    locWidth = self.UI.getAttribute(id, "width")
  end
  if(lengthText > 0) then locWidth = locWidth + lengthText*5 end
  Wait.time(|| self.UI.setAttribute(id, "width", locWidth), 0.2)
end

function ChangeCharacteristic(id)
  if(allCharacteristics[id]) then
    local name = allCharacteristics[id].UI.getAttribute("name", "text")
    local charact = allCharacteristics[id].UI.getValue("textCharacteristic")
    local bonusChar = allCharacteristics[id].UI.getValue("textCharacteristicBonus")
    local textChar = name .. ": ох=" .. charact .. ",обх=" .. bonusChar
    self.UI.setAttribute("tChar"..id, "text", textChar)
  end
end

function Minus(player, val)
  val = tonumber(val)
  if(allStatistics[val]) then
	  allStatistics[val].call("Minus", player)
    Wait.time(|| ChangeStatistic(val), 0.1)
  else
    broadcastToAll("Вы удалили эту статистику. Произведите переподключение")
  end
end
function Plus(player, val)
  val = tonumber(val)
  if(allStatistics[val]) then
	  allStatistics[val].call("Plus", player)
    Wait.time(|| ChangeStatistic(val), 0.1)
  else
    broadcastToAll("Вы удалили эту статистику. Произведите переподключение")
  end
end
function ChangeStatistic(id)
  id = tonumber(id)
  if(allStatistics[id]) then
    self.UI.setAttribute("bar"..id, "color", allStatistics[id].UI.getAttribute("bar", "color"))
    self.UI.setAttribute("bar"..id, "fillImageColor", allStatistics[id].UI.getAttribute("bar", "fillImageColor"))
    self.UI.setAttribute("bar"..id, "percentage", allStatistics[id].UI.getAttribute("bar", "percentage"))

    local name = allStatistics[id].UI.getAttribute("name", "text")
    local textBar = allStatistics[id].UI.getValue("textBar")
    self.UI.setAttribute("textBar"..id, "text", name .. ":" .. textBar)
  end
end

function ActiveDeactivePanel(player, idPanel)
  local locActive = self.UI.getAttribute(idPanel, "active") == "false"
	self.UI.setAttribute(idPanel, "active", tostring(locActive))
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
  local rootIn = 'https://img2.freepng.ru/20180418/hlw/kisspng-computer-icons-adventure-hotel-luggage-5ad725017cc0f8.903043971524049153511.jpg'
  local rootB = 'https://img2.freepng.ru/20180320/tze/kisspng-artist-s-book-scalable-vector-graphics-clip-art-gray-books-cliparts-5ab10db5d03c32.1930740015215528218529.jpg'
  local assets = {
    {name = 'uiGear', url = root .. 'gear.png'},
    {name = 'uiClose', url = root .. 'close.png'},
    {name = 'uiPlus', url = root .. 'plus.png'},
    {name = 'uiMinus', url = root .. 'minus.png'},
    {name = 'uiBars', url = root .. 'bars.png'},
    {name = 'uiInventory', url = rootIn},
    {name = 'uiBook', url = rootB}
  }
  self.UI.setCustomAssets(assets)
end

function ChageHeight(_, value)
  if(value == "") then return end
  value = tonumber(value)
  if(value < 0) then return end
  saveHeightUI = (-1)*value
  self.UI.setAttribute("mainPanel", "position", "0 0 "..saveHeightUI)
  UpdateSave()
end

function InteractWithCombatSystem(player, value, id)
  if(not combatSystem) then
    for _, object in pairs(getObjects()) do
      if(object.getGMNotes():find("Combat sistem")) then
        combatSystem = object
      end
    end
  end
  combatSystem.call("CreateCharacteristics", {allCharacteristics = allCharacteristics, type = id, name = self.getName()})
end