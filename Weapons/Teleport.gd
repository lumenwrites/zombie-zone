extends Spatial

export var max_damage = 120
export var min_damage = 50
export var max_range = 3.0
export var explosion_delay = 1.0
var reload_rate = 2.0
var fired = false
var exploded = false
var is_reloading = false

onready var player = get_node("/root/World/Player")
onready var cursor = get_node("/root/World/Player/Cursor")

onready var audio_empty = $AudioEmpty
onready var audio_fire = $AudioFire
onready var audio_reload = $AudioReload
onready var audio_explode = $AudioExplode
onready var target = $Target
onready var animation = $AnimationPlayer
onready var switcher = get_parent()
onready var is_player = get_parent().get_parent() is Player
onready var HUD = get_node("/root/World/HUD")

func _ready():
	set_as_toplevel(true)
	animation.play("turn")

func _physics_process(delta):
	# For some reason it keeps rotating even if I set it as toplevel?
	# Probably because player does look at
	global_transform.basis = Basis()
	global_transform.origin = cursor.global_transform.origin
	if Input.is_action_just_pressed("fire"):
		player.global_transform.origin = global_transform.origin
		target.hide()
		reload()


func reload():
	if is_reloading: return
	if switcher.get("ammo") == 0:
		audio_empty.play()
		return

	if is_player: 
		HUD.activate_cooldown(0, reload_rate)
	is_reloading = true
	yield(get_tree().create_timer(reload_rate), "timeout")
	is_reloading = false
	
	switcher.spend_ammo(1) 
	audio_reload.play()
	fired = false
	exploded = false
	target.show()
	animation.play("turn")
	


func _on_AudioExplode_finished():
	return
	reload()
