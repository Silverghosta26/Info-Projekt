extends Camera2D

@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("zoom") and player.velocity.length() == 0:
			zoom = Vector2(3,3)
	else:
		zoom = Vector2(4,4)
