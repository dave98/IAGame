extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 25 # Fuerza de caida
const MAX_SPEED = 400 # Maxima velocidad que se puede alcanzar corriendo de forma normal
const RUN_SPEED = 300 # Velocidad adicional al sprintar
const ACCELERATION = 50 # Aceleracion obtenida al sprintar
const JUMP_HIGH = -600 # Potencia del salto
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

const FIREBALL = preload("res://SecondaryScenes/Distance_Attacks/Fireball.tscn")

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
	#$Tween.interpolate_property($"Effect", "cutoff", 0.0, 1.0, 2.0, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	#$Tween.start()

func _physics_process(delta): #Funcion para el desarrollo de procesos fisicos
	#Updating Health
	$SaludBar.value = self.salud
	$AmmoBar.value = self.ammo
	$NOpen.text = str(self.opens)
	$NCon.text = str(self.consc)
	$NNeu.text = str(self.neuros)
	
	#Configuracion de gravedad
	motion.y += GRAVITY
	var friction = false
	#Definiendo animación de ataque
	attack_anim = "Attack_" + str(attack_anim_number)

	if is_dead == false:
		if (attacking == false) and (is_stunt == false): #Al atacar quitamos el movimiento 
			#Configuración de movimiento en X
			if Input.is_action_pressed("ui_right"):
				if sign($PositionDistanceAttack.position.x) == -1: #Si miramos a la izquierda cambiamos la direccion del ataque a distancia a la derecha
					self.numero_direcciones += 1 #-----------> BEHAVIOR <------------
					$PositionDistanceAttack.position.x *= -1
					$RayCastBalancingUp.position.x *= -1 #Aprovechamos para cambiar la direccion de los RayCast de deslizamiento
					$RayCastBalancingDown.position.x *= -1
					$RayCastBalancingUp.set_cast_to(sliding_cast_to_detection_1)
					$RayCastBalancingDown.set_cast_to(sliding_cast_to_detection_2)
					
				
				if Input.is_key_pressed(KEY_X): #Estamos corriendo
					if is_on_floor():
						self.tiempo_corriendo += delta # -----------> BEHAVIOR <------------
						motion.x = min(motion.x + ACCELERATION + RUN_SPEED, MAX_SPEED + RUN_SPEED) #Redondea la velocidad a su maximo		
				elif Input.is_key_pressed(KEY_SHIFT):
					if is_on_floor():
						motion.x = min(motion.x + ACCELERATION/2, MAX_SPEED/2) #Redondea la velocidad a su maximo		
				else:
					motion.x = min(motion.x + ACCELERATION, MAX_SPEED) #Redondea la velocidad a su maximo
				
				$Sprite.flip_h = false # Accediendo al Sprite, falso por que la direccion del sprite coincide con la de nuestro personaje
				if is_on_wall():
					$Sprite.play("Idle")
				else:
					$Sprite.play("Run")
					
			elif Input.is_action_pressed("ui_left"): 
				if sign($PositionDistanceAttack.position.x) == 1:
					self.numero_direcciones += 1 #-----------> BEHAVIOR <------------
					$PositionDistanceAttack.position.x *= -1
					$RayCastBalancingUp.position.x *= -1 #Aprovechamos para cambiar la direccion de los RayCast de deslizamiento
					$RayCastBalancingDown.position.x *= -1
					$RayCastBalancingUp.set_cast_to(-1 * sliding_cast_to_detection_1)
					$RayCastBalancingDown.set_cast_to(-1 * sliding_cast_to_detection_2)
					
					 
				if Input.is_key_pressed(KEY_X):
					if is_on_floor():
						motion.x = max(motion.x - ACCELERATION - RUN_SPEED, - MAX_SPEED - RUN_SPEED) #Negativo porque vamos en sentido contrario			
						self.tiempo_corriendo += delta # -----------> BEHAVIOR <------------
				elif Input.is_key_pressed(KEY_SHIFT):
					if is_on_floor():
						motion.x = max(motion.x - ACCELERATION/2, - MAX_SPEED/2) #Negativo porque vamos en sentido contrario			
				else:
					motion.x = max(motion.x - ACCELERATION, -MAX_SPEED) #Negativo porque vamos en sentido contrario
					
				$Sprite.flip_h = true
		
				if is_on_wall(): #Detener animacion si colisionamos con muros
					$Sprite.play("Idle")
				else:
					$Sprite.play("Run")
							
			else:
				friction = true
				$Sprite.play("Prepare")
			
			#Configuración de movimiento en Y
			if is_on_floor():
				actual_jump_number = 0
				key_pressed_time = 0
				actual_time_between_jumps += delta
				is_sliding_in_wall = false
				
				if Input.is_action_pressed("ui_up") and actual_time_between_jumps > TIME_BEETWEN_JUMPS:
					motion.y = JUMP_HIGH
				if friction == true:
					motion.x = lerp(motion.x, 0, 0.2)  #0.2 indica el procentaje de reduccion de velocidad 
			else: #Configuracion en Y si no estamos en el aire
				actual_time_between_jumps = 0 # El tiempo entre saltos retorna a cero puesto que estamos en el aire
		
				if motion.y < 0: #Significa que estamos saltando (arriba)
					$Sprite.play("Jump")
				else: 
					$Sprite.play("Fall")
					#Configuracion de deslizamiento
					if  $RayCastBalancingUp.is_colliding() and $RayCastBalancingDown.is_colliding():
						is_sliding_in_wall = true
						actual_jump_number = -1
						if $RayCastBalancingDown.position.x < 0: #No importa cual seleccionemos, ambos raycast apuntan a la izquierda
							$Sprite.set_flip_h(false)
											
							if Input.is_action_pressed("ui_left"):
								motion.y = SLIDING_VELOCITY * 0.2
							else:
								motion.y = SLIDING_VELOCITY
							
						else: #Ambos raycast estan hacia la derecha
							$Sprite.set_flip_h(true)
											
							if Input.is_action_pressed("ui_right"):
								motion.y = SLIDING_VELOCITY * 0.2
								
							else:
								motion.y = SLIDING_VELOCITY 
							
						$Sprite.play("Sliding")
						
					elif $RayCastBalancingDown.is_colliding():
						is_sliding_in_wall = true
						actual_jump_number = -1
						
						if $RayCastBalancingDown.position.x < 0:
							$Sprite.set_flip_h(false)
						else:
							$Sprite.set_flip_h(true)
						
						motion.y = 0
						motion.x = 0
						$Sprite.play("Sliding")
						
					else:
						is_sliding_in_wall = false
	
								
				if Input.is_action_just_pressed("ui_up"):
					if actual_jump_number < JUMP_NUMBER:
						motion.y = JUMP_HIGH
						actual_jump_number += 1
				
				if Input.is_key_pressed(KEY_Z) && actual_jump_number == JUMP_NUMBER && key_pressed_time < FAST_JUMP_TIME:
					$Sprite.play("BigJump")
					if $Sprite.is_flipped_h():
						motion.x = -1000
					else:
						motion.x = 1000
					motion.y = 0
					key_pressed_time += delta
							
				if friction == true:
					motion.x = lerp(motion.x, 0, 0.05)		
		
			#Configuracion de ataque
			if is_on_floor():
				if Input.is_action_just_pressed("ui_attack"):
					self.total_golpes += 1 # -----------> BEHAVIOR <------------
					$TimerAttack.start()
					attack(delta)
					
					if $TimerAttack.time_left > 0: #Entiendase como el tiempo necesario para realizar ataques consecutivos
						attack_anim_number += 1 
					
					if attack_anim_number > ATTACK_NUMBER_VARIATIONS:
						attack_anim_number = 1
				else:
					self.tiempo_entre_golpes += delta # -----------> BEHAVIOR <------------		
						
				if Input.is_action_just_pressed("ui_attack_2"):
					if self.ammo > 0:
						self.total_disparos += 1 # -----------> BEHAVIOR <------------
						self.ammo -= 1
						distance_attack(delta)
				else:
					self.tiempo_entre_disparos += delta
	
		motion = move_and_slide(motion, UP) #De no igualarse a motion la gravedad en el objeto aumenta de forma indefinida
	else:
		destroy_player()
		wait_defade(10)

func attack(var _time):
	self.tiempo_entre_golpes -= _time # -----------> BEHAVIOR <------------
	attacking = true
	motion.x = 0
	$Sprite.play(attack_anim)
	
	if $Sprite.flip_h == false:
		self.position += Vector2(ATTACK_JUMP_SIZE, 0)
	else:
		self.position -= Vector2(ATTACK_JUMP_SIZE, 0)
	
	yield($Sprite, "animation_finished")
	attacking = false
	
func stunt_player(var stun_traslation_x, var stun_traslation_y):
	#Esta mirando a la derecha
	is_stunt = true
	$TimerStunt.start()
	$Sprite.play("Stunt")
	if $Sprite.flip_h == false:
		self.position -= Vector2(stun_traslation_x, stun_traslation_y)
	#Esta mirando a la izquierda
	else:
		self.position += Vector2(stun_traslation_x, stun_traslation_y)
	
	if apply_and_verify_damage():
		self.is_dead = true
	
#Reiniciar secuencias de ataque si el tiempo entre ataques se ha agotado
func _on_TimerAttack_timeout():
	attack_anim_number = 1
	pass # Replace with function body.

func _on_TimerStunt_timeout():
	is_stunt = false
	pass # Replace with function body.

func distance_attack(var _time):
	self.tiempo_entre_disparos -= _time # -----------> BEHAVIOR <------------
	attacking = true
	motion.x = 0
	$Sprite.play("DistanceAttack_1")
	
	#Nos aseguramos del alineamiento en relacion al sprite
	yield($Sprite, "animation_finished")

	var fireball = FIREBALL.instance()
	if sign($PositionDistanceAttack.position.x) == 1:
		fireball.set_variable_direction(1)
	else:
		fireball.set_variable_direction(-1)
					
	get_parent().add_child(fireball)
	fireball.position = $PositionDistanceAttack.global_position
	
	attacking = false
	return

func apply_and_verify_damage():
	self.vida_perdida += 1 # -----------> BEHAVIOR <------------
	self.salud -= 1
	if self.salud <= 0:
		return true
	else:	
		return false
		
func give_life():
	if(self.salud  < self.max_salud):
		self.salud += 1
	
func give_ammo():
	var n_balas = randi() % 10
	if (self.ammo + n_balas) > self.max_ammo:
		self.ammo = max_ammo
	else:
		self.ammo += n_balas
	

func destroy_player():
	$CollisionShape2D.set_disabled(true)
	$CollisionShape2D.set_rotation_degrees(90)
	#motion.y += GRAVITY
	#motion = move_and_slide(motion, UP)
	$Sprite.play("Dying")
	yield($Sprite, "animation_finished")
	pass

func wait_defade(var _time):
	var t = Timer.new()
	t.set_wait_time(_time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	#print("[Tween on]")
	#$Tween.start()
	#yield($Tween, "tween_completed")
	#self.queue_free() -> Mas que eliminar al jugador cambiamos el ambiente	

func reset_done_behaviors():
	#print("Resetenado comportamientos")
	self.tiempo_corriendo = 0 #1
	self.areas_exploradas = 0 #2
	self.total_disparos = 0 #3
	self.total_golpes = 0
	self.tiempo_entre_golpes = 0
	self.tiempo_entre_disparos = 0
	self.vida_perdida = 0
	self.numero_direcciones = 0	
	
	
