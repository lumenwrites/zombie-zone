extends Position3D


var BOT = preload("res://Bots/Bot.tscn")
var weapons = ["Fists", "Sword", "Gun", "Shotgun", "Assault Rifle", "Rocket Launcher", "Sniper Rifle", "Grenade"]

export var active = true
export var spawn_frequency = 7.0

export var max_enemies = 15
export var initial_enemies = 1
export var max_armor_probability = 0.8
export var initial_armor_probability = 0.0
export var initial_available_weapons = 1
var current_enemies = initial_enemies
var current_armor_probability = initial_armor_probability
var current_available_weapons = initial_available_weapons

var can_spawn = true

onready var bots = get_node("/root/World/Bots")

func _physics_process(delta):
	if active and can_spawn and bots.get_children().size() < current_enemies:
		spawn_bot()
		can_spawn = false
		yield(get_tree().create_timer(spawn_frequency), "timeout")
		can_spawn = true


func spawn_bot():
	var instance = BOT.instance()
	instance.global_transform.origin = global_transform.origin
	randomize()
	instance.default_weapon = weapons[rand_range(0,current_available_weapons)]
	instance.armored = rand_range(0,1) < current_armor_probability
	bots.add_child(instance)


func _on_IncreaseDifficulty_timeout():
	if current_enemies < max_enemies:
		current_enemies += 1
	if current_armor_probability < max_armor_probability:
		current_armor_probability += 0.05
	if current_available_weapons < weapons.size():
		current_available_weapons += 1
