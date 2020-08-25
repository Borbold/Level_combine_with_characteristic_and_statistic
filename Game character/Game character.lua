function UpdateSave()
  local dataToSave = {
    ["allStatisticsGUID"] = allStatisticsGUID, ["allCharacteristicsGUID"] = allCharacteristicsGUID
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
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
  Wait.Frames(|| Confer(savedData), 10)
end

function Confer(savedData)
  originalXml = self.UI.getXml()
  allCharacteristics, allStatistics = {}, {}
  RebuildAssets()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    allStatisticsGUID = loadedData.allStatisticsGUID or {}
    allCharacteristicsGUID = loadedData.allCharacteristicsGUID or {}
    SetStatisticObjects()
    Wait.Frames(SetCharacteristicObjects, 13)
    Wait.Frames(CreateFields, 15)
  end
end

function SetGUID(params)
  SetStatistic(params.statisticsGUID)
  SetCharacteristic(params.characteristicsGUID)

  Wait.Frames(CreateFields, 3)
  UpdateSave()
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
    if(getObjectFromGUID(statisticGUID)) then
	    allStatistics[k] = getObjectFromGUID(statisticGUID)
    else
      broadcastToAll("���� ��� ��������� ��������� ���� �������. ����������� ���������������")
      return
    end
  end
end
function SetCharacteristicObjects()
	for k,characteristicGUID in ipairs(allCharacteristicsGUID) do
    if(getObjectFromGUID(characteristicGUID)) then
	    allCharacteristics[k] = getObjectFromGUID(characteristicGUID)
    else
      broadcastToAll("���� ��� ��������� ������������� ���� �������. ����������� ���������������")
      return
    end
  end
end

function CreateFields()
  self.UI.setXml(originalXml)
  AddNewField()
  for i = 1, #allStatisticsGUID do
    Wait.Frames(|| ChangeStatistic(i), 10)
  end
end

function AddNewField()
  local allXml = originalXml

  local searchString = "visibility="
  local searchStringLength = #searchString

  local indexVisibility = allXml:find(searchString)

  local startXml = allXml:sub(1, indexVisibility + searchStringLength)
  local endXml = allXml:sub(indexVisibility + searchStringLength + 1)--+1 ����� ��� ���� ����� ������ ������ "

  local strVis = "Black|"..DenoteSth()
  allXml = startXml .. strVis .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newCharacteristic, longestLine = "", 15
  if(#allCharacteristics > 0) then
    for index,char in pairs(allCharacteristics) do
      local textChar = CreateNameForCharacteristic(char)
      if(#textChar > longestLine) then
        longestLine = #textChar
      end

      local locColor = "#ffffff"
      local typeChar = char.UI.getAttribute("selectionType", "text")
      if(typeChar ~= "�������") then
        locColor = (typeChar == "������" and "#ff0000") or (typeChar == "������" and "#00ff00") or locColor
      end

      newCharacteristic = newCharacteristic ..
      "<Row preferredHeight='50'>\n" ..
      " <Cell>\n" ..
      "   <Text id='tChar"..index.."' class='forCharacteristic' color='"..locColor.."' text='"..textChar.."'/>\n" ..
      " </Cell>\n" ..
      "</Row>\n"
    end
  end

  searchString = "<NewRowC />"
  searchStringLength = #searchString

  local indexEndFirstCharacteristic = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstCharacteristic + searchStringLength)
  endXml = allXml:sub(indexEndFirstCharacteristic + searchStringLength)

  allXml = startXml .. newCharacteristic .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newStatistic = ""
  if(#allStatistics > 0) then
    for statisticIndex = 1, #allStatisticsGUID do
      newStatistic = newStatistic ..
      "<Row preferredHeight='50'>\n" ..
      " <Cell>\n" ..
      "   <Button image='uiMinus' onClick='Minus("..statisticIndex..")'/>\n" ..
      " </Cell>\n" ..
      " <Cell>\n" ..
	    "		<Panel>\n" ..
	    "			<ProgressBar id='bar"..statisticIndex.."' class='classBar'/>\n" ..
	    "			<Text id='textBar"..statisticIndex.."' class='textForBar'/>\n" ..
	    "		</Panel>\n" ..
      " </Cell>\n" ..
      " <Cell>\n" ..
      "   <Button image='uiPlus' onClick='Plus("..statisticIndex..")'/>\n" ..
      " </Cell>\n" ..
      "</Row>\n"
    end
  end

  searchString = "<NewRowS />"
  searchStringLength = #searchString

  local indexEndFirstStatistic = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstStatistic + searchStringLength)
  endXml = allXml:sub(indexEndFirstStatistic + searchStringLength)

  startXml = startXml .. newStatistic .. endXml
  self.UI.setXml(startXml)
  EnlargeHeightPanelStat(#allStatisticsGUID + 1)
  EnlargeHeightPanelChar(#allCharacteristicsGUID + 1)
  EnlargeWidthPanelChar(longestLine)
end

function CreateNameForCharacteristic(char)
  local name = char.UI.getAttribute("name", "text")
  local charact = char.UI.getValue("textCharacteristic")
  local bonusChar = char.UI.getValue("textCharacteristicBonus")
  return name .. ": ��=" .. charact .. ",���=" .. bonusChar
end

function EnlargeHeightPanelStat(countStatisticIndex)
  if(countStatisticIndex > 4) then
    --preferredHeight=50 cellSpacing=5
    local newHeightPanel = countStatisticIndex * 50 + countStatisticIndex * 5
    Wait.Frames(|| self.UI.setAttribute("TLPanelStat", "height", newHeightPanel), 5)
  end
end

function EnlargeHeightPanelChar(countCharacteristicIndex)
  if(countCharacteristicIndex > 4) then
    --preferredHeight=50 cellSpacing=5
    local newHeightPanel = countCharacteristicIndex * 50 + countCharacteristicIndex * 5
    Wait.Frames(|| self.UI.setAttribute("TLPanelChar", "height", newHeightPanel), 5)
  end
end
function EnlargeWidthPanelChar(lengthText)
  local locDifference = lengthText - 15
  local locWidth = self.UI.getAttribute("TLPanelChar", "width")
  for i = 1, locDifference do
    locWidth = locWidth + i + (i - 1)
  end
  Wait.Frames(|| self.UI.setAttribute("TLPanelChar", "width", locWidth), 5)
  Wait.Frames(|| self.UI.setAttribute("characteristicPanel", "width", locWidth), 5)
end

function ChangeCharacteristic(id)
  if(allStatistics[id]) then
    local name = allCharacteristics[id].UI.getAttribute("name", "text")
    local charact = allCharacteristics[id].UI.getValue("textCharacteristic")
    local bonusChar = allCharacteristics[id].UI.getValue("textCharacteristicBonus")
    local textChar = name .. ": ��=" .. charact .. ",���=" .. bonusChar
    self.UI.setAttribute("tChar"..id, "text", textChar)
  end
end

function ChangeStatistic(id)
  if(allStatistics[id]) then
    self.UI.setAttribute("bar"..id, "color", allStatistics[id].UI.getAttribute("bar", "color"))
    self.UI.setAttribute("bar"..id, "fillImageColor", allStatistics[id].UI.getAttribute("bar", "fillImageColor"))
    self.UI.setAttribute("bar"..id, "percentage", allStatistics[id].UI.getAttribute("bar", "percentage"))

    local name = allStatistics[id].UI.getAttribute("name", "text")
    local textBar = allStatistics[id].UI.getValue("textBar")
    self.UI.setAttribute("textBar"..id, "text", name .. ":" .. textBar)
  end
end

function Minus(player, val)
  val = tonumber(val)
  if(allStatistics[val]) then
	  allStatistics[val].call("Minus", player)
    Wait.Frames(|| ChangeStatistic(val), 2)
  else
    broadcastToAll("�� ������� ��� ����������. ����������� ���������������")
  end
end
function Plus(player, val)
  val = tonumber(val)
  if(allStatistics[val]) then
	  allStatistics[val].call("Plus", player)
    Wait.Frames(|| ChangeStatistic(val), 2)
  else
    broadcastToAll("�� ������� ��� ����������. ����������� ���������������")
  end
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
	if(colorObject.R == colorPlayer[color].r and colorObject.G == colorPlayer[color].g and colorObject.B == colorPlayer[color].b) then
    return true
  else
    return false
  end
end

function ActiveDeactivePanel(player, idPanel)
  local locActive = self.UI.getAttribute(idPanel, "active") == "false"
	self.UI.setAttribute(idPanel, "active", tostring(locActive))
end

function RebuildAssets()
  local root = 'https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/'
  local assets = {
    {name = 'uiGear', url = root .. 'gear.png'},
    {name = 'uiClose', url = root .. 'close.png'},
    {name = 'uiPlus', url = root .. 'plus.png'},
    {name = 'uiMinus', url = root .. 'minus.png'},
    {name = 'uiBars', url = root .. 'bars.png'}
  }
  self.UI.setCustomAssets(assets)
end

function Round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end