extends Spatial

export(PackedScene) var weapon = preload("res://Weapons/Sentry.tscn")
export var fire_rate = 1.0
export var damage = 50
export var speed_modifier = 0.7
var can_fire = true
onready var parent = get_parent().get_parent()
onready var switcher = get_parent()
onready var build_audio = $BuildAudio
onready var reload_audio = $ReloadAudio
onready var weapon_model = $WeaponModel/Model

func _ready():
	parent.speed *= speed_modifier

func _exit_tree():
	parent.speed /= speed_modifier

func _physics_process(delta):
	if not parent is Player: return
	if Input.is_action_just_pressed("fire"):
		fire()

func fire():
	if can_fire:
		spawn_weapon()
		switcher.spend_ammo(1)
		build_audio.play()
		weapon_model.hide()
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
		can_fire = true
		weapon_model.show()
		reload_audio.play()

func spawn_weapon():
	var instance = weapon.instance()
	instance.global_transform.origin = parent.global_transform.origin - parent.global_transform.basis.z*1.5
	instance.parent = get_parent().get_parent()
	print(instance.global_transform.origin)
	get_node("/root/World").add_child(instance)
