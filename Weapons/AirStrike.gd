extends Spatial

export var max_damage = 200
export var min_damage = 50
export var max_range = 3.0
export var explosion_delay = 1.0
var reload_rate = 2.0
var can_fire = true

onready var cursor = get_node("/root/World/Player/Cursor")
onready var damage_area = $Target/DamageArea
onready var audio_empty = $AudioEmpty
onready var audio_fire = $AudioFire
onready var audio_reload = $AudioReload
onready var target = $Target
onready var rocket = $Target/Rocket
onready var animation = $AnimationPlayer
onready var rocket_animation = $RocketAnimation
onready var switcher = get_parent()
onready var is_player = get_parent().get_parent() is Player
onready var HUD = get_node("/root/World/HUD")
onready var reloading_bar = $"../../ReloadingBar"

func _ready():
	target.set_as_toplevel(true)
	# target.set_as_toplevel(true)
	damage_area.scale *= max_range
	animation.play("turn")

func _physics_process(delta):
	# For some reason it keeps rotating even if I set it as toplevel?
	# Probably because player does look at
	target.global_transform.basis = Basis()

	if can_fire:
		target.global_transform.origin = cursor.global_transform.origin
		if Input.is_action_just_pressed("fire"):
			can_fire = false
			animation.stop()
			audio_fire.play()
			rocket.show()
			rocket_animation.play("fire")
			yield(get_tree().create_timer(0.7), "timeout")
			explode()


func explode():
	var bodies_within_range = damage_area.get_overlapping_bodies()
	print(bodies_within_range)
	for body in bodies_within_range:
		if body.has_method("take_damage"):
			var distance = (body.global_transform.origin - target.global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			body.take_damage(decayed_damage)
	target.hide()
	rocket.hide()
	# audio_explode.play()
	spawn_explosion(target.global_transform.origin)

	reload()

onready var EXPLOSION = preload("res://FX/Explosion.tscn")
func spawn_explosion(pos):
	var instance = EXPLOSION.instance()
	instance.global_transform.origin = pos
	get_node("/root/World").add_child(instance)

func reload():
	if switcher.get("ammo") == 0:
		audio_empty.play()
		return

	
	if is_player: 
		reloading_bar.activate_cooldown(reload_rate)

	yield(get_tree().create_timer(reload_rate), "timeout")
	can_fire = true
	switcher.spend_ammo(1) 
	audio_reload.play()
	target.show()
	animation.play("turn")

func _on_AudioExplode_finished():
	return
	reload()

