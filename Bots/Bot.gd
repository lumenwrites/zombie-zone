class_name Bot # used in sentry
extends KinematicBody

export(String, "Fists", "Sword", "Gun", "Shotgun", "Assault Rifle", "Sniper Rifle", "Grenade", "Rocket Launcher", "Zombie Fists") var default_weapon = "Fists"
const SETTINGS = {
	"Fists": {
		"target_distance": 1.5,
		"aiming_speed": 3,
		"aiming_accuracy": 0.95,
		"offcenter": false
	},
	"Zombie Fists": {
		"target_distance": 1.5,
		"aiming_speed": 3,
		"aiming_accuracy": 0.95,
		"offcenter": false
	},
	"Sword": {
		"target_distance": 2,
		"aiming_speed": 3,
		"aiming_accuracy": 0.9,
		"offcenter": false
	},
	"Gun": {
		"target_distance": 8,
		"aiming_speed": 3,
		"aiming_accuracy": 0.95,
		"offcenter": true
	},
	"Shotgun": { 
		"target_distance": 5,
		"aiming_speed": 3,
		"aiming_accuracy": 0.95,
		"offcenter": true
	},
	"Assault Rifle": {
		"target_distance": 8,
		"aiming_speed": 3,
		"aiming_accuracy": 0.95,
		"offcenter": true
	},
	"Sniper Rifle": { 
		"target_distance": 12,
		"aiming_speed": 2,
		"aiming_accuracy": 0.98,
		"offcenter": true
	},
	"Grenade": { 
		"target_distance": 8,
		"aiming_speed": 3,
		"aiming_accuracy": 0.95,
		"offcenter": false
	},
	"Rocket Launcher": { 
		"target_distance": 8,
		"aiming_speed": 3,
		"aiming_accuracy": 0.7,
		"offcenter": false
	}
}

export var target_distance = 2
export var aiming_speed = 5
export var aiming_accuracy = 0.95 # shoot only once forward.dot(dir) > aiming_accuracy
export var weapon_damage_multiplier = 0.25
export var is_active = true
export var do_attack = true
export var armored = false
export var delay = 0.0

export var max_health = 100
var current_health = max_health

export var speed = 30 # 50 # 75
export var friction = 0.875
export var gravity = 80

var vel = Vector3()
var player_pos = Vector3()
var my_pos = Vector3()
var target = Vector3() # target for nav path, will be set to player's position
var path = []
var weapon

onready var HUD = get_node("/root/World/HUD")
onready var PlayerNode = get_node("/root/World/Player")
onready var Nav = get_node("/root/World/Navigation")
onready var sightline = $Sightline
onready var weapon_sightline = $WeaponSightline
onready var healthbar = $HealthBar
onready var switcher = $WeaponSwitcher
onready var body = $Model/character_placer_ctrl/body_ctrl
onready var vest = $Vest

func _ready():
	sightline.set_as_toplevel(true)
	weapon_sightline.set_as_toplevel(true) 

	target_distance = SETTINGS[default_weapon]["target_distance"]
	aiming_speed = SETTINGS[default_weapon]["aiming_speed"]
	aiming_accuracy = SETTINGS[default_weapon]["aiming_accuracy"]

	switcher.slots[0] = Constants.WEAPONS[default_weapon].duplicate(true)
	switcher.switch_weapon()
	weapon = switcher.get_children()[0]
	weapon.damage *= weapon_damage_multiplier
	# Armored
	if armored:
		vest.show()
		max_health *= 2
		current_health = max_health
	if delay:
		is_active = false
		hide()
		yield(get_tree().create_timer(delay), "timeout")
		is_active = true
		show()

func _physics_process(delta):
	vest.translation.y = body.translation.y

	if not is_active: return
	if PlayerNode.is_dead: return
	player_pos = PlayerNode.global_transform.origin
	my_pos = global_transform.origin
	sightline.global_transform.origin = my_pos + Vector3(0,0.7,0)
	sightline.look_at(player_pos + Vector3(0,0.7,0), Vector3.UP)

	var dir = my_pos.direction_to(player_pos)
	var dist = my_pos.distance_to(player_pos)
	var player_in_line_of_sight = sightline.is_colliding() and sightline.get_collider() is Player
	var forward = -global_transform.basis.z
	
	if dist > target_distance or not player_in_line_of_sight:
		# Move towards player
		update_path()
		follow_path(delta)

	vel *= friction
	if not is_on_floor(): 
		vel.y -= gravity * delta
	vel = move_and_slide(vel, Vector3.UP, true)
	
	if vel.length() > 0.5:
		$Model/AnimationPlayer.play("walk")
	else:
		$Model/AnimationPlayer.play("idle")
	
	# Slowly aim at player
	rotation.y = lerp_angle(rotation.y, sightline.rotation.y, aiming_speed*delta)

	# Weapon is shifted to the left of the bot. 
	# So when it's looking at player, weapon is aimed off to the side of him.
	# So I need to make the weapon aim at the middle of the player separately
	if SETTINGS[default_weapon]["offcenter"]:
		weapon.set_as_toplevel(true) 
		var weapon_pos = my_pos + global_transform.basis.x*0.25  + Vector3.UP*0.7
		weapon_sightline.look_at_from_position(weapon_pos, player_pos + Vector3(0,0.7,0), Vector3.UP)
		weapon.global_transform.origin = weapon_pos
		weapon.rotation.y = lerp_angle(weapon.rotation.y, weapon_sightline.rotation.y, aiming_speed*delta)

	# Shoot once aimed
	var aimed_at_player = forward.dot(dir) > aiming_accuracy
	if not do_attack: return
	if aimed_at_player and player_in_line_of_sight and dist <= target_distance:
		weapon.fire()

func update_path():
	# Update NavPath if player walks too far away from the target
	if target.distance_to(player_pos) > 1: 
		target = player_pos # save into a variable so I know how far player walks away from it
		path = Nav.get_simple_path(global_transform.origin, target)

func follow_path(delta):
	if path.size() == 0: return
	var next_pos = path[0]
	var my_pos = global_transform.origin
	
	# If I have arrived at a point - remove it
	if my_pos.distance_to(next_pos) < 1:
		path.remove(0) 
		return
	# Move towards the next point 
	# Only along x/z, let the gravity/collisions handle y
	vel.x += my_pos.direction_to(next_pos).x * speed * delta
	vel.z += my_pos.direction_to(next_pos).z * speed * delta


func take_damage(damage):
	if not is_active: return
	if current_health > 0:
		current_health -= damage
		healthbar.update_progressbar(current_health,max_health)
		# Hide armor once it's destroyed. This looks weird, just keep armor on and double the health.
#		if current_health <= 100: 
#			vest.hide()
		if current_health <= 0: 
			switcher.drop_weapon()
			HUD.increment_score()
			spawn_blood_explosion()
			queue_free()

onready var BLOOD_EXPLOSION = preload("res://FX/BloodExplosion.tscn")
func spawn_blood_explosion():
	var instance = BLOOD_EXPLOSION.instance()
	get_node("/root/World").add_child(instance)
	# has to be after adding it as a child, otherwise Im getting
	# get_global_transform: Condition "!is_inside_tree()" is true. Returned: Transform()
	# only here and not on any other spawns, for some reason.
	instance.global_transform.origin = global_transform.origin
