ESX = nil
local PhoneNumbers = {}

TriggerEvent('esx:getSO', function(obj)
  ESX = obj
end)

function AlertSMS(number, alert, listeSrc)
  if PhoneNumbers[number] ~= nil then
    local mess = 'De #' .. alert.numero  .. ' : ' .. alert.message
    if alert.coords ~= nil then
      mess = mess .. ' ' .. alert.coords.x .. ', ' .. alert.coords.y 
    end

    for k, _ in pairs(listeSrc) do
      getPhoneNumber(tonumber(k), function(nn)
        if nn ~= nil then
          TriggerEvent('gcPhone:_internalAddMessage', number, nn, mess, 0, function (smssMess)
            TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smssMess)
          end)
        end
      end)
    end
  end
end

AddEventHandler('esx_phone:registerNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
  local source = source
  print('= INFO = Enregistrement du telephone ' .. number .. ' => ' .. type)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
    sources       = {},
    alerts        = {}
	}
end)


AddEventHandler('esx:setJob', function(source, job, lastJob)
  if PhoneNumbers[lastJob.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', lastJob.name, source)
  end

  if PhoneNumbers[job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:addSource', job.name, source)
  end
end)

AddEventHandler('esx_addons_gcphone:addSource', function(number, source)
  local source = source
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('esx_addons_gcphone:removeSource', function(number, source)
  local source = source
	PhoneNumbers[number].sources[tostring(source)] = nil
end)

RegisterServerEvent('gcPhone:sendMessage')
AddEventHandler('gcPhone:sendMessage', function(number, message)
    local source = source
    if PhoneNumbers[source] ~= nil then
      getPhoneNumber(sourcePlayer, function (phone) 
        AlertSMS(number, { message = message, numero = phone }, PhoneNumbers[number].sources)
      end)
    end
end)

RegisterServerEvent('esx_addons_gcphone:startCall')
AddEventHandler('esx_addons_gcphone:startCall', function(number, message, coords)
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      AlertSMS(number, { message = message, coords = coords, numero = phone }, PhoneNumbers[number].sources)
    end)
  else
    print('= WARNING = Appels sur un service non enregistre => numero : ' .. number)
  end
end)


AddEventHandler('esx:playerLoaded', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)

    local phoneNumber = result[1].phone_number
    xPlayer.set('phoneNumber', phoneNumber)

    if PhoneNumbers[xPlayer.job.name] ~= nil then
      TriggerEvent('esx_addons_gcphone:addSource', xPlayer.job.name, source)
    end
  end)
end)

AddEventHandler('esx:playerDropped', function(source)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if PhoneNumbers[xPlayer.job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', xPlayer.job.name, source)
  end
end)

function getPhoneNumber (source, callback) 
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer == nil then
    callback(nil)
  end
  MySQL.Async.fetchAll('SELECT phone_number FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)
    callback(result[1].phone_number)
  end)
end

RegisterServerEvent('esx_phone:send')
AddEventHandler('esx_phone:send', function(number, message, _, coords)
  local sourcePlayer = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(sourcePlayer, function (phone) 
      AlertSMS(number, { message = message, coords = coords, numero = phone }, PhoneNumbers[number].sources)
    end)
  else
    print('esx_phone:send | Appels sur un service non enregistre => numero : ' .. number)
  end
end)