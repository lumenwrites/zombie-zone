extends Spatial

export(AudioStream) var hit_sound

const BLOOD_SPLATTER = preload("res://FX/BloodSplatter.tscn")
export var push_force = 5

var right_arm = false
export var fire_rate = 0.175
export var damage = 20
export var speed_modifier = 1.25
var can_fire = true

onready var parent = get_parent().get_parent()

func _ready():
	parent.speed *= speed_modifier

func _exit_tree():
	parent.speed /= speed_modifier


func _physics_process(delta):
	if not parent is Player: return
	if Input.is_action_just_pressed("fire"):
		fire()

func fire():
	if not can_fire: return

	if right_arm: $AnimationPlayer.play("hit1")
	else: $AnimationPlayer.play("hit2")
	right_arm = !right_arm
	
	var landed_a_hit = false
	var bodies_within_range = $DamageArea.get_overlapping_bodies()
	for body in bodies_within_range:
		var is_me = body == get_parent().get_parent()
		if not is_me and body.has_method("take_damage"):
			body.take_damage(damage)
			landed_a_hit = true
			if body is Bot:
				spawn_blood_splatter(body)
				push(body)

	
	if landed_a_hit:
		$AudioStreamPlayer.stream = hit_sound
		$AudioStreamPlayer.play()
	else:
		$AudioStreamPlayer.stream = load("res://assets/sounds/swoosh.wav")
		$AudioStreamPlayer.play()

	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true

func spawn_blood_splatter(body):
	var instance = BLOOD_SPLATTER.instance()
	body.add_child(instance)
	instance.translation = Vector3(0,0.7,-0.2)
	# instance.rotation_degrees.y = 180
	# instance.global_transform.basis = global_transform.basis
	# instance.look_at(parent.global_transform.origin+Vector3.UP*0.7, Vector3.UP)
	# instance.rotate_y(deg2rad(180))
	

func push(body):
	# if "vel" in body and not body is Player:
	var dir = parent.global_transform.origin.direction_to(body.global_transform.origin) * Vector3(1,0,1)
	dir = dir.normalized()
	body.vel += dir*push_force
