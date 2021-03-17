function onLoad()
  allCharacteristicsAt, allCharacteristicsDef = {}, {}
  modifiedAttacker, modifiedDefensive = 0, 0
  countRollAttacker, countRollDefensive = 1, 1
  diceRollMinAttacker, diceRollMaxAttacker = {1, 1}, {20, 10}
  diceRollMinDefensive, diceRollMaxDefensive = {1, 1}, {20, 10}
  characteristicAttacker, characteristicDefensive = "", ""
  nameAttacker, nameDefensive = "", ""
  Wait.time(function() originalXml = self.UI.getXml() end, 0.8)
end

function Roll()
  broadcastToAll("-•-•-•-•-•-•-•-•-•-•-", {r = 0, g = 0, b = 0})
  if(countRollAttacker > 0) then
    broadcastToAll(string.format("Атакующий/Attacker %d•%d",
                   CreateRollText(countRollAttacker, diceRollMinAttacker[1], diceRollMaxAttacker[1], modifiedAttacker),
                   CreateRollText(countRollAttacker, diceRollMinAttacker[2], diceRollMaxAttacker[2], modifiedAttacker)),
                   {r = 1, g = 0.14, b = 0})
  end
  if(countRollDefensive > 0) then
    broadcastToAll(string.format("Защищаюсийся/Defensive %d•%d",
                   CreateRollText(countRollDefensive, diceRollMinDefensive[1], diceRollMaxDefensive[1], modifiedDefensive),
                   CreateRollText(countRollDefensive, diceRollMinDefensive[2], diceRollMaxDefensive[2], modifiedDefensive)),
                   {r = 0.99, g = 0.99, b = 0.16})
  end
  broadcastToAll("-•-•-•-•-•-•-•-•-•-•-", {r = 0, g = 0, b = 0})
end
function CreateRollText(countRoll, diceRollMin, diceRollMax, modified)
  local messageRoll = ""
  for i = 1, countRoll do
    local additionalText = (((countRoll - i > 0) and "-•-") or "")
    local randomValue = math.ceil(math.random(diceRollMin, diceRollMax*100)/100)
    local resultText = (modified ~= 0 and ((randomValue + modified) .. "("..randomValue..")")) or
                        randomValue
    messageRoll = messageRoll .. resultText .. additionalText
  end
  return messageRoll
end

function InputCountRoll(_, input, id)
  if(input == "") then return end

  if(id == "attacker") then
    countRollAttacker = tonumber(input)
  elseif(id == "defensive") then
    countRollDefensive = tonumber(input)
  end
end

function InputDiceRoll(_, input, id)
  if(input == "") then return end

  if(id == "attacker") then
    local findD = input:find("/")
    if(findD) then
      diceRollMinAttacker[1] = tonumber(input:sub(1, findD - 1))
      diceRollMaxAttacker[1] = tonumber(input:sub(findD + 1))
    else
      diceRollMaxAttacker[1] = tonumber(input)
    end
  elseif(id == "defensive") then
    local findD = input:find("/")
    if(findD) then
      diceRollMinDefensive[1] = tonumber(input:sub(1, findD - 1))
      diceRollMaxDefensive[1] = tonumber(input:sub(findD + 1))
    else
      diceRollMaxDefensive[1] = tonumber(input)
    end
  end
end
function InputMoreDiceRoll(_, input, id)
  if(input == "") then return end

  if(id == "attacker") then
    local findD = input:find("/")
    if(findD) then
      diceRollMinAttacker[2] = tonumber(input:sub(1, findD - 1))
      diceRollMaxAttacker[2] = tonumber(input:sub(findD + 1))
    else
      diceRollMaxAttacker[2] = tonumber(input)
    end
  elseif(id == "defensive") then
    local findD = input:find("/")
    if(findD) then
      diceRollMinDefensive[2] = tonumber(input:sub(1, findD - 1))
      diceRollMaxDefensive[2] = tonumber(input:sub(findD + 1))
    else
      diceRollMaxDefensive[2] = tonumber(input)
    end
  end
end

function InputModified(_, input, id)
  if(input == "") then return end
  
  if(id == "attacker") then
    modifiedAttacker = tonumber(input)
  elseif(id == "defensive") then
    modifiedDefensive = tonumber(input)
  end
end

function CreateCharacteristics(param)
  local searchString, searchStringLength, indexEndFirstCharacteristic
  local startXml, endXml
  local allXml = originalXml

  if(param.type == "attacker") then
    local locText = "{ru}атакующий %s{en}attacker %s"
    nameAttacker = string.format(locText, param.name, param.name)
    allCharacteristicsAt = param.allCharacteristics
    characteristicAttacker = AddNewCharacteristic(param.allCharacteristics, param.type)
    searchStringAt = "<NewRowAt />"
  elseif(param.type == "defensive") then
    local locText = "{ru}защищающийся %s{en}defensive %s"
    nameDefensive = string.format(locText, param.name, param.name)
    allCharacteristicsDef = param.allCharacteristics
    characteristicDefensive = AddNewCharacteristic(param.allCharacteristics, param.type)
    searchStringDef = "<NewRowDef />"
  end

  if(characteristicAttacker ~= "") then
    Wait.time(function()
      self.UI.setAttribute("textAttacker", "text", nameAttacker)
      EnlargeHeightPanel(#allCharacteristicsAt, "TLPanelCharAt")
    end, 0.1)
    searchStringLength = #searchStringAt
    indexEndFirstCharacteristic = allXml:find(searchStringAt)
    startXml = allXml:sub(1, indexEndFirstCharacteristic + searchStringLength)
    endXml = allXml:sub(indexEndFirstCharacteristic + searchStringLength)

    allXml = startXml .. characteristicAttacker .. endXml
  end
  if(characteristicDefensive ~= "") then
    Wait.time(function()
      self.UI.setAttribute("textDefensive", "text", nameDefensive)
      EnlargeHeightPanel(#allCharacteristicsDef, "TLPanelCharDef")
    end, 0.1)
    searchStringLength = #searchStringDef
    indexEndFirstCharacteristic = allXml:find(searchStringDef)
    startXml = allXml:sub(1, indexEndFirstCharacteristic + searchStringLength)
    endXml = allXml:sub(indexEndFirstCharacteristic + searchStringLength)

    allXml = startXml .. characteristicDefensive .. endXml
  end
  self.UI.setXml(allXml)
end
function AddNewCharacteristic(allCharacteristics, type)
  local newCharacteristic = ""
  if(#allCharacteristics > 0) then
    for index,char in ipairs(allCharacteristics) do
      local textChar = CreateNameForCharacteristic(char)
      if(textChar) then
        local locColor = "#ffffff"
        local typeChar = char.UI.getAttribute("selectionType", "text")
        if(typeChar ~= "обычная") then
          locColor = (typeChar == "боевая" and "#ff0000") or (typeChar == "мирная" and "#00ff00") or (typeChar == "пустая" and "#808080") or locColor
        end

        newCharacteristic = newCharacteristic .. [[
          <Row preferredHeight='50'>
            <Cell columnSpan='5'>
              <Text id='tCharAttacker]]..index..[[' class='forCharacteristic' color=']]..locColor..[[' text=']]..textChar..[['/>
            </Cell>
            <Cell columnSpan='1'>
              <Toggle id=']]..type..index..[[' toggleWidth='35' toggleHeight='35' onValueChanged='AddCharacteristicModified'
                tooltip=
                'Использовать характеристику в подсчетах
                Use the characteristic in calculations'
                tooltipFontSize='35' tooltipWidth='300' tooltipPosition='Above' tooltipOffset='20'/>
            </Cell>
          </Row>
        ]]
      end
    end
  end
  return newCharacteristic
end

function CreateNameForCharacteristic(charac)
  local name = charac.UI.getAttribute("name", "text")
  local charact = tonumber(charac.UI.getValue("textCharacteristic"))
  local bonusChar = tonumber(charac.UI.getValue("textCharacteristicBonus"))
  return name .. " (" .. (charact + bonusChar) .. ")"
end
function CreateValue(charac)
  local charact = tonumber(charac.UI.getValue("textCharacteristic"))
  local bonusChar = tonumber(charac.UI.getValue("textCharacteristicBonus"))
  return charact + bonusChar
end

function EnlargeHeightPanel(countIndex, id)
  if(countIndex > 8) then
    --preferredHeight=50 cellSpacing=5
    local newHeightPanel = countIndex * 50 + countIndex * 5 + 50
    Wait.time(|| self.UI.setAttribute(id, "height", newHeightPanel), 0.2)
  end
end

function AddCharacteristicModified(_, value, id)
  if(id:find("attacker")) then
    id = tonumber(id:sub(9))
    if(value == "True") then
      modifiedAttacker = modifiedAttacker + CreateValue(allCharacteristicsAt[id])
    else
      modifiedAttacker = modifiedAttacker - CreateValue(allCharacteristicsAt[id])
    end
  elseif(id:find("defensive")) then
    id = tonumber(id:sub(10))
    if(value == "True") then
      modifiedDefensive = modifiedDefensive + CreateValue(allCharacteristicsDef[id])
    else
      modifiedDefensive = modifiedDefensive - CreateValue(allCharacteristicsDef[id])
    end
  end
end