extends Spatial

# To drop the weapon when I swap it for something else
onready var pickups = get_node("/root/World/Pickups")
const WEAPON_PICKUP = preload("res://Pickups/WeaponPickup.tscn")

onready var HUD = get_node("/root/World/HUD")

var active_slot = 0
var slots = [
	Constants.WEAPONS["Fists"].duplicate(true) # Set by Bot when it's ready, because it's _ready after WeaponSwitcher is.
]

# Can't create AudioStrimPlayer under WeaponSwitcher because I'm constantly deleting children.
onready var audio_player = $"../AudioStreamPlayer3D"


func switch_weapon():
	# print("WeaponSwitcher switch to weapon ", active_slot)
	for child in get_children(): child.queue_free()
	audio_player.stream = load("res://assets/sounds/switch_weapon.wav")
	audio_player.play()
	var instance = slots[active_slot]["scene"].instance()
	add_child(instance)

func drop_weapon():
	var current_weapon = slots[active_slot]
	if not current_weapon["name"] in ["Fists", "Zombie Fists"]:
		var instance = WEAPON_PICKUP.instance()
		# Drop the weapon slightly in front of the player
		instance.global_transform.origin = global_transform.origin - global_transform.basis.z*1.5
		# Drop the weapon from currently active slot
		instance.weapon_data = current_weapon
		pickups.add_child(instance)

func get(property):
	# TODO Sometimes crashes here
	return slots[active_slot][property]

func set(property, value):
	slots[active_slot][property] = value

func spend_clip_ammo():
	return
	slots[active_slot]["clip_ammo"] -= 1
	
func reload():
	pass

func spend_ammo(amount):
	# I don't want bots to run out of ammo when they reload the weapon
	pass
