extends Node2D

var planets = []
var forces = []
var center_of_mass
var v_max = 150
var x_max = 250
var r_min = 8
var n_particles = 8
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
	$AudioListener2D.position = center_of_mass.position
	for i in range(n_particles - 1):
		var instance = node_scene.instantiate()
		instance.is_playing = true
		instance.x = rand_vec(x_max)
		# make initial velocity perpendicular to r
		instance.v0 = Vector2(-instance.x.y, instance.x.x).normalized() * v_max * randf()
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
		poses += p.x
	last_one.x = -poses
	last_one.v0 = -velos
	planets.append(last_one)
	forces.append(Vector2(0, 0))
	add_child(last_one)

func _physics_process(_delta: float):
	for i in range(len(forces)):
		forces[i] = Vector2(0, 0)
	for i in range(len(planets)):
		for j in range(i + 1, len(planets)):
			var r: Vector2 = planets[i].x - planets[j].x
			if r.length() < r_min:
				continue
			
			forces[i] += -r * (G / r.length_squared())
			forces[j] += r * (G / r.length_squared())
	center_of_mass.x = Vector2(0, 0)
	for i in range(len(planets)):
		planets[i].acc = forces[i]
		center_of_mass.x += planets[i].x
	center_of_mass.x /= len(planets)
	$AudioListener2D.position = center_of_mass.position
