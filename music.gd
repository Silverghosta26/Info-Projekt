extends AudioStreamPlayer2D

var music_bus := AudioServer.get_bus_index("music")

func set_music_level(step: float):
	var percent := step / 100.0

	# 🔁 invertieren (WICHTIG!)
	percent = clamp(percent, 0.0, 1.0)
	percent = lerp(0.0, 1.0, percent) # optional nur Klarheit

	var db := linear_to_db(percent)

	AudioServer.set_bus_volume_db(music_bus, db)
