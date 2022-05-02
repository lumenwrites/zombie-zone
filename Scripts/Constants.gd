extends Node
# Fists, Sword, Gun, Shotgun, Assault Rifle, Sniper Rifle, Grenade
const WEAPONS = {
	"Fists": {
		"name": "Fists",
		"icon": preload("res://assets/icons/blank.png"),
		"scene": preload("res://Weapons/Fists.tscn")
	},
	"Sword": {
		"name": "Sword",
		"icon": preload("res://assets/weapon-icons/sword.png"),
		"scene": preload("res://Weapons/Sword.tscn")
	},
	# Deals more damage than Assault Rifle, more precise, gives you more speed
	"Gun": {
		"name": "Gun",
		"icon": preload("res://assets/weapon-icons/gun.png"),
		"scene": preload("res://Weapons/Gun.tscn"),
		"clip_ammo": 8,
		"clip_size": 8,
		"ammo": 32,
		"max_ammo": 32,
		"pickup_ammo_amount": 32
	},
	"Shotgun": { 
		"name": "Shotgun",
		"icon": preload("res://assets/weapon-icons/shotgun.png"),
		"scene": preload("res://Weapons/Shotgun.tscn"),
		"clip_ammo": 4,
		"clip_size": 4,
		"ammo": 12,
		"max_ammo": 24,
		"pickup_ammo_amount": 32
	},
	"Assault Rifle": {
		"name": "Assault Rifle",
		"icon": preload("res://assets/weapon-icons/assault-rifle.png"),
		"scene": preload("res://Weapons/Weapon.tscn"),
		"clip_ammo": 15,
		"clip_size": 15,
		"ammo": 50,
		"max_ammo": 150,
		"pickup_ammo_amount": 50
	},
	"Sniper Rifle": { 
		"name": "Sniper Rifle",
		"icon": preload("res://assets/weapon-icons/sniper-rifle.png"),
		"scene": preload("res://Weapons/SniperRifle.tscn"),
		"clip_ammo": 4,
		"clip_size": 4,
		"ammo": 12,
		"max_ammo": 32,
		"pickup_ammo_amount": 12
	},
	"Grenade": { 
		"name": "Grenade",
		"icon": preload("res://assets/weapon-icons/grenade.png"),
		"scene": preload("res://Weapons/GrenadeLauncher.tscn"),
		"ammo": 4,
		"max_ammo": 12,
		"pickup_ammo_amount": 4
	},
	"Rocket Launcher": { 
		"name": "Rocket Launcher",
		"icon": preload("res://assets/weapon-icons/rocket-launcher.png"),
		"scene": preload("res://Weapons/RocketLauncher.tscn"),
		"ammo": 4,
		"max_ammo": 12,
		"pickup_ammo_amount": 4
	},
	"Air Strike": { 
		"name": "Air Strike",
		"icon": preload("res://assets/weapon-icons/air-strike.png"),
		"scene": preload("res://Weapons/AirStrike.tscn"),
		"ammo": 4,
		"max_ammo": 12,
		"pickup_ammo_amount": 4
	},
	"Mine": { 
		"name": "Mine",
		"icon": preload("res://assets/weapon-icons/mine.png"),
		"scene": preload("res://Weapons/MineSpawner.tscn"),
		"ammo": 4,
		"max_ammo": 12,
		"pickup_ammo_amount": 2 # can't replenish it
	},
	"Sentry": { 
		"name": "Sentry",
		"icon": preload("res://assets/weapon-icons/sentry.png"),
		"scene": preload("res://Weapons/SentrySpawner.tscn"),
		"ammo": 4,
		"max_ammo": 12,
		"pickup_ammo_amount": 2 # can't replenish it
	},
	"Health Pack": { 
		"name": "Health Pack",
		"icon": preload("res://assets/weapon-icons/healthpack.png"),
		"scene": preload("res://Weapons/HealthPack.tscn"),
		"ammo": 2,
		"max_ammo": 12,
		"pickup_ammo_amount": 0 # can't replenish it
	},
	"Zombie Fists": {
		"name": "Zombie Fists",
		"icon": preload("res://assets/icons/blank.png"),
		"scene": preload("res://Weapons/ZombieFists.tscn")
	},
}


#	"Teleport": { 
#		"name": "Teleport",
#		"icon": preload("res://assets/weapon-icons/teleport.png"),
#		"scene": preload("res://Weapons/Teleport.tscn"),
#		"ammo": 4,
#		"max_ammo": 12,
#		"pickup_ammo_amount": 4
#	}
