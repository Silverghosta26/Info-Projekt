extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var tilemap = get_tree().current_scene.find_child("tiles", true, false)

# eingabe für ice tiles
var ice_tiles = [
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(7, 1),
	Vector2i(6,2)
]

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")


	# flip sprite depending on direction
	if direction > 0:
		animated_sprite_2d.flip_h = false
		
	if direction < 0:
		animated_sprite_2d.flip_h = true


	# play animations
	if is_on_floor():
		if direction ==0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")


	# movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	check_tile_below()
	
func check_tile_below():
	var left = global_position + Vector2(-7, 16)
	var right = global_position + Vector2(7, 16)

	var cell_left = tilemap.local_to_map(tilemap.to_local(left))
	var cell_right = tilemap.local_to_map(tilemap.to_local(right))

	var tile_left = tilemap.get_cell_source_id(cell_left)
	var tile_right = tilemap.get_cell_source_id(cell_right)

	if tile_left != -1 or tile_right != -1:
		#print("Auf Boden")
		pass
		# 👉 Infos holen (linke Seite als Beispiel)
	if tile_left != -1:
		var atlas = tilemap.get_cell_atlas_coords(cell_left)
		handle_tile(tile_left, atlas)

	if tile_right != -1:
		var atlas = tilemap.get_cell_atlas_coords(cell_right)
		handle_tile(tile_right, atlas)

	else:
		print("In der Luft")


func handle_tile(tile_id, atlas_coords):
	# Beispiel: Lava Tile
	if atlas_coords in ice_tiles:
		print("Spieler steht auf Eis")
		

	# Beispiel: Gras Tile
	elif atlas_coords == Vector2i(0, 0):
		print("Gras")
