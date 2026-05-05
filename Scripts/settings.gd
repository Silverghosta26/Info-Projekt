extends Control

var menü_open = false

func _ready():
	print("geladen")
	$CenterContainer.visible = false
	$ColorRect.visible = false

func _on_zahnrad_pressed() -> void:
	print("geklickt")
	menü_open = !menü_open
	
	$CenterContainer.visible = menü_open
	$ColorRect.visible = menü_open
	
	get_tree().paused = menü_open


func _on_v_slider_value_changed(value):
	Music.set_music_level(value)


func _on_exit_pressed() -> void:
	get_tree().quit()



func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
