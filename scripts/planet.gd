extends Node2D

@export var v0: Vector2
@export var acc: Vector2
@export var x_prev: Vector2
@export var x_current: Vector2 

var first_step = true

@export var player: AudioStreamPlayer2D
@export var is_playing = false
var pd: AudioStreamPD

var f = 440.0

# TODO: use leapfrog integration to conserve momentum
func transform(vec: Vector2):
	vec *= Vector2(1, -1)
	vec += get_viewport_rect().size / 2
	return vec

func _ready() -> void:
	player = AudioStreamPlayer2D.new()
	player.volume_db = -16
	add_child(player)
	player.stream = AudioStreamPD.new()
	
	pd = player.stream
	pd.patch_path = "res://patches/planet_sound.pd"
	position = transform(x_current)
	f = randf_range(220, 880)

	player.play()

func leapforg(delta):
	if first_step:
		v0 = v0 + acc * delta
		x_current = x_current + v0 * 2 * delta
	else:
		v0 = v0 + acc * delta
	first_step = !first_step

func _physics_process(delta: float):
	leapforg(delta)	
	position = transform(x_current)

func _process(delta: float):
	var amp = exp(-x_current.length_squared()/10000)
	pd.send_float("ms", delta * 1000)
	pd.send_float("volume", amp)
	pd.send_float("freq", f)
