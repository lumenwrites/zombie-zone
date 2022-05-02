extends RigidBody

export(String, "Sword", "Gun", "Shotgun", "Assault Rifle", "Sniper Rifle", "Grenade", "Mine", "Sentry", "Rocket Launcher", "Air Strike", "Health Pack", "Armor", "Ammo") var default_weapon = "Fists"
export var random = true
export var max_health = 100.0
var current_health

# Fists, Sword, Gun, Shotgun, Assault Rifle, Sniper Rifle, Grenade
const WEAPON_PICKUP = preload("res://Pickups/WeaponPickup.tscn")
var objects = [
	preload("res://Pickups/AmmoBox.tscn"),
	preload("res://Pickups/ArmorPickup.tscn")
]
var weapon_types = ["Sword", "Gun", "Shotgun", "Assault Rifle", "Sniper Rifle", "Grenade", "Rocket Launcher", "Air Strike", "Mine", "Sentry"]

onready var pickups = get_parent() # get_node("/root/World/Pickups")

func _ready():
	# I disable rigid body when it hit the ground and stopped moving
	# Make sure it has some velocity at the beginning so it doesnt happen in the air
	linear_velocity = Vector3(0,-1,0)
	
	current_health = max_health

func _physics_process(delta):
	if linear_velocity.length() < 0.01:
		mode = RigidBody.MODE_STATIC


func take_damage(damage):
	if current_health > 0:
		current_health -= damage
		$HealthBar.update_progressbar(current_health, max_health)
		if current_health <= 0: 
			queue_free()
			drop_loot()

func drop_loot():
	# TODO: Check if player has no weapons, in that case always drop the weapon
	var instance
	randomize()
	instance = WEAPON_PICKUP.instance()

	if random:
		instance.weapon_type = weapon_types[int(rand_range(0,weapon_types.size()))]
		if rand_range(0,1) < 0.3:
			instance.weapon_type = "Health Pack"
		# 30% of the time spawn a support item.
		if rand_range(0,1) < 0.3:
			instance = objects[int(rand_range(0,objects.size()))].instance()
	
	if not random:
		instance.weapon_type = default_weapon
		if default_weapon == "Ammo": instance = objects[0].instance()
		if default_weapon == "Armor": instance = objects[1].instance()

	instance.global_transform.origin = global_transform.origin
	pickups.add_child(instance)
	
func drop_loot3():
	# TODO: Check if player has no weapons, in that case always drop the weapon
	var instance
	randomize()
	var rand = int(rand_range(0,weapon_types.size()+2))
	print(rand)
	if rand > weapon_types.size():
		instance = objects[rand-weapon_types.size()].instance()
	else:
		instance = WEAPON_PICKUP.instance()
		instance.weapon_type = weapon_types[rand-2]
	instance.global_transform = global_transform
	pickups.add_child(instance)


func drop_loot2():
	# TODO: Check if player has no weapons, in that case always drop the weapon
	randomize()
	var rand_object = objects[rand_range(0, objects.size())]
	var instance = rand_object.instance()
	if instance is WeaponPickup:
		instance.weapon_type = weapon_types[int(rand_range(0,weapon_types.size()))]
	instance.global_transform = global_transform
	pickups.add_child(instance)
