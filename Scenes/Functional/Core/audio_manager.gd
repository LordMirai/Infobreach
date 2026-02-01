extends Node
# HOW TO USE: AudioManager.play_sound(sound_name, volume, pitch_variance)
var sounds = {
	"type": preload("res://audio/type_click.wav"),
	"beep": preload("res://audio/bios_beep.wav"),
	"error": preload("res://audio/error_static.wav"),
	"success": preload("res://audio/success_chime.wav")
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_sound(sound_name: String, volume: float = 0.0, pitch_variance: float = 0.1):
	if not sounds.has(sound_name):
		print("Sound error")
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = sounds[sound_name]
	player.bus = "SFX"

	# the value we give is in db so 0 is 100%, <0 is lower volume and >0 is over 100%
	player.volume_db = volume

	player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)

	player.play()

	player.finished.connect(player.queue_free)