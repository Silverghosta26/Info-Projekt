extends PhysicsEntity

var input_enabled = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: CollisionShape2D = $hurtbox

#func _ready() -> void:
#var exit_tp = get_tree().current_scene.find_child("exit", true, false)
#
#if exit_tp:
#	global_position = exit_tp.global_position
		
		
func check_enemy_collisions():

	for i in range(get_slide_collision_count()):

		var col = get_slide_collision(i)
		var collider = col.get_collider()

		if collider == null:
			continue

		if collider.is_in_group("enemies"):

			var normal = col.get_normal()

			# von oben
			if normal.y < -0.5:

				velocity.y = -(velocity.y + 150)

				collider.queue_free()

			# seitlich
			else:
				die()


func _physics_process(delta: float) -> void:
	if is_alive:
		if not input_enabled: return


		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_axis("goleft", "goright")
		if watermove:
			input_dir.y = Input.get_axis("Jump", "ducken")
	
		var wants_to_jump = Input.is_action_pressed("Jump")
	
		if Input.is_action_pressed("ducken"):
			hurtbox.disabled = true
			speed_multiplier = 0.5
		else:
			hurtbox.disabled = false
			speed_multiplier = 1.0
		apply_physics(delta, input_dir, wants_to_jump)
		handle_animation(input_dir.x)
		check_enemy_stomp()
	else: animated_sprite.play("die")
func handle_animation(direction_x):
	if direction_x != 0:
		animated_sprite.flip_h = direction_x < 0
	
	var anim = "idle"
	if not is_on_floor(): anim = "jump"
	elif Input.is_action_pressed("ducken"): anim = "duck"
	elif direction_x != 0: anim = "run"
	
	animated_sprite.play(anim)

func disable_input_for(seconds: float) -> void:
	input_enabled = false
	await get_tree().create_timer(seconds).timeout
	input_enabled = true

func die():
	is_alive = false
	await get_tree().create_timer(0.4).timeout
	get_tree().reload_current_scene()

	
