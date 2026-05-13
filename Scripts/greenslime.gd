extends Area2D

const  SPEED = 60

var direction = 1
var icemult := 1

# Tile Definitionen
var ice_tiles = [
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(7, 1),
	Vector2i(6, 2)
]

var water_tiles = [
	Vector2i(4, 9),
	Vector2i(4, 10),
	Vector2i(6, 9),
	Vector2i(6, 10)
]
var spike_tiles = [
	Vector2i(12, 1)
]
var slime_tiles = [
	Vector2i(12, 0)
]
var air_1_tiles = [
	Vector2i(12, 4)
]
var tj = [
	Vector2i(13, 0)
]

const WATER_GRAVITY = 300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var rayright: RayCast2D = $rayright
@onready var rayleft: RayCast2D = $rayleft

func  _physics_process(delta: float) -> void:
	
	func update_tile_state()
	movestatic()
	playanim()



# ----------------------------
# MOVEMENT
# ----------------------------
func movestatic(): 
	if rayright.is_colliding():
		#print("collides right")
		direction = -1

	if rayleft.is_colliding():
		#print("collides left")
		direction = 1

	global_position += Vector2(direction * SPEED * icemult * delta,0)

# ----------------------------
# GRAVITY
# ----------------------------
func apply_gravity(delta):
	if watermove:
		velocity.y += WATER_GRAVITY * delta
	else:
		velocity.y += get_gravity * delta

# ----------------------------
# ANIMATION
# ----------------------------
func playanim():
	if direction == 1:
		animated_sprite.flip_h = false
	if direction == -1:
		animated_sprite.flip_h = true


# ----------------------------
# TILE SYSTEM
# ----------------------------
func update_tile_state():
	icemove = false
	watermove = false
	
	check_tiles_at_position(global_position + Vector2(0, 10)) 

	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		
		var tile_pos = collider.local_to_map(collider.to_local(collision.get_position() - collision.get_normal() * 2))
		var atlas = collider.get_cell_atlas_coords(tile_pos)
		handle_tile(atlas)
		
		
			
		


func check_tiles_at_position(pos):
	for tm in tilemaps:
		if tm == null: continue
		var cell = tm.local_to_map(tm.to_local(pos))
		var atlas = tm.get_cell_atlas_coords(cell)
		if atlas != Vector2i(-1, -1):
			handle_tile(atlas)






func handle_tile(atlas_coords):
	if atlas_coords in ice_tiles:
		icemult = 2
	else: icemult = 1
	if atlas_coords in water_tiles:
		watermove = true
	if atlas_coords in spike_tiles:
		get_tree().call_deferred("reload_current_scene")
	if atlas_coords in air_1_tiles:
		air_1 = true
	else: air_1= false
	if atlas_coords in tj:
		velocity.y = -velocity.y 