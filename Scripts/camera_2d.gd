extends Camera2D

@onready var player: CharacterBody2D = $".."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("zoom") and player.velocity.length() == 0:
			zoom = Vector2(1,1)
	else:
		zoom = Vector2(2.5,2.5)
