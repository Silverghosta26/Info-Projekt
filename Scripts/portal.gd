extends Area2D
@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_tree().current_scene.find_child("Player", true, false)


func _on_body_entered(body: Node2D) -> void:
	if not body.name == "Player": 
		return
	
	const level = ["res://scenes/game.tscn","res://scenes/fabislv.tscn","res://scenes/lorenzlv.tscn"]
	
	var current_path = get_tree().current_scene.scene_file_path
	var i = level.find(current_path) +1
	
	
	if self.name == "enter":
		var exitpoint = level[i]
		player.disable_input_for(1.0)
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(exitpoint)
	if self.name == "exit":
		animated_sprite.play("close")
		timer.start()


func _on_timer_timeout() -> void:
	queue_free()
