extends Area2D
@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _on_body_entered(body: Node2D) -> void:
	if self.name == "enter":
		
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/fabislv.tscn")
	if self.name == "exit":
		animated_sprite.play("close")
		timer.start()


func _on_timer_timeout() -> void:
	queue_free()
