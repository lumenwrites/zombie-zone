extends Spatial

export(String, "Fists", "Sword", "Gun", "Shotgun", "Assault Rifle", "Sniper Rifle", "Grenade", "Mine", "Sentry", "Rocket Launcher", "Air Strike") var default_weapon = "Fists"

# To drop the weapon when I swap it for something else
onready var pickups = get_node("/root/World/Pickups")
const WEAPON_PICKUP = preload("res://Pickups/WeaponPickup.tscn")

onready var HUD = get_node("/root/World/HUD")

var active_slot = 0
var slots = [
	Constants.WEAPONS["Fists"],
	Constants.WEAPONS["Fists"],
	Constants.WEAPONS["Fists"],
	Constants.WEAPONS["Fists"],
	Constants.WEAPONS["Fists"]
#	Constants.WEAPONS["Assault Rifle"],
#	Constants.WEAPONS["Grenade"],
#	Constants.WEAPONS["Air Strike"],
#	Constants.WEAPONS["Rocket Launcher"],
#	Constants.WEAPONS["Mine"]
#	Constants.WEAPONS["Sniper Rifle"],
#	Constants.WEAPONS["Sword"],
#	Constants.WEAPONS["Gun"],
#	Constants.WEAPONS["Assault Rifle"]
]

# Can't create AudioStrimPlayer under WeaponSwitcher because I'm constantly deleting children.
onready var audio_player = $"../AudioStreamPlayer"

func _ready():
	slots[0] = Constants.WEAPONS[default_weapon].duplicate(true)
	switch_weapon()
	HUD.activate_slot(active_slot)
	HUD.update_slots(slots)

func _input(event):
	if Input.is_action_just_pressed("next_weapon"): 
		next_weapon()
	if Input.is_action_just_pressed("prev_weapon"): 
		prev_weapon()
	if Input.is_action_just_pressed("1"): activate_slot(0)
	if Input.is_action_just_pressed("2"): activate_slot(1)
	if Input.is_action_just_pressed("3"): activate_slot(2)
	if Input.is_action_just_pressed("4"): activate_slot(3)
	if Input.is_action_just_pressed("5"): activate_slot(4)

func next_weapon():
	if active_slot < slots.size()-1: active_slot += 1
	else: active_slot = 0
	HUD.activate_slot(active_slot)
	switch_weapon()

func prev_weapon():
	if active_slot > 0: active_slot -= 1
	else: active_slot = slots.size()-1
	HUD.activate_slot(active_slot)
	switch_weapon()
	
func activate_slot(slot_number):
	active_slot = slot_number
	HUD.activate_slot(active_slot)
	switch_weapon()



func pickup_weapon(weapon_drop):
	
	# If I already have a weapon of this type - extract the ammo
	for slot in slots:
		if slot["name"] == weapon_drop["name"] and slot.has("ammo"):
			# If I already have this weapon, and it's already maxed out on ammo - 
			# I do nothing, don't make the pickup disappear.
			if slot["ammo"] == slot["max_ammo"]: return false
			slot["ammo"] += weapon_drop["ammo"]
			slot["ammo"] = clamp(slot["ammo"], 0, slot["max_ammo"])
			HUD.update_slots(slots)
			return true
		var ammoless_weapons = ["Sword"]
		if weapon_drop["name"] in ammoless_weapons and slot["name"] in ammoless_weapons: 
			# If it's a sword and I already have it, I want to stop the code below from adding it to invetntory again
			return false
	
	# If there's an empty slot - put the weapon into that slot
	for slot_id in slots.size():
		if slots[slot_id]["name"] == "Fists":
			slots[slot_id] = weapon_drop.duplicate(true)
			switch_weapon()
			HUD.update_slots(slots)
			return true

func swap_weapon(weapon_drop):
	if pickup_weapon(weapon_drop): return true # Just in case I click switch when I already have the weapon, then I need to extract ammo
	# If I'm already holding a weapon - drop it so I can switch to the new one.
	var current_weapon = slots[active_slot]
	if current_weapon["name"] != "Fists":
		var instance = WEAPON_PICKUP.instance()
		# Drop the weapon slightly in front of the player
		instance.global_transform.origin = global_transform.origin - global_transform.basis.z*1.5
		# Drop the weapon from currently active slot
		instance.weapon_data = current_weapon
		pickups.add_child(instance)

	# Replace the current weapon with the one I picked up.
	slots[active_slot] = weapon_drop.duplicate(true)
	switch_weapon()
	HUD.update_slots(slots)
	
	# Returning true tells the WeaponPickup that it's okay to disappear
	return true


func pickup_ammo_box():
	var current_weapon = slots[active_slot]
	# If it's melee
	if not current_weapon.has("ammo"): return false 
	# If it can't be replenished from an ammo box (like Health Packs)
	if not current_weapon.has("pickup_ammo_amount"): return false 
	# If it's already maxed out on ammo
	if current_weapon["ammo"] == current_weapon["max_ammo"]: return false
	
	current_weapon["ammo"] += current_weapon["pickup_ammo_amount"]
	current_weapon["ammo"] = clamp(current_weapon["ammo"], 0, current_weapon["max_ammo"])
	HUD.update_slots(slots)
	return true


func switch_weapon():
	# print("WeaponSwitcher switch to weapon ", active_slot)
	for child in get_children(): child.queue_free()
	audio_player.stream = load("res://assets/sounds/switch_weapon.wav")
	audio_player.play()
	var instance = slots[active_slot]["scene"].instance()
	add_child(instance)

func get(property):
	# TODO Sometimes crashes here, when weapon is despawned
	if not slots[active_slot].has(property): return
	return slots[active_slot][property]

func set(property, value):
	slots[active_slot][property] = value
	HUD.update_slots(slots)

func spend_clip_ammo():
	if not slots[active_slot].has("clip_ammo"): return
	slots[active_slot]["clip_ammo"] -= 1
	HUD.update_slots(slots)


func spend_ammo(amount):
	if not slots[active_slot].has("ammo"): return
	slots[active_slot]["ammo"] -= amount
	slots[active_slot]["ammo"] = max(slots[active_slot]["ammo"], 0)
	# TODO: HUD.activate_cooldown(active_slot, reload_rate)

	HUD.update_slots(slots)
	remove_if_empty()

func reload():
	var current_weapon = slots[active_slot]
	if not current_weapon.has("ammo"): return
	# Take the clip size from the ammo, unless there's less than that ammo left, then take remaining ammo.
	var spend_ammo = min(current_weapon["clip_size"]-current_weapon["clip_ammo"], current_weapon["ammo"])
	current_weapon["ammo"] -= spend_ammo
	current_weapon["clip_ammo"] += spend_ammo

	HUD.update_slots(slots)
	remove_if_empty()

func remove_if_empty():
	if not slots[active_slot]["name"] in ["Grenade", "Health Pack", "Air Strike", "Mine", "Sentry"]: return
	if slots[active_slot].has("ammo") and slots[active_slot]["ammo"] > 0: return

	# Remove the weapon
	slots[active_slot] = Constants.WEAPONS["Fists"]
	switch_weapon()
	HUD.update_slots(slots)

func has_weapons():
	# If I don't have any weapons, the crate will always spawn a weapon first
	for slot in slots:
		if slot["name"] != "Fists":
			return true
	return false
