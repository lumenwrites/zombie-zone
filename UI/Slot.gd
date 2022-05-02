extends Control

var cooldown_time = 1.0
var cooldown_timer = 0.0

func _process(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
		cooldown_timer = max(cooldown_timer, 0)
		$Cooldown.value = (cooldown_timer / cooldown_time) * 100

func activate_cooldown(cooldown_length):
	cooldown_time = cooldown_length
	cooldown_timer = cooldown_length

func set_active(active):
	if active:
		$SlotInactive.hide()
		$SlotActive.show()
	else:
		$SlotInactive.show()
		$SlotActive.hide()
