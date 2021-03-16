function onLoad()
  allCharacteristicsAt, allCharacteristicsDef = {}, {}
  modifiedAttacker, modifiedDefensive = 0, 0
  countRollAttacker, countRollDefensive = 1, 1
  diceRollMinAttacker, diceRollMaxAttacker = 1, 20
  diceRollMinDefensive, diceRollMaxDefensive = 1, 20
  characteristicAttacker, characteristicDefensive = "", ""
  Wait.time(function() originalXml = self.UI.getXml() end, 0.8)
end

function Roll()
  if(countRollAttacker > 0) then
    broadcastToAll("Атакующий/Attacker " ..
                   CreateRollText(countRollAttacker, diceRollMinAttacker, diceRollMaxAttacker, modifiedAttacker),
                   {r = 1, g = 0.3, b = 0})
  end
  if(countRollDefensive > 0) then
    broadcastToAll("Защищаюсийся/Defensive " ..
                   CreateRollText(countRollDefensive, diceRollMinDefensive, diceRollMaxDefensive, modifiedDefensive),
                   {r = 0.99, g = 0.99, b = 0.16})
  end
end
function CreateRollText(countRoll, diceRollMin, diceRollMax, modified)
  local messageRoll = ""
  for i = 1, countRoll do
    local additionalText = (((countRoll - i > 0) and "-•-") or "")
    local randomValue = math.random(diceRollMin, diceRollMax)
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
    local findD = input:find("d")
    if(findD) then
      diceRollMinAttacker = tonumber(input:sub(1, findD - 1))
      diceRollMaxAttacker = tonumber(input:sub(findD + 1))
    else
      diceRollMaxAttacker = tonumber(input)
    end
  elseif(id == "defensive") then
    local findD = input:find("d")
    if(findD) then
      diceRollMinDefensive = tonumber(input:sub(1, findD - 1))
      diceRollMaxDefensive = tonumber(input:sub(findD + 1))
    else
      diceRollMaxDefensive = tonumber(input)
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
    allCharacteristicsAt = param.allCharacteristics
    characteristicAttacker = AddNewCharacteristic(param.allCharacteristics, param.type)
    searchStringAt = "<NewRowAt />"
  elseif(param.type == "defensive") then
    allCharacteristicsDef = param.allCharacteristics
    characteristicDefensive = AddNewCharacteristic(param.allCharacteristics, param.type)
    searchStringDef = "<NewRowDef />"
  end

  if(characteristicAttacker ~= "") then
    searchStringLength = #searchStringAt
    indexEndFirstCharacteristic = allXml:find(searchStringAt)
    startXml = allXml:sub(1, indexEndFirstCharacteristic + searchStringLength)
    endXml = allXml:sub(indexEndFirstCharacteristic + searchStringLength)

    allXml = startXml .. characteristicAttacker .. endXml
  end
  if(characteristicDefensive ~= "") then
    searchStringLength = #searchStringDef
    indexEndFirstCharacteristic = allXml:find(searchStringDef)
    startXml = allXml:sub(1, indexEndFirstCharacteristic + searchStringLength)
    endXml = allXml:sub(indexEndFirstCharacteristic + searchStringLength)

    allXml = startXml .. characteristicDefensive .. endXml
  end
  self.UI.setXml(allXml)

  EnlargeHeightPanel(#param.allCharacteristics, "TLPanelCharAt")
  EnlargeHeightPanel(#param.allCharacteristics, "TLPanelCharDef")
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
  if(countIndex > 9) then
    --preferredHeight=50 cellSpacing=5
    local newHeightPanel = countIndex * 50 + countIndex * 5
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