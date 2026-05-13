extends PhysicsEntity

const ENEMY_SPEED = 60.0
var direction = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rayright: RayCast2D = $rayright
@onready var rayleft: RayCast2D = $rayleft

func _physics_process(delta: float) -> void:
	if not rayright or not rayleft:
		return

	# 1. Richtung bestimmen
	if rayright.is_colliding():direction = -1
	elif rayleft.is_colliding():
		direction = 1

	# 2. Input-Vektor für die Basis-Klasse simulieren
	var input_dir = Vector2(direction, 0)
	
	# Da ein einfacher Enemy nicht springt, setzen wir wants_to_jump auf false
	# Wir überschreiben kurz die SPEED der Basis-Klasse mit der ENEMY_SPEED
	var original_speed = SPEED 
	# (Hinweis: Da SPEED in der Basis eine const ist, nutzen wir hier 
	# ENEMY_SPEED direkt im Aufruf oder passen die Basis an)
	
	# 3. Physik anwenden (Schwerkraft, Tiles, Bewegung)
	# Wir übergeben einen modifizierten Geschwindigkeits-Vektor
	apply_physics_custom(delta, input_dir)

	# 4. Animation / Sprite Flip
	animated_sprite.flip_h = (direction == -1)
	animated_sprite.play("run") # Oder wie deine Animation heißt

# Hilfsfunktion, falls du die Geschwindigkeit des Gegners anpassen willst
func apply_physics_custom(delta, input_dir):
	update_timers(delta, false)
	apply_gravity(delta)
	
	# Bewegung berechnen (vereinfacht für Enemy ohne Beschleunigungs-Logik)
	# Wenn du die Reibung/Beschleunigung der Basis willst, nutze apply_physics
	velocity.x = input_dir.x * ENEMY_SPEED
	
	move_and_slide()
	update_tile_state()
	handle_water_exit()
