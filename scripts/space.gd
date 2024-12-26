extends Node2D

var planets = []
var forces = []
var center_of_mass
@export var G = 30.0

# TODO: magnitude of the position vector (origin is at the center of the screen)
# will determine amplitude, direction (angle 0-2pi) will determine panning
# amplitudes and directions of velocity and acceleration will determine other
# parameters. speed = pitch for example. Or we can keep track of the winding
# number and let that together with angle determine octave and pitchclass
func rand_vec(amp):
	var vec = Vector2.from_angle(TAU * randf())
	vec = amp * randf() * vec
	return vec

func _ready() -> void:
	var node_scene = preload("res://scenes/planet.tscn")
	center_of_mass = node_scene.instantiate()
	add_child(center_of_mass)
	center_of_mass.player.stop()
	for i in range(5):
		var instance = node_scene.instantiate()
		instance.is_playing = true
		instance.x_current = rand_vec(250)
		instance.v0 = rand_vec(150 * randf())
		instance.acc = Vector2(0, 0)
		planets.append(instance)
		forces.append(Vector2(0, 0))
		add_child(instance)
	
	var last_one = node_scene.instantiate()
	last_one.is_playing = true
	var velos = Vector2(0, 0)
	var poses = Vector2(0, 0)
	for p in planets:
		velos += p.v0
		poses += p.x_current
	last_one.v0 = -velos
	last_one.x_current = -poses
	planets.append(last_one)
	forces.append(Vector2(0, 0))
	add_child(last_one)

func _physics_process(_delta: float):
	for i in range(len(forces)):
		forces[i] = Vector2(0, 0)
	for i in range(len(planets)):
		for j in range(i + 1, len(planets)):
			var r: Vector2 = planets[i].x_current - planets[j].x_current
			
			forces[i] += -r * (G / r.length_squared())
			forces[j] += r * (G / r.length_squared())
	center_of_mass.x_current = Vector2(0, 0)
	# TODO: move leapfrog or velocity verlet here
	for i in range(len(planets)):
		planets[i].acc = forces[i]
		center_of_mass.x_current += planets[i].x_current
	center_of_mass.x_current /= len(planets)
