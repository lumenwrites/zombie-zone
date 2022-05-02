extends Spatial

const GRENADE = preload("res://Weapons/Grenade.tscn")

export var grenade_speed = 30
export var fire_rate = 2.0
export var damage = 100

var charge = 0.2
var can_fire = true
var grenade_in_the_air # set it after I spawn it so I could explode it

onready var switcher = get_parent()
onready var muzzle = $Muzzle
onready var charge_audio = $ChargeAudio
onready var throw_audio = $ThrowAudio
onready var animation = $AnimationPlayer
onready var grenade = $Arm2/Grenade
onready var parent = get_parent().get_parent()

func _physics_process(delta):
	if not parent is Player: return

	if Input.is_action_just_pressed("fire") and is_instance_valid(grenade_in_the_air):
		grenade_in_the_air.explode()
		# return

	if not can_fire: return
	if switcher.get("ammo") == 0: return

	if Input.is_action_just_pressed("fire"):
		charge_audio.play()

	if Input.is_action_pressed("fire"):
		charge = lerp(charge, 1, delta*0.25)

	if Input.is_action_just_released("fire"):
		charge_audio.stop()

func _on_ChargeAudio_finished():
	throw_grenade()
	charge = 0.2

func fire():
	# Only for bots
	if not can_fire: return
	charge = 0.25
	throw_grenade()
	
func throw_grenade():
	throw_audio.play()
	animation.play("throw")
	grenade.hide()

	spawn_missile()
	switcher.spend_ammo(1)

	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true
	grenade.show()

	
func spawn_missile():
	var instance = GRENADE.instance()
	instance.global_transform = muzzle.global_transform
	instance.max_damage = damage
	instance.min_damage = damage/4
	instance.apply_central_impulse(-muzzle.global_transform.basis.z * grenade_speed * charge)
	grenade_in_the_air = instance
	get_node("/root/World").add_child(instance)


