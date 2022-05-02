extends KinematicBody

class_name PlayerTP

export var speed = 75
export var friction = 0.875
export var gravity = 80
export var jump_power = 25

export var mouse_sensitivity = 0.3
var camera_x_rotation = 0 # keep track of camera rotation to avoid overlooking upside down

var vel = Vector3()

onready var camera_rig = $CameraRig
onready var camera = $CameraRig/Camera

onready var body = $Model/character_placer_ctrl/body_ctrl
onready var vest = $Vest
onready var raycast = $Camera/RayCast
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# $WeaponSwitcher.set_as_toplevel(true)
	
func _input(event):
	if event is InputEventMouseMotion:
		 # Capture mouse movement, save it to variable which will be used in aim()
		rotate_y(deg2rad(-event.relative.x  * mouse_sensitivity))
		$Camera.rotate_x(deg2rad(-event.relative.y  * mouse_sensitivity))
		$Camera.rotation.x = clamp($Camera.rotation.x, deg2rad(-90), deg2rad(90))
		
		
		# weapon.rotate_x(deg2rad(-event.relative.y  * mouse_sensitivity))
		# weapon.rotation.x = clamp(weapon.rotation.x, deg2rad(-45), deg2rad(25))

	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()



func _physics_process(delta):
	vest.visible = $Resources.current_armor > 0
	vest.translation.y = body.translation.y
	var weapon = $WeaponSwitcher.get_children()[0]
	weapon.set_as_toplevel(true)
	if raycast.is_colliding():
		var weapon_pos = global_transform.origin + global_transform.basis.x*0.5  + Vector3.UP*1.2
		weapon.global_transform.origin = weapon_pos
		$Visualizer.global_transform.origin = raycast.get_collision_point()
		weapon.look_at_from_position(weapon_pos, raycast.get_collision_point(), $Camera.global_transform.basis.y)
		# $WeaponSwitcher.get_children()[0].get_node("Muzzle").look_at(raycast.get_collision_point(), Vector3.UP)
	else:
		weapon.global_transform.basis = $Camera.global_transform.basis
	run(delta)

	vel *= friction
	if not is_on_floor(): vel.y -= gravity*delta
	
	# Snap prevents sliding on slopes, but to be able to jump I must disable it.
	var snap = Vector3.DOWN
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y += jump_power
		snap = Vector3()

	vel = move_and_slide_with_snap(vel, snap, Vector3.UP, true)


func run(delta):
	var move_direction = Vector3()

	if Input.is_action_pressed("up"):
		move_direction -= global_transform.basis.z
	elif Input.is_action_pressed("down"):
		move_direction += global_transform.basis.z
	if Input.is_action_pressed("left"):
		move_direction -= global_transform.basis.x
	elif Input.is_action_pressed("right"):
		move_direction += global_transform.basis.x
	move_direction.y = 0
	move_direction = move_direction.normalized()

	if move_direction:
		$Model/AnimationPlayer.play("walk")
	else:
		$Model/AnimationPlayer.play("idle")
	
	vel += move_direction*speed*delta

func take_damage(damage):
	print("take damage ", damage)
	$Resources.take_damage(damage)
