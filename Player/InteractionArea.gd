extends Area

var interactable_objects = []
var closest_object

onready var HUD = get_node("/root/World/HUD")
onready var switcher = $"../WeaponSwitcher"
onready var resources = $"../Resources"
onready var use_audio = $UseAudio

func _physics_process(delta):
	if Input.is_action_just_pressed("use"): 
		interact()

	if interactable_objects.size() == 0:
		HUD.hide_tooltip()
		return

	# Find closest object
	closest_object = interactable_objects[0]
	for object in interactable_objects:
		var dist_to_object = global_transform.origin.distance_to(object.global_transform.origin)
		var dist_to_closest_object =  global_transform.origin.distance_to(closest_object.global_transform.origin)
		if dist_to_object < dist_to_closest_object:
			closest_object = object
		
	HUD.show_tooltip("Press E to pick up " + closest_object.weapon_data["name"])

func interact():
	if not is_instance_valid(closest_object): return
	closest_object.use(get_parent())


func _on_InteractionArea_area_entered(area):
	if area.has_method("use"):
		interactable_objects.append(area)


func _on_InteractionArea_area_exited(area):
	if area.has_method("use"):
		interactable_objects.erase(area)
		if closest_object == area:
			closest_object = null
