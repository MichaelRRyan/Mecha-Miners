extends Node

var num_players = 8
var bus = "master"

var available = []  # The available players.
var available_2d = []  # The available 2D players.
var queue = []  # The queue of sounds to play.
var queue_2d = []  # The queue of sounds to play.


# -----------------------------------------------------------------------------
func play(sound_path):
	queue.append(sound_path)
	_check_queue()


# -----------------------------------------------------------------------------
func play_2d(sound_path, sound_position : Vector2):
	queue_2d.append({ 
		"path": sound_path,
		"position": sound_position,
	})
	_check_2d_queue()


# -----------------------------------------------------------------------------
func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus
		
		p = AudioStreamPlayer2D.new()
		add_child(p)
		available_2d.append(p)
		p.connect("finished", self, "_on_2d_stream_finished", [p])
		p.bus = bus


# -----------------------------------------------------------------------------
func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)
	_check_queue()


# -----------------------------------------------------------------------------
func _on_2d_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available_2d.append(stream)
	_check_2d_queue()


# -----------------------------------------------------------------------------
func _check_queue():
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()


# -----------------------------------------------------------------------------
func _check_2d_queue():
	# Play a queued sound if any 2d players are available.
	if not queue_2d.empty() and not available_2d.empty():
		var sound = queue_2d.pop_front()
		var player = available_2d.pop_front()
		player.stream = load(sound["path"])
		player.global_position = sound["position"]
		player.max_distance = 250.0
		player.play()


# -----------------------------------------------------------------------------
