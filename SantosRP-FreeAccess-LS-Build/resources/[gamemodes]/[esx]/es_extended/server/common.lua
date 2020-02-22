ESX = {}
ESX.Players = {}
ESX.UsableItemsCallbacks = {}
ESX.Items = {}
ESX.ServerCallbacks = {}
ESX.TimeoutCount = -1
ESX.CancelledTimeouts = {}
ESX.LastPlayerData = {}
ESX.Pickups = {}
ESX.PickupId = 0
ESX.Jobs = {}
ESX.Orgs = {}

AddEventHandler('esx:getSO', function(cb)
	cb(ESX)
end)

function getSO()
	return ESX
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for k,v in ipairs(result) do
			ESX.Items[v.name] = {
				label     = v.label,
				limit     = v.limit,
				rare      = v.rare,
				canRemove = v.can_remove,
			}
		end
	end)

	MySQL.Async.fetchAll('SELECT * FROM jobs', {}, function(jobs)
		for k,v in ipairs(jobs) do
			ESX.Jobs[v.name] = v
			ESX.Jobs[v.name].grades = {}
		end

		MySQL.Async.fetchAll('SELECT * FROM job_grades', {}, function(jobGrades)
			for k,v in ipairs(jobGrades) do
				if ESX.Jobs[v.job_name] then
					ESX.Jobs[v.job_name].grades[tostring(v.grade)] = v
				else
					print(('[es_extended] [^3WARNING^7] Ignoring job grades for "%s" due to missing job'):format(v.job_name))
				end
			end

			for k2,v2 in pairs(ESX.Jobs) do
				if ESX.Table.SizeOf(v2.grades) == 0 then
					ESX.Jobs[v2.name] = nil
					print(('[es_extended] [^3WARNING^7] Ignoring job "%s" due to no job grades found'):format(v2.name))
				end
			end
		end)
	end)

	MySQL.Async.fetchAll('SELECT * FROM orgs', {}, function(orgs)
		for k,v in ipairs(orgs) do
			ESX.Orgs[v.name] = v
			ESX.Orgs[v.name].grades = {}
		end

		MySQL.Async.fetchAll('SELECT * FROM org_grades', {}, function(orgGrades)
			for k,v in ipairs(orgGrades) do
				if ESX.Orgs[v.org_name] then
					ESX.Orgs[v.org_name].grades[tostring(v.org_grade)] = v
				else
					print(('[es_extended] [^3WARNING^7] Ignoring org grades for "%s" due to missing job'):format(v.job_name))
				end
			end

			for k2,v2 in pairs(ESX.Orgs) do
				if ESX.Table.SizeOf(v2.grades) == 0 then
					ESX.Orgs[v2.name] = nil
					print(('[es_extended] [^3WARNING^7] Ignoring org "%s" due to no job grades found'):format(v2.name))
				end
			end
		end)
	end)

	print('[es_extended] [^2INFO^7] ESX developed by ESX-Org has been initialized')
end)

AddEventHandler('esx:playerLoaded', function(playerId)
	local xPlayer, accounts, items = ESX.GetPlayerFromId(playerId), {}, {}
	local xPlayerAccounts, xPlayerItems = xPlayer.getAccounts(), xPlayer.getInventory()
	
	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	for i=1, #xPlayerItems, 1 do
		items[xPlayerItems[i].name] = xPlayerItems[i].count
	end

	ESX.LastPlayerData[playerId] = {
		accounts = accounts,
		items = items
	}
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[es_extended] [^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESX.TriggerServerCallback(name, requestID, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)