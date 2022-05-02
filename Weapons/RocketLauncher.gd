extends Spatial

const MISSILE = preload("res://Weapons/SelfGuidingMissile.tscn")
export var fire_rate = 1.0
export var damage = 120
export var speed_modifier = 0.5
var can_fire = true
var rocket_in_the_air

onready var parent = get_parent().get_parent()
onready var fire_audio = $AudioFire
onready var audio_empty = $AudioEmpty
onready var animation = $AnimationPlayer
onready var switcher = get_parent()

func _ready():
	parent.speed *= speed_modifier

func _exit_tree():
	parent.speed /= speed_modifier

func _physics_process(delta):
	if not parent is Player: return

	if Input.is_action_just_pressed("fire") and is_instance_valid(rocket_in_the_air):
		rocket_in_the_air.explode()
		# return

	if Input.is_action_just_pressed("fire"):
		fire()

func fire():
	if switcher.get("ammo") == 0:
		audio_empty.play()
		return
	
	if can_fire:
		spawn_bullet()
		fire_audio.play()
		animation.play("fire")
		switcher.spend_ammo(1)
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
		can_fire = true

func spawn_bullet():
	var instance = MISSILE.instance()
	instance.global_transform = global_transform
	instance.max_damage = damage
	instance.min_damage = damage/4
	instance.parent = get_parent().get_parent()
	rocket_in_the_air = instance
	get_node("/root/World").add_child(instance)
