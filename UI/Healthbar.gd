extends Sprite3D

export var max_health = 100.0
var current_health

const HEALTH_PICKUP = preload("res://Environment/HealthPickup.tscn")

onready var progress_bar = $Viewport/ProgressBar
onready var EnemyNode = get_parent()

func _ready():
	texture = $Viewport.get_texture()
	current_health = max_health
	
func take_damage(damage):
	current_health -= damage
	update_progressbar(current_health, max_health)
	if current_health <= 0:
		die()

func update_progressbar(current_value, max_value):
	progress_bar.value = current_value * 100/max_value

func die():
	if not EnemyNode.can_die: return
	if EnemyNode.health_drop_probability > randf():
		spawn_health(EnemyNode.health_drop_amount)
	get_parent().queue_free()

func spawn_health(amount):
	var instance = HEALTH_PICKUP.instance()
	var scene_root = get_node("/root/World")
	instance.global_transform = get_parent().global_transform
	instance.amount = amount
	scene_root.add_child(instance)
