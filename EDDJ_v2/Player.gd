extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 25 # Fuerza de caida
const MAX_SPEED = 250 # Maxima velocidad que se puede alcanzar corriendo de forma normal
const RUN_SPEED = 150 # Velocidad adicional al sprintar
const ACCELERATION = 10 # Aceleracion obtenida al sprintar
const JUMP_HIGH = -600 # Potencia del salto
const JUMP_MEGA = -800
const SLIDING_VELOCITY = 200 #Velocidad de caida durante sliding
const SLIDING_PRESSED_FACTOR = 0.2  #La caida en sliding se hace más lento si el usuario presiona contra la pared. Factor multiplicativo
const SMOOTH = 0.2 #Valor de deslize
const JUMP_NUMBER = 0 # Numeros de saltos en el aire
const FAST_JUMP_TIME = 0.3 #Duracion del salto largo en el aire
const TIME_BEETWEN_JUMPS = 0.1 #Tiempo que tiene que pasar para realizar un nuevo salto
const ATTACK_JUMP_SIZE = 40 #Defina la distancia que se avanza al hacer un ataque
const ATTACK_NUMBER_VARIATIONS = 4
const STUNT_TIME = 0.5
const STUN_TRASLATION = 2
const REVERSE_FORCE = -400 # Fuerza opuesta tras saltar sobre un objetivo
const SUPER_REVERSE_FORCE = -700

var motion = Vector2() #Direccion de movimiento del sujeto
var past_position = Vector2() # Recuerda la ultima posicion del sujeto
var actual_jump_number = 0  # Numero actual de rebote en el aire
var key_pressed_time = 0.00 #Utilizado en el salto largo, controla el tiempo de dicho salto
var actual_time_between_jumps = 0.00 #Tiempo transcurrido desde el ultimo salto
var sliding_cast_to_detection_1 = Vector2(20, 0) #Rango de deteccion para hacer el Sliding
var sliding_cast_to_detection_2 = Vector2(15, 0)

var attacking = false
var attack_anim = null
var attack_anim_number = 1
var is_dead = false 
var is_sliding_in_wall = false
var is_stunt = false
var is_running = false
var killing = true


var state = 1
var process_state = ""
var is_changind_state = 0
var is_invulnerable = false # Util cuando estamos en medio de una tranformación
var invulnarivility_time = 3 # Tiempo total de invulnaravilidad
var invulnaribility_defade = 0.3 # Porcentaje de valor previo para avisarle al jugador que la invulnaribilidad se acaba
var invulnaribility_defade_1 = 0.15
var next_change = true


#Renovables
var max_salud = 30
var salud = 10
var ammo = 20
var max_ammo = 50

var opens = 0.0
var consc = 0.0
var neuros = 0.0


#Behavior data
var tiempo_corriendo = 0 #1
var areas_exploradas = 0 #2
var total_disparos = 0 #3
#var disparos_acertados = 0
var total_golpes = 0
#var golpes_acertados = 0
var tiempo_entre_golpes = 0
var tiempo_entre_disparos = 0
#var curas_recogidas = 0
#var vida_curas = 0	
#var municion_recogida = 0
#var vida_municion = 0
var vida_perdida = 0
var numero_direcciones = 0	
	
func _ready():
	past_position = position #Guardamos la primera posicion 
	self.process_state = "_" + String(self.state)
	#$Tween.interpolate_property($"Effect", "cutoff", 0.0, 1.0, 2.0, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	#$Tween.start()

func _physics_process(delta): #Funcion para el desarrollo de procesos fisicos
	#Updating Health
	#Configuracion de gravedad
	motion.y += GRAVITY
	var friction = false
	#Definiendo animación de ataque

	if is_dead == false and self.is_changind_state == 0:
		if (attacking == false) and (is_stunt == false): #Al atacar quitamos el movimiento 
			#Configuración de movimiento en X
			if Input.is_action_pressed("ui_right"):
				#if sign($PositionDistanceAttack.position.x) == -1: #Si miramos a la izquierda cambiamos la direccion del ataque a distancia a la derecha
					#self.numero_direcciones += 1 #-----------> BEHAVIOR <------------
					#$PositionDistanceAttack.position.x *= -1
					#$RayCastBalancingUp.position.x *= -1 #Aprovechamos para cambiar la direccion de los RayCast de deslizamiento
					#$RayCastBalancingDown.position.x *= -1
					#$RayCastBalancingUp.set_cast_to(sliding_cast_to_detection_1)
					#$RayCastBalancingDown.set_cast_to(sliding_cast_to_detection_2)
					
				
				if Input.is_key_pressed(KEY_X): #Estamos corriendo
					if is_on_floor():
						self.is_running = true
						self.tiempo_corriendo += delta # -----------> BEHAVIOR <------------
						motion.x = min(motion.x + ACCELERATION + RUN_SPEED, MAX_SPEED + RUN_SPEED) #Redondea la velocidad a su maximo		
				elif Input.is_key_pressed(KEY_SHIFT):
					if is_on_floor():
						self.is_running = false
						motion.x = min(motion.x + ACCELERATION/2, MAX_SPEED/2) #Redondea la velocidad a su maximo		
				else:
					self.is_running = false
					motion.x = min(motion.x + ACCELERATION, MAX_SPEED) #Redondea la velocidad a su maximo
				$Sprite.flip_h = false # Accediendo al Sprite, falso por que la direccion del sprite coincide con la de nuestro personaje
				if is_on_wall():
					#$Sprite.play("Idle")
					$Sprite.play("mario_idle" + self.process_state)
				else:
					#$Sprite.play("Run")
					if self.is_running:
						$Sprite.play("mario_run" + self.process_state)
					else:
						$Sprite.play("mario_walk" + self.process_state)
					
			elif Input.is_action_pressed("ui_left"): 
				#if sign($PositionDistanceAttack.position.x) == 1:
				#	self.numero_direcciones += 1 #-----------> BEHAVIOR <------------
				#	$PositionDistanceAttack.position.x *= -1
				#	$RayCastBalancingUp.position.x *= -1 #Aprovechamos para cambiar la direccion de los RayCast de deslizamiento
				#	$RayCastBalancingDown.position.x *= -1
				#	$RayCastBalancingUp.set_cast_to(-1 * sliding_cast_to_detection_1)
				#	$RayCastBalancingDown.set_cast_to(-1 * sliding_cast_to_detection_2)
					
					 
				if Input.is_key_pressed(KEY_X):
					if is_on_floor():
						self.is_running = true
						motion.x = max(motion.x - ACCELERATION - RUN_SPEED, - MAX_SPEED - RUN_SPEED) #Negativo porque vamos en sentido contrario			
						self.tiempo_corriendo += delta # -----------> BEHAVIOR <------------
				elif Input.is_key_pressed(KEY_SHIFT):
					if is_on_floor():
						self.is_running = false
						motion.x = max(motion.x - ACCELERATION/2, - MAX_SPEED/2) #Negativo porque vamos en sentido contrario			
				else:
					self.is_running = false
					motion.x = max(motion.x - ACCELERATION, -MAX_SPEED) #Negativo porque vamos en sentido contrario
					
				$Sprite.flip_h = true
		
				if is_on_wall(): #Detener animacion si colisionamos con muros
					$Sprite.play("mario_idle" + self.process_state)
				else:
					if self.is_running:
						$Sprite.play("mario_run" + self.process_state)
					else:
						$Sprite.play("mario_walk" + self.process_state)
							
			else:
				friction = true
				$Sprite.play("mario_idle" + self.process_state)
			
			#Configuración de movimiento en Y
			if is_on_floor():
				#actual_jump_number = 0
				#key_pressed_time = 0
				#actual_time_between_jumps += delta
				#is_sliding_in_wall = false
				
				#if Input.is_action_pressed("ui_up") and actual_time_between_jumps > TIME_BEETWEN_JUMPS:
				if Input.is_action_just_pressed("ui_up"):
					$Sounds/Jump.play()
					if self.is_running:
						motion.y = JUMP_MEGA
					else:	
						motion.y = JUMP_HIGH
				if friction == true:
					motion.x = lerp(motion.x, 0, 0.2)  #0.2 indica el procentaje de reduccion de velocidad 
			else: #Configuracion en Y si no estamos en el aire
				#actual_time_between_jumps = 0 # El tiempo entre saltos retorna a cero puesto que estamos en el aire
				if motion.y < 0: #Significa que estamos saltando (arriba)
					if self.is_running:
						$Sprite.play("mario_sjump" + self.process_state)
					else:
						$Sprite.play("mario_jump" + self.process_state)
				else: 
					$Sprite.play("mario_fall" + self.process_state)
					#Configuracion de deslizamiento
					#if  $RayCastBalancingUp.is_colliding() and $RayCastBalancingDown.is_colliding():
					#	is_sliding_in_wall = true
					#	actual_jump_number = -1
					#	if $RayCastBalancingDown.position.x < 0: #No importa cual seleccionemos, ambos raycast apuntan a la izquierda
					#		$Sprite.set_flip_h(false)
											
					#		if Input.is_action_pressed("ui_left"):
					#			motion.y = SLIDING_VELOCITY * 0.2
					#		else:
					#			motion.y = SLIDING_VELOCITY
							
					#	else: #Ambos raycast estan hacia la derecha
					#		$Sprite.set_flip_h(true)
					#						
					#		if Input.is_action_pressed("ui_right"):
					#			motion.y = SLIDING_VELOCITY * 0.2
					#			
					#		else:
					#			motion.y = SLIDING_VELOCITY 
							
					#	$Sprite.play("mario_idle_1")
						
					#elif $RayCastBalancingDown.is_colliding():
					#	is_sliding_in_wall = true
					#	actual_jump_number = -1
						
					#	if $RayCastBalancingDown.position.x < 0:
					#		$Sprite.set_flip_h(false)
					#	else:
					#		$Sprite.set_flip_h(true)
						
					#	motion.y = 0
					#	motion.x = 0
					#	$Sprite.play("mario_idle_1")
						
					#else:
					#	is_sliding_in_wall = false
	
								
				#if Input.is_action_just_pressed("ui_up"):
				#	if actual_jump_number < JUMP_NUMBER:
				#		motion.y = JUMP_HIGH
				#		actual_jump_number += 1
				
				#if Input.is_key_pressed(KEY_Z) && actual_jump_number == JUMP_NUMBER && key_pressed_time < FAST_JUMP_TIME:
				#	$Sprite.play("BigJump")
				#	if $Sprite.is_flipped_h():
				#		motion.x = -1000
				#	else:
				#		motion.x = 1000
				#	motion.y = 0
				#	key_pressed_time += delta
							
				if friction == true:
					motion.x = lerp(motion.x, 0, 0.05)		
		
			#Configuracion de ataque
			#if is_on_floor():
			#	if Input.is_action_just_pressed("ui_attack"):
			#		self.total_golpes += 1 # -----------> BEHAVIOR <------------
			#		$TimerAttack.start()
			#		attack(delta)
			#		
			#		if $TimerAttack.time_left > 0: #Entiendase como el tiempo necesario para realizar ataques consecutivos
			#			attack_anim_number += 1 
			#		
			#		if attack_anim_number > ATTACK_NUMBER_VARIATIONS:
			#			attack_anim_number = 1
			#	else:
			#		self.tiempo_entre_golpes += delta # -----------> BEHAVIOR <------------		
			#			
			#	if Input.is_action_just_pressed("ui_attack_2"):
			#		if self.ammo > 0:
			#			self.total_disparos += 1 # -----------> BEHAVIOR <------------
			#			self.ammo -= 1
			#			distance_attack(delta)
			#	else:
			#		self.tiempo_entre_disparos += delta
	
		motion = move_and_slide(motion, UP) #De no igualarse a motion la gravedad en el objeto aumenta de forma indefinida
	else:
		if self.is_changind_state != 0:
			pass

		else:
			destroy_player()
			wait_defade(5)


		
func reverse_force(var direction, var reverse_type = 1):
	if reverse_type == 1:
		$Sounds/Stomp.play()
	elif reverse_type == 2:
		$Sounds/Stomp_2.play()
	elif reverse_type == 3:
		$Sounds/Stomp_3.play()
		
	if Input.is_action_pressed("ui_up") or direction == 2:
		self.motion.y = SUPER_REVERSE_FORCE
	else:
		self.motion.y = REVERSE_FORCE
	pass
			
######## --------------------------------------------------------------- ######
######## --------------------------------------------------------------- ######
######## --------------------------------------------------------------- ######

func set_new_state(var _state):
	self.state = _state
	self.process_state = "_" + String(self.state)

# Logica y efectos al darle power up a mario
func set_power_up(var _type): # 1 is actual so dont exists, 2 for mushroms, 3 for flowers and 4 for feathers
	if _type == 2:
		if self.state == 2:
			$Sounds/SamePowerUp.play()
		else:
			self.is_changind_state = 1
			self.position += Vector2(0, -10)
			$Sounds/PowerUp.play()
			$CollisionShape2D.set_disabled(true)
			$CollisionShape2D2.set_disabled(false)

			$Sprite.play("mario_grow")
			yield($Sprite, "animation_finished")
			self.set_new_state(_type)
			self.activate_invulnerabilty()
			self.is_changind_state = 0
		pass

# La configuracion del como se hace los power ya esta hecho
func delete_power_up(var _type):  # 1 is normal_state so dont exists, 2 for mushroms (from flowers and feathers we go to mushrom)
	if _type == 1:
		self.is_changind_state = 1
		self.position += Vector2(0, -10)
		$Sounds/LostPowerUp.play()
		$CollisionShape2D.set_disabled(false)
		$CollisionShape2D2.set_disabled(true)
		
		self.set_new_state(_type)
		$Sprite.play("mario_dwarf")
		yield($Sprite, "animation_finished")
		self.activate_invulnerabilty()
		self.is_changind_state = 0
	pass

func level_ended(path):
	self.is_changind_state = 1
	$Sounds/Ambiance.stop()
	$Sounds/LevelEnded.play()
	yield($Sounds/LevelEnded, "finished")
	SceneChanger.change_scene(path)
	
func live_up():
	$Sounds/LiveUp.play()
	Global.add_lives()

# Logica para la muerte de mario
func kill_player():
	if not self.is_invulnerable and not bool(self.is_changind_state):
		if self.state != 1:
			if self.state == 2:
				self.delete_power_up(1)
		else:
			self.is_dead = true

func destroy_player():
	self.is_dead = true
	$CollisionShape2D.set_disabled(true)
	$CollisionShape2D2.set_disabled(true)
	#$CollisionShape2D.set_rotation_degrees(90)
	if self.killing:
		$Sounds/Ambiance.stop()
		$Sounds/Lost.play()
		self.motion = Vector2(0, -800)
		self.killing = false
	else:
		self.motion.y += (GRAVITY/8)
		self.motion = move_and_slide(self.motion, UP)
	#motion.y += GRAVITY
	#motion = move_and_slide(motion, UP)
		$Sprite.play("mario_death")
	#yield($Sprite, "animation_finished")
	pass

func activate_invulnerabilty():
	$AnimationPlayer.set_speed_scale(1)

	var d_t1 = self.invulnarivility_time
	var d_t2 = d_t1 * self.invulnaribility_defade
	var d_t3 = d_t1 * self.invulnaribility_defade_1
	d_t1 -= (d_t2+d_t3)
	
	self.is_invulnerable = true
	$AnimationPlayer.play("Parpadear")
	$TimerInvulnerability.set_wait_time(d_t1)
	$TimerInvulnerability.start()
	
	
	yield($TimerInvulnerability, "timeout")
	$AnimationPlayer.set_speed_scale(2)
	$TimerInvulnerability.set_wait_time(d_t2)
	$TimerInvulnerability.start()
	
	
	yield($TimerInvulnerability, "timeout")
	$AnimationPlayer.set_speed_scale(4)
	$TimerInvulnerability.set_wait_time(d_t3)
	$TimerInvulnerability.start()
	
	yield($TimerInvulnerability, "timeout")	
	$AnimationPlayer.stop(true)
	$AnimationPlayer.seek(0)
	self.is_invulnerable = false

func wait_defade(var _time):
	var t = Timer.new()
	t.set_wait_time(_time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	if self.next_change:
		self.next_change = false
		var temp_lives = Global.get_lives()
		if temp_lives > 0:
			Global.take_lives()
			SceneChanger.change_scene(Global.get_actual_map())
		else:
			Global.restore_mario_properties()
			SceneChanger.change_scene("res://MarioScenes/Lost.tscn")
		
	

func _on_VisibilityNotifier2D_screen_exited():
	self.is_dead = true
	pass # Replace with function body.
