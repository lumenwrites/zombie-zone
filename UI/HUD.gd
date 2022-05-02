extends CanvasLayer

var score = 0

func _ready():
	$Score.text = str(score)

func activate_cooldown(slot_id, cooldown_length):
	$Slots.get_children()[slot_id].activate_cooldown(cooldown_length)

func update_healthbar(current_value):
	$HealthBar.value = current_value

func update_armorbar(current_value):
	$ArmorBar.value = current_value
	
func activate_slot(slot_id):
	for i in $Slots.get_children().size():
		var is_active = i == slot_id
		$Slots.get_children()[i].set_active(is_active)


func update_slots(weapons):
	for i in weapons.size():
		var slot = $Slots.get_children()[i]
		slot.get_node("Icon").texture = weapons[i]["icon"]
		var ammo_text = ""
		if weapons[i].has("ammo"):
			ammo_text = str(weapons[i]["ammo"])
		if weapons[i].has("clip_ammo"):
			ammo_text = str(weapons[i]["clip_ammo"]) + " " + str(weapons[i]["ammo"]) 
		slot.get_node("Ammo").text = ammo_text

func show_tooltip(text):
	$Tooltip.show()
	$Tooltip.text = text

func hide_tooltip():
	$Tooltip.hide()

func pain_effect():
	$PainEffect.modulate.a = 1

func _physics_process(delta):
	$PainEffect.modulate.a = lerp($PainEffect.modulate.a,0,1*delta)

func increment_score():
	score += 1
	$Score.text = str(score)
	if score > Save.save_data["high_score"]:
		Save.save_data["high_score"] += score
		Save.save_data()
