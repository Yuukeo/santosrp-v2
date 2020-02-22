Config                            = {}
Config.DrawDistance               = 5.0
Config.MarkerColor                = { r = 0, g = 50, b = 255 }
Config.EnablePlayerManagement     = true -- enables the actual car dealer job. You'll need esx_addonaccount, esx_billing and esx_society
Config.ResellPercentage           = 50
Config.Locale                     = 'fr'

Config.LicenseEnable = false -- require people to own drivers license when buying vehicles? Only applies if EnablePlayerManagement is disabled. Requires esx_license

-- looks like this: 'LLL NNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters  = 4
Config.PlateNumbers  = 3
Config.PlateUseSpace = true

Config.Zones = {

	ShopEntering = {
	    Pos   = vector3(-793.876, -218.610, 36.079),
	    Size  = { x = 1.5, y = 1.5, z = 1.0 },
	    Type  = 27,
	},

	ShopInside = {
		Pos     = vector3(-783.843, -224.042, 37.321),
		Size    = { x = 1.5, y = 1.5, z = 1.0 },
		Heading = 0.0,
		Type    = -1
	},

	ShopOutside = {
		Pos     = vector3(-772.088, -231.950, 36.079),
		Size    = { x = 1.5, y = 1.5, z = 1.0 },
		Heading = 205.0,
		Type    = -1
	},

	BossActions = {
	    Pos   = vector3(-788.40, -215.595, 36.079), 
	    Size  = { x = 1.5, y = 1.5, z = 1.0 },
	    Type  = 27,
	},

	GiveBackVehicle = {
		Pos   = vector3(-180000.227, -1078.558, 25.675),
		Size  = { x = 3.0, y = 3.0, z = 1.0 },
		Type  = (Config.EnablePlayerManagement and 1 or -1)
	},

	ResellVehicle = {
		Pos   = vector3(-44000.630, -1080.738, 25.683),
		Size  = { x = 3.0, y = 3.0, z = 1.0 },
		Type  = 1
	}

}
