extends KinematicBody

class_name Player

export var speed = 75
export var friction = 0.875
export var gravity = 80
export var jump_power = 25

var vel = Vector3()
var is_dead = false

onready var animation_player = $Model/AnimationPlayer
onready var camera = $CameraRig/Camera
onready var resources = $Resources
onready var cursor = $Cursor
onready var look_at_crusor = $LookAtCursor
onready var body = $Model/character_placer_ctrl/body_ctrl
onready var vest = $Vest

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor.set_as_toplevel(true)
	look_at_crusor.set_as_toplevel(true)

func _physics_process(delta):
	if is_dead: return
	vest.visible = $Resources.current_armor > 0
	vest.translation.y = body.translation.y
	look_at_cursor()
	run(delta)

	vel *= friction
	if not is_on_floor(): vel.y -= gravity*delta
	
	# Snap prevents sliding on slopes, but to be able to jump I must disable it.
	var snap = Vector3.DOWN
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y += jump_power
		snap = Vector3()

	vel = move_and_slide_with_snap(vel, snap, Vector3.UP, true)

func look_at_cursor():
	var space_state = get_world().direct_space_state
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var intersect = space_state.intersect_ray(from, to, [], 32) # 4
	if not intersect: return
	
	var cursor_pos = intersect["position"]
	var normal = intersect["normal"]
	# Set the position of cursor visualizer. Elevated a tiny bit above the ground.
	cursor.global_transform.origin = cursor_pos + Vector3.UP*0.7 # + normal*0.01

	# Aligns the cursor along the surface normal
	cursor.look_at(cursor_pos + normal, Vector3(0.0001,1,0.0001))

	var player_pos = global_transform.origin
	look_at_crusor.look_at_from_position(player_pos, cursor_pos, Vector3.UP)
	rotation.y = look_at_crusor.rotation.y
	$WeaponSwitcher.get_children()[0].look_at(cursor_pos+Vector3.UP*0.7,Vector3.UP)


func run(delta):
	var move_direction = Vector3()
	var camera_basis = camera.get_global_transform().basis
	
	if Input.is_action_pressed("up"):
		move_direction -= camera_basis.z
	elif Input.is_action_pressed("down"):
		move_direction += camera_basis.z
	if Input.is_action_pressed("left"):
		move_direction -= camera_basis.x
	elif Input.is_action_pressed("right"):
		move_direction += camera_basis.x
		
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	if move_direction:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	
	vel += move_direction*speed*delta

func take_damage(damage):
	resources.take_damage(damage)
