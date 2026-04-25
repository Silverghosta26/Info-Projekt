extends Area2D

@onready var timer: Timer = $Timer
@onready var parcourspawn: Marker2D = %parcourspawn




func _on_body_entered(body: Node2D) -> void:
	if self.name == "parcour":
		print("reset parcour")
		body.global_position = parcourspawn.global_position
	else: timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
