extends Node2D

var v0: Vector2
var acc: Vector2
var x: Vector2 

var first_step = true

var player: AudioStreamPlayer2D
var is_playing = false

var pd: AudioStreamPD
var f = 440.0

func transform(vec: Vector2):
	vec *= Vector2(1, -1)
	vec += get_viewport_rect().size / 2
	return vec

func _ready() -> void:
	player = $AudioStreamPlayer2D
	player.volume_db = -16
	player.stream = AudioStreamPD.new()
	
	pd = player.stream
	pd.patch_path = "res://patches/planet_sound.pd"
	position = transform(x)
	f = randf_range(220, 880)

	player.play()

# TODO: use leapfrog integration to conserve momentum
func leapforg(delta):
	if first_step:
		v0 = v0 + acc * delta
		x = x + v0 * 2 * delta
	else:
		v0 = v0 + acc * delta
	first_step = !first_step

func _physics_process(delta: float):
	leapforg(delta)	
	position = transform(x)

func _process(delta: float):
	pd.send_float("ms", delta * 1000)
	pd.send_float("volume", 1.0)
	pd.send_float("freq", f)
