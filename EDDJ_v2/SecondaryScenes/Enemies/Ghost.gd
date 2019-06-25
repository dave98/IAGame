extends KinematicBody2D

const GRAVITY = 10 
const SPEED = 160
const FLOOR = Vector2(0, -1)
var POUNCE_VELOCITY = 700
const ATTACK_INITIAL_POSITION = Vector2(30, 15)
var start_behavior_attack = false #Inicia el modo de ataque para cualquier comportamiento
var behavior_2_attack = false #Indica si esta listo para efectuar el ataque 2
var rate_behavior_2 = 3 #Tiempo entre ataque para el behavior 2
var actual_rate_behavior2 = 0 
var ATTACK_AGAIN = true
#onready var Player = get_parent().get_parent().get_node("Player")
#Behavior_2 CONST
#TimeBehavior1
const HIT = preload("res://SecondaryScenes/Distance_Attacks/EnemyHit.tscn")
const CURA = preload("res://SecondaryScenes/SpecialAreas/Cura.tscn")
const AMMO = preload("res://SecondaryScenes/SpecialAreas/Ammo.tscn")

var velocity = Vector2()
var direction = 1
var is_dead = false
var is_stunt = false
var behavior = randi() % 4 + 1 # Existen cuatro posibles behavior para un enemigo

var behavior_1_direction_alert = false
var ray_cast_attack = Vector2(250, 0)
var ray_cast_damage = Vector2(70, 0)
 #Contador actual para el ataque
var time_alive = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	#print_tree_pretty()
	pass # Replace with function body.

#Las direcciones son un estandar
func _physics_process(delta):
	if is_dead == false:
		time_alive += delta # ----------> BEHAVIOR <--------------
		#behavior_0(delta)
		#behavior_1()
		#behavior_2(delta)
		#behavior_3(delta)
		if behavior == 0:
			behavior_0(delta)
		elif behavior == 1:
			behavior_1()
		elif behavior == 2:
			behavior_2(delta)
		else:
			behavior_3(delta)
	else:
		$CollisionShape2D.set_disabled(true)
	
##################################BEHAVIOR 0#######################################
var pounce_to = POUNCE_VELOCITY
var behavior_0_pounce_duration = 0.3
var behavior_0_pounce_duration_actual = 0
var behavior_0_disable_time = 4
var behavior_0_disable_time_actual = 0
var r_po = 0
func behavior_0(delta):
	if start_behavior_attack == false:
		behavior_0_disable_time_actual += delta
		$Sprite.play("idle")
		turn_around()
		velocity.x = 0
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)		
		if $RayCastAttack.is_colliding():
			var body = $RayCastAttack.get_collider()
			if body.get_name() == "Player" and (behavior_0_disable_time_actual > behavior_0_disable_time):
				start_behavior_attack = true
	else:
		behavior_0_disable_time_actual = 0
		behavior_0_pounce_duration_actual += delta
		$Sprite.play("pounce")
		if behavior_0_pounce_duration_actual < behavior_0_pounce_duration:
			if direction == 1:
				pounce_direction = POUNCE_VELOCITY
			else:
				pounce_direction = -POUNCE_VELOCITY
			velocity.x = pounce_direction
			var r_po = randi()%2
			r_po += 1
			r_po = r_po % 2
			if r_po == 1:
				velocity.y = -150
			velocity = move_and_slide(velocity, FLOOR)
		else:
			behavior_0_pounce_duration_actual = 0
			start_behavior_attack = false
		
###################################BEHAVIOR 1#########################################
func behavior_1(): # Comportamiento plano, Mario
	velocity.x = SPEED * direction #Definiendo la direccion del salto 
	$Sprite.play("walk")
	
	turn_around()
		
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_wall():
		direction = -direction
		$RayCastBorde.position.x *= -1 #Cambiando posicion del reycast en caso giremos el personaje
	
	if $RayCastBorde.is_colliding() == false: #Definiendo el Raycast de colision, basicamente si no hay colision cambia de direccion 
		direction = -direction
		$RayCastBorde.position.x *= -1
	
###################################BEHAVIOR 2#########################################	
func behavior_2(var _time): #Movimiento aleatorio con saltos o represiones de caídas.
	if start_behavior_attack == false:
		velocity.x = SPEED * direction
		$Sprite.play("walk")
	
		turn_around()
		if $RayCastAttack.is_colliding():
			var body = $RayCastAttack.get_collider()
			if body.get_name() == "Player":
				start_behavior_attack = true
				behavior_2_attack = true
				
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)	
		
		#COMPORTAMIENTO FRENTE A OBSTACULOS O PRECIPICIOS
		if is_on_wall():
			direction = -direction
			$RayCastBorde.position.x *= -1
		
		if $RayCastBorde.is_colliding() == false and is_on_floor(): #Definiendo el Raycast de colision, basicamente si no hay colision cambia de direccion 
			direction = -direction
			$RayCastBorde.position.x *= -1
	else:
		pounce(_time)

###################################BEHAVIOR 3#########################################	
func behavior_3(var _time): #Movimiento aleatorio con saltos o represiones de caídas.
	if start_behavior_attack == false:
		velocity.x = SPEED * direction
		$Sprite.play("walk")
	
		turn_around()
		if $RayCastAttack.is_colliding():
			var body = $RayCastAttack.get_collider()
			if body.get_name() == "Player":
				start_behavior_attack = true
				behavior_3_attack = true
				
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)	
		
		#COMPORTAMIENTO FRENTE A OBSTACULOS O PRECIPICIOS
		if is_on_wall():
			direction = -direction
			$RayCastBorde.position.x *= -1
		
		if $RayCastBorde.is_colliding() == false and is_on_floor(): #Definiendo el Raycast de colision, basicamente si no hay colision cambia de direccion 
			direction = -direction
			$RayCastBorde.position.x *= -1
	else:
		high_pounce(_time)

##############################POUNCING ON PLAYER#############################
var pounce_duration = 0.5 #El pounce dura un medio segundo
var pounce_duration_actual = 0
var pounce_direction = POUNCE_VELOCITY
var behavior_2_damage = false
var do_damage_duration = 0.3 # Tiempo que dura el ataque
var do_damage_duration_actual = 0
var behavior_2_looking = false
func pounce(var _time):
	if behavior_2_attack == true:
		turn_around()
		if direction == 1:
			pounce_direction = POUNCE_VELOCITY
		else:
			pounce_direction = -POUNCE_VELOCITY
		$Sprite.play("pounce")
		velocity.x = pounce_direction
		pounce_duration_actual += _time
		#CON AMBAS CONDICIONES DE CUMPLE LA CONDICION DEL POUNCE
		if pounce_duration_actual > pounce_duration: #Verificamos la duración del pounce
			pounce_duration_actual = 0
			behavior_2_attack = false # Desactivando el pounce 
			behavior_2_damage = false
			behavior_2_looking = true # Activando la busqueda 
		
		if $RayCastDamage.is_colliding():
			var body = $RayCastDamage.get_collider()
			if body.get_name() == "Player":
				pounce_duration_actual = pounce_duration + 1 #Suspendemos el pounce 
				behavior_2_attack = false #El pounce se detiene
				behavior_2_damage = true #Activando el ataque
				behavior_2_looking = false
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	elif behavior_2_damage == true:
		do_damage_duration_actual += _time
		do_damage(_time)
		if do_damage_duration_actual > do_damage_duration:
				do_damage_duration_actual = 0
				behavior_2_damage = false
				start_behavior_attack = false
				behavior_2_looking = false
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	elif behavior_2_looking == true:
		look_around(_time)
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	else: #No importa mucho este else es solo por defecto
		behavior_2_attack = false
		
##############################HIGH POUNCE ON PLAYER#############################
var behavior_3_attack = false
var high_pounce_duration = 0.5 #El pounce dura un medio segundo
var high_pounce_duration_actual = 0
var high_pounce_direction = POUNCE_VELOCITY
var behavior_3_damage = false
var high_do_damage_duration = 0.3 # Tiempo que dura el ataque
var high_do_damage_duration_actual = 0
var behavior_3_looking = false
var high_pounce_jump = -150
func high_pounce(var _time):
	if behavior_3_attack == true:
		turn_around()
		if direction == 1:
			high_pounce_direction = POUNCE_VELOCITY
		else:
			high_pounce_direction = -POUNCE_VELOCITY
		$Sprite.play("pounce")
		velocity.x = high_pounce_direction
		velocity.y = high_pounce_jump
		high_pounce_duration_actual += _time
		#CON AMBAS CONDICIONES DE CUMPLE LA CONDICION DEL POUNCE
		if high_pounce_duration_actual > high_pounce_duration: #Verificamos la duración del pounce
			high_pounce_duration_actual = 0
			behavior_3_attack = false # Desactivando el pounce 
			behavior_3_damage = false
			behavior_3_looking = true # Activando la busqueda 
		
		if $RayCastDamage.is_colliding():
			var body = $RayCastDamage.get_collider()
			if body.get_name() == "Player":
				high_pounce_duration_actual = high_pounce_duration + 1 #Suspendemos el pounce 
				behavior_3_attack = false #El pounce se detiene
				behavior_3_damage = true #Activando el ataque
				behavior_3_looking = false
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	elif behavior_3_damage == true:
		high_do_damage_duration_actual += _time
		do_damage(_time)
		if high_do_damage_duration_actual > high_do_damage_duration:
				high_do_damage_duration_actual = 0
				behavior_3_damage = false
				start_behavior_attack = false
				behavior_3_looking = false
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	elif behavior_3_looking == true:
		look_around(_time)
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)
	else:
		behavior_3_attack = false
###############################LOOKING PLAYER################################
var time_looking = 5
var actual_time_looking = 0
func look_around(var _time):
	if start_behavior_attack == true:
		velocity.x = 0
		actual_time_looking += _time
		$Sprite.play("looking")
		if actual_time_looking < 1:
			$Sprite.flip_h = true
		elif actual_time_looking < 1.5:
			$Sprite.flip_h = false
		elif actual_time_looking < 2:
			$Sprite.flip_h = true
		elif actual_time_looking < 3:
			$Sprite.flip_h = false
		elif actual_time_looking < 4:
			actual_time_looking = 0
			behavior_2_looking = false
			start_behavior_attack = false
		
		
################################DO DAMAGE#####################################		
func do_damage(var _time):
	velocity.x = 0 #Al atacar, la velocidad se hace cero
	$Sprite.play("attack")
	attack()
	
func turn_around():
	if direction == 1:
		$Sprite.flip_h = true
		$RayCastAttack.set_cast_to(ray_cast_attack)
		$RayCastDamage.set_cast_to(ray_cast_damage)
		$PositionAttack.position = ATTACK_INITIAL_POSITION
	else:
		$Sprite.flip_h = false
		$RayCastAttack.set_cast_to(direction * ray_cast_attack)
		$RayCastDamage.set_cast_to(direction * ray_cast_damage)	
		$PositionAttack.position = ATTACK_INITIAL_POSITION
		$PositionAttack.position.x *= -1
	
func attack():
	if ATTACK_AGAIN == true:
		ATTACK_AGAIN = false
		$TimerAttack.start()
		var hit = HIT.instance()
		if direction == 1:
			hit.set_variable_direction(-1)
		else:
			hit.set_variable_direction(1)
		get_parent().add_child(hit)
		hit.position = $PositionAttack.global_position
		return
		
func _on_TimerAttack_timeout():
	ATTACK_AGAIN = true
	pass # Replace with function body.

func dead():
	is_dead = true
	var padre = get_parent()
	padre.receive_enemy_death_time(self.time_alive)
	
	var random_item = randi() % 2
	if random_item == 0:
		var salud = CURA.instance()
		get_parent().add_child(salud)
		salud.position = $CollisionShape2D.global_position
	else:
		var ammo = AMMO.instance()
		get_parent().add_child(ammo)
		ammo.position = $CollisionShape2D.global_position
	
	velocity = Vector2(0, 0)
	$Sprite.play("dead")
	yield($Sprite, "animation_finished")
	queue_free()
	
	

func _on_TouchBody_body_entered(body):
	if "Player" in body.name:
		if direction == 1:
			body.stunt_player(-20, 0)
		else:
			body.stunt_player(20, 0)	
	pass # Replace with function body.



