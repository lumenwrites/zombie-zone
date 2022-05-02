extends Spatial

const BULLET = preload("res://Weapons/Bullet.tscn")

export var fire_rate = 0.12
export var reload_rate = 1.0
export var spread = 10
var current_spread = 0
export var damage = 20
export var bullet_speed = 30 # I want to make it faster for the sniper rifle
export var speed_modifier = 1.0
export var push_force = 10
var can_fire = true
var is_reloading = false

onready var switcher = get_parent()
onready var muzzle = $Muzzle
onready var audio_empty = $AudioEmpty
onready var audio_fire = $AudioFire
onready var audio_reload = $AudioReload
onready var animation = $AnimationPlayer
onready var parent = get_parent().get_parent()

func _ready():
	parent.speed *= speed_modifier

func _exit_tree():
	parent.speed /= speed_modifier
	
func _physics_process(delta):
	if not parent is Player: return

	if Input.is_action_just_pressed("fire"): 
		if switcher.get("clip_ammo") == 0:
			reload()
			return
		
	if Input.is_action_pressed("fire"): 
		fire()

	if Input.is_action_just_pressed("reload"): 
		reload()
	
	if current_spread > 0:
		current_spread = lerp(current_spread, 0, 1.0*delta)
		
func fire():
	if not can_fire: return
	if is_reloading: return
	if switcher.get("clip_ammo") == 0: return

	spread()
	spawn_bullet()
	switcher.spend_clip_ammo()
	# if switcher.get("clip_ammo") == 0: reload()
	animation.play("shoot")
	audio_fire.play()

	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true

func spread():
	muzzle.rotation = Vector3(0,0,0)
	muzzle.rotate_x(deg2rad(rand_range(-current_spread,current_spread)))
	muzzle.rotate_y(deg2rad(rand_range(-current_spread,current_spread)))
	# print(current_spread)
	current_spread = lerp(current_spread, spread, 1.0/switcher.get("clip_size"))


func spawn_bullet():
	var instance = BULLET.instance()
	instance.global_transform = muzzle.global_transform
	instance.damage = damage
	instance.speed = bullet_speed
	instance.push_force = push_force # shotgun is different
	instance.parent = get_parent().get_parent() # So I could make bullets ignore one who's shooting them
	get_node("/root/World").add_child(instance)

onready var reloading_bar = $"../../ReloadingBar"

func reload():
	if is_reloading: return
	if switcher.get("clip_ammo") == switcher.get("clip_size"): return
	if switcher.get("ammo") == 0: 
		audio_empty.play()
		return

	if parent is Player: 
		reloading_bar.activate_cooldown(reload_rate)

	animation.play("reload")
	is_reloading = true
	yield(get_tree().create_timer(reload_rate), "timeout")
	is_reloading = false
	
	switcher.reload()

	audio_reload.play()
	
