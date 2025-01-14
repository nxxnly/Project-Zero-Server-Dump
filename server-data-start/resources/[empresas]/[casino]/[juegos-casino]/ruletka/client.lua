ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj)
			ESX = obj 
		end)
		Citizen.Wait(0)
	end
end)
local blipX = -1400.94
local blipY = -605.00
local blipZ = 29.50
local pic = 'CHAR_SOCIAL_CLUB'
local game_during = false
local elements = {}

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('route68_ruletka:start')
AddEventHandler('route68_ruletka:start', function()
	ESX.TriggerServerCallback('esx_roulette:check_money', function(quantity)
		if quantity >= 10 then
			SendNUIMessage({
				type = "show_table",
				zetony = quantity
			})
			SetNuiFocus(true, true)
		else
			ESX.ShowNotification('Necesitas al menos 10 Fichas para poder jugar!')
			SendNUIMessage({
				type = "reset_bet"
			})
		end
	end, '')
end)

RegisterNUICallback('exit', function(data, cb)
	cb('ok')
	SetNuiFocus(false, false)
end)

RegisterNUICallback('betup', function(data, cb)
	cb('ok')
	TriggerServerEvent('InteractSound_SV:PlayOnSource', 'betup', 1.0)
end)

RegisterNUICallback('roll', function(data, cb)
	cb('ok')
	TriggerEvent('esx_roulette:start_game', data.kolor, data.kwota)
end)

RegisterNetEvent('esx_roulette:start_game')
AddEventHandler('esx_roulette:start_game', function(action, amount)
	local amount = amount
	if game_during == false then
		TriggerServerEvent('esx_roulette:removemoney', amount)
		local kolorBetu = action
		TriggerEvent('pNotify:SendNotification', {text = "Has apostado "..amount.." fichas al "..kolorBetu..". La ruleta gira..."})
		game_during = true
		local randomNumber = math.floor(math.random() * 36)
		--local randomNumber = 0
		SendNUIMessage({
			type = "show_roulette",
			hwButton = randomNumber
		})
		TriggerServerEvent('InteractSound_SV:PlayOnSource', 'ruletka', 1.0)
		Citizen.Wait(10000)
		local rojo = {32,19,21,25,34,27,36,30,23,5,16,1,14,9,18,7,12,3};
		local negro = {15,4,2,17,6,13,11,8,10,24,33,20,31,22,29,28,35,26};
		local function has_value (tab, val)
			for index, value in ipairs(tab) do
				if value == val then
					return true
				end
			end
			return false
		end
		if action == 'negro' then
			if has_value(negro, randomNumber) then
				local win = amount * 2
				ESX.ShowNotification('Has ganado '..win..' fichas!')
				TriggerServerEvent('esx_roulette:givemoney', action, amount)
			else
				ESX.ShowNotification('No has sido afortunado. Intentalo otra vez! Buena suerte!')
			end
		elseif action == 'rojo' then
			local win = amount * 2
			if has_value(rojo, randomNumber) then
				ESX.ShowNotification('Has ganado '..win..' fichas!')
				TriggerServerEvent('esx_roulette:givemoney', action, amount)
			else
				ESX.ShowNotification('No has sido afortunado. Intentalo otra vez! Buena suerte!')
			end
		elseif action == 'verde' then
			local win = amount * 14
			if randomNumber == 0 then
				ESX.ShowNotification('Has ganado '..win..' fichas!')
				TriggerServerEvent('esx_roulette:givemoney', action, amount)
			else
				ESX.ShowNotification('No has sido afortunado. Intentalo otra vez! Buena suerte!')
			end
		end
		--TriggerServerEvent('roulette:givemoney', randomNumber)
		SendNUIMessage({type = 'hide_roulette'})
		SetNuiFocus(false, false)
		--ESX.ShowNotification('Gra end!')
		game_during = false
		TriggerEvent('route68_ruletka:start')
	else
		ESX.ShowNotification('La ruleta esta girando...')
	end
end)