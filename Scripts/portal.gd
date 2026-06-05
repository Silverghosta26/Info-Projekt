extends Area2D
@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if not body.name == "Player": 
		return
	
	const level = [
		"res://scenes/level/level1.tscn",
		"res://scenes/level/level2.tscn",
		"res://scenes/level/level3.tscn",
		"res://scenes/level/level4.tscn",
		"res://scenes/level/level5.tscn",
		"res://scenes/level/level6.tscn",
		"res://scenes/level/level7.tscn"]
	
	var current_path = get_tree().current_scene.scene_file_path
	var i = level.find(current_path) +1
	
	
	if self.name == "enter":
		var exitpoint = level[i]
		await get_tree().create_timer(0.05).timeout
		body.disable_input_for(1.0)
		body.portal_animation()
		await get_tree().create_timer(0.4).timeout
		get_tree().change_scene_to_file(exitpoint)
		
	if self.name == "exit":
		animated_sprite.play("close")
		timer.start()


func _on_timer_timeout() -> void:
	queue_free()
