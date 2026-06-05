extends Control

@onready var confdialog: ConfirmationDialog = $CenterContainer/ConfirmationDialog
@onready var vslider: VSlider = $CenterContainer/Panel/VSlider

var menü_open = false

var difdialog = 0

func _ready():
	vslider.value = 100
	$CenterContainer.visible = false
	$ColorRect.visible = false

func _on_zahnrad_pressed() -> void:
	menü_open = !menü_open
	update()
	
func update():
	$CenterContainer.visible = menü_open
	$ColorRect.visible = menü_open
	
	get_tree().paused = menü_open


func _on_v_slider_value_changed(value):
	Music.set_music_level(value)


func _on_exit_pressed() -> void:
	confdialog.dialog_text = "Do you really want to close the game?"
	confdialog.popup_centered()
	difdialog = 1


func _on_restart_pressed() -> void:
	confdialog.dialog_text = "Do you really want to reset all your progress?"
	confdialog.popup_centered()
	difdialog = 2

func _on_confirmation_dialog_confirmed() -> void:
	if difdialog == 1:
		get_tree().quit()
	elif difdialog == 2:
		get_tree().change_scene_to_file("res://scenes/ui etc/start.tscn")
		menü_open = false
		update()
		
