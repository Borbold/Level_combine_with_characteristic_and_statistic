function UpdateSave()
  local dataToSave = {
    ["allStatisticsGUID"] = allStatisticsGUID
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
  RebuildAssets()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    allStatisticsGUID = loadedData.allStatisticsGUID or {}
    SetStatisticObjects()
    Wait.Frames(|| CreateStatistics(#allStatisticsGUID), 3)
  end
end

function SetStatistics(statistics)
  self.UI.setXml(originalXml)
  allStatisticsGUID = {}
  for k,stat in pairs(statistics) do
	  allStatisticsGUID[k] = stat
  end
  SetStatisticObjects()
  Wait.Frames(|| CreateStatistics(#allStatisticsGUID), 3)
  UpdateSave()
end

function SetStatisticObjects()
  allStatistics = {}
	for k,statisticGUID in pairs(allStatisticsGUID) do
    if(getObjectFromGUID(statisticGUID)) then
	    allStatistics[k] = getObjectFromGUID(statisticGUID)
    else
      broadcastToAll("Одна или несколько статистик были удалены. Произведите переподключение")
      return
    end
  end
end

function CreateStatistics(count)
  AddNewStatistic(count)
  for i = 1, count do
    Wait.Frames(|| ChangeStatistic(i), 10)
  end
end

function AddNewStatistic(countStatisticIndex)
  local allXml = originalXml

  local searchString = "visibility="
  local searchStringLength = #searchString

  local indexVisibility = allXml:find(searchString)

  local startXml = allXml:sub(1, indexVisibility + searchStringLength)
  local endXml = allXml:sub(indexVisibility + searchStringLength + 1)--+1 нужен для того чтобы убрать лишний "

  local strVis = "Black|"..DenoteSth()
  allXml = startXml .. strVis .. endXml
  ----------------------------------------------------------------------------------------------------------
  local newStatistic = ""
  for statisticIndex = 1, countStatisticIndex do
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

  searchString = "</Row>"
  searchStringLength = #searchString

  local indexEndFirstStatistic = allXml:find(searchString)

  startXml = allXml:sub(1, indexEndFirstStatistic + searchStringLength)
  endXml = allXml:sub(indexEndFirstStatistic + searchStringLength)

  startXml = startXml .. newStatistic .. endXml
  self.UI.setXml(startXml)
  EnlargeHeightPanel(countStatisticIndex + 1)
end

function EnlargeHeightPanel(countStatisticIndex)
  if(countStatisticIndex > 4) then
    --preferredHeight=50 cellSpacing=5
    local newHeightPanel = countStatisticIndex * 50 + countStatisticIndex * 5
    Wait.Frames(|| self.UI.setAttribute("TLPanel", "height", newHeightPanel), 5)
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
    broadcastToAll("Вы удалили эту характеристику. Произведите переподключение")
  end
end
function Plus(player, val)
  val = tonumber(val)
  if(allStatistics[val]) then
	  allStatistics[val].call("Plus", player)
    Wait.Frames(|| ChangeStatistic(val), 2)
  else
    broadcastToAll("Вы удалили эту характеристику. Произведите переподключение")
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