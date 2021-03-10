function onLoad()
  watchword = "Игровой персонаж"
end

function onCollisionEnter(info)
  if(watchword) then
    for _,v in pairs(getObjects()) do
      if(v.getGMNotes():find(watchword)) then
        saveScript = v.getLuaScript()
        saveXml = v.UI.getXml()
        newGameCharacter = info.collision_object
        return
      end
    end
    print("Нет Игрового персонажа на столе, для копирования скрипта")
  end
end

function ApplyChanges()
  if(newGameCharacter and saveScript and saveXml) then
    print("Скрипт скопирован")
    newGameCharacter.UI.setXml(saveXml)
    Wait.time(function() newGameCharacter.setLuaScript(saveScript) end, 1)
  end
end