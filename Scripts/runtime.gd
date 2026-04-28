extends Label
@onready var timer: Timer = $Timer

var gamestart := 0

func _on_timer_timeout() -> void:
	gamestart += 1
	text = "playing for " + str(gamestart)
