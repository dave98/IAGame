extends AnimatedSprite

# Declare member variables here. Examples:
const STEPS_MINIMAL_TIME = 0.05
const STEPS_PITCH_SCALE = 0.5
const STEPS_VOLUME_sCALE = -25

var step_version = randi() % 10 + 1 #version aleatoria de sonido
var step_sounds  #Variable de aleatoriedad entre los pasos
var step_actual_time = 0.0



# Called when the node enters the scene tree for the first time.
func _ready():
	step_sounds = AudioStreamPlayer.new()
	self.add_child(step_sounds)
	step_sounds.stream = load("res://Sounds/Effects/Character/step_mud_1.wav")
	step_sounds.set_pitch_scale(STEPS_PITCH_SCALE)
	step_sounds.set_volume_db(STEPS_VOLUME_sCALE)

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	randomize()
	step_version = randi() % 10 + 1
	step_actual_time += delta
		
	if self.get_animation() == "Run" and step_actual_time > STEPS_MINIMAL_TIME:
		step_sounds.stream = load("res://Sounds/Effects/Character/step_mud_" + str(step_version) + ".wav")
		step_actual_time = 0.0
		if self.get_frame() == 1 or self.get_frame() == 3:
			step_sounds.play()
			yield(step_sounds, "finished")
		
			
			