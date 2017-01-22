#Copyright - Jonathan Ghazarian - 2017
extends Node2D

var screen_size
const LEFT_WIDTH = 100
const RIGHT_WIDTH = 100
var score
const BASE_SPEED = 25
const SPEED_MULTIPLIER = 1.3
var current_speed
var current_multiplier
var playing = false
#var constant_sample
#var constant_id

func _ready():
	score = 0
	screen_size = get_viewport_rect().size
	current_speed = BASE_SPEED
	current_multiplier = 2.72
	set_process(true)
	set_process_input(true)
	
func startGame():
	score = 0
	current_multiplier = 2.72
	var left_pos = get_node("left").get_pos()
	var right_pos = get_node("right").get_pos()
	left_pos.x = 0
	right_pos.x = screen_size.x
	get_node("left").set_pos(left_pos)
	get_node("right").set_pos(right_pos)
	get_node("Control/Button").set_hidden(true)
	playing = true
	get_node("Control/GameOverLabel").set_hidden(true)
	get_node("StreamPlayer").play()
	#get_node("StreamPlayer").set_volume(1.0)
	#var constant_sample = get_node("SamplePlayer").get_sample_library().get_sample("constant1").get_rid()
	#AudioServer.voice_play(AudioServer.voice_create(), constant_sample)
	#constant_id = get_node("SamplePlayer").play("constant2")

func endGame():
	playing = false
	get_node("Control/Button").set_text("Replay")
	get_node("Control/Button").set_hidden(false)
	get_node("end_explosion").set_emitting(true)
	get_node("Control/GameOverLabel").set_hidden(false)
	#get_node("SamplePlayer").stop(constant_id)
	get_node("SamplePlayer").play("explosion")
	get_node("StreamPlayer").stop()

func _input(event):
	var left_pos = get_node("left").get_pos()
	var right_pos = get_node("right").get_pos()
	if ((event.is_action_pressed("hit_left") or (event.type == InputEvent.SCREEN_TOUCH and event.pressed == true)) and not event.is_echo()):
		if (left_pos.x < 0):
			endGame()
		else:
			left_pos.x = -randf() * 100
			current_multiplier *= SPEED_MULTIPLIER
			current_speed = log(current_multiplier) * BASE_SPEED
			get_node("left").set_pos(left_pos)
	if (event.is_action_pressed("hit_right") and not event.is_echo()):
		if (right_pos.x > screen_size.x):
			endGame()
		else:
			right_pos.x = (randf() * 100) + screen_size.x
			current_multiplier *= SPEED_MULTIPLIER
			current_speed = log(current_multiplier) * BASE_SPEED
			get_node("right").set_pos(right_pos)
	if (event.is_action_pressed("start_game")):
		startGame()

func _process(delta):
	var left_pos = get_node("left").get_pos()
	var right_pos = get_node("right").get_pos()
	
	if ( playing ):
		left_pos.x += randf() * current_speed * delta
		right_pos.x -= randf() * current_speed * delta
		
		var left_edge = left_pos.x
		var right_edge = right_pos.x
		if (left_edge > right_edge):
			endGame()
		
		if ( playing ):
			get_node("left").set_pos(left_pos)
			get_node("right").set_pos(right_pos)
		
		score += 1 * delta
		get_node("Control/ScoreLabel").set_text(str(score).pad_decimals(1))
		var distance = get_node("right").get_pos().x - get_node("left").get_pos().x
		var volume = max(0.12, min(55.0 / distance, 1.0))
		get_node("StreamPlayer").set_volume(volume)
		#get_node("SamplePlayer").set_volume(constant_id, volume)

func _on_Button_pressed():
	startGame()
