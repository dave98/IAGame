extends Node

const TIME_WINDOWS = 15
var ACTUAL_WINDOWS = 0
var GET_DATA = false #Empezamos sin ninguna ventana
var PLAYER_AVAILABLE = true
var MAX_CONSIDERED_ENEMIES = 50
var MAX_CONSIDERED_CURAS = 50
var MAX_CONSIDERED_AMMO = 50
var MAX_CONSIDERED_SPAWNERS = 30
var INFLUENCE_BEHAVIOR_INDEX = 0.2

var p_running_time = 0
var n_new_areas = 0
var n_shoots_made = 0
var p_objective_shoots = 0
var n_hits_made = 0
var p_objective_hits = 0
var p_dead_enemies = 0
var t_between_hits = 0
var t_between_shoots = 0
var d_enemies = 0
var t_enemies_to_die = 0
var p_health_packages = 0
var t_alive_health = 0
var p_ammo_packages = 0
var t_ammo_alive = 0
var p_damage_received = 0
var n_directions = 0

var openness = Global.g_open
var concientuness = Global.g_cons
var neurocitism = Global.g_neu

var objective_author = "Player"
export var subjective_enemy = "Enemy_Skull"
onready var _player = get_node_or_null(objective_author)

var initial_enemy_number = 0
var initial_cura_number = 0
var initial_ammo_number = 0
var initial_enenmy_alive_time = 0
var initial_health_alive_time = 0
var initial_ammo_alive_time = 0

#var ann	= load("res://bin/gdtest.gdns").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#self._player.opens = self.openness
	#self._player.consc = self.concientuness
	#self._player.neuros = self.neurocitism
	#print(ann.create_saved_ann("redxor_2.sinapsis"))
	#$TimerWindows.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("Agree: ", Global.g_agree)
	#print("Concient: ", Global.g_cons)
	#print("Extraversion: ", Global.g_extra)
	#print("Neuroticism: ", Global.g_neu)
	#print("Opennes: ", Global.g_open)
	#self._is_connected()
	#if GET_DATA == true:
	#	GET_DATA = false
	#	ACTUAL_WINDOWS += 1
	#	$TimerWindows.start()
	#	#Configuracion basica
	#	self.update_data() #Obtenemos los datos obtenidos por el jugador
	#	self._player.reset_done_behaviors() # Reseteamos los datos cedidos por el jugadorez
	#	self.reset_own_values() #Reseteamos los datos obtenidos al externo del jugador

	pass

func _is_connected():
	if self.has_node("Player"):
		print ("Connected: ",_player.salud)
	else:
		print("El jugador ha muerto")

func update_data():
	if self.is_objective_alive():
		self.p_running_time = self._player.tiempo_corriendo #1
		self.n_new_areas = self._player.areas_exploradas #2
		self.n_shoots_made = self._player.total_disparos #3
		#self.p_objective_shoots = self._player.disparos_acertados #4
		self.n_hits_made = self._player.total_golpes #5
		#self.p_objective_hits = self._player.golpes_acertados #6
		#self.p_dead_enemies = 0 #7
		self.t_between_hits = self._player.tiempo_entre_golpes #8
		self.t_between_shoots = self._player.tiempo_entre_disparos #9
		self.d_enemies = 0.5 #10
		#self.t_enemies_to_die = 0 #11 
		#self.p_health_packages = self._player.curas_recogidas #12
		#self.t_alive_health = self._player.vida_curas #13
		#self.p_ammo_packages = self._player.municion_recogida #14
		#self.t_ammo_alive = self._player.vida_municion #15
		self.p_damage_received = self._player.vida_perdida #16
		self.n_directions = self._player.numero_direcciones #17
		
		var temp_shoots_made = self.n_shoots_made
		var temp_hits_made = self.n_hits_made
		
		#FORMATTING DATA
		self.p_running_time = get_percentage(self.p_running_time, self.TIME_WINDOWS) #1 LISTO
		#self.n_new_areas															 #2 LISTO
		self.n_shoots_made = get_percentage(self.n_shoots_made, self.TIME_WINDOWS)   #3 LISTO
		self.p_objective_shoots = get_percentage(self.p_objective_shoots, temp_shoots_made) #4 LISTO
		self.n_hits_made = get_percentage(self.n_hits_made, self.TIME_WINDOWS) #5 LISTO 
		self.p_objective_hits = get_percentage(self.p_objective_hits, temp_hits_made) #6 LISTO
		self.p_dead_enemies = get_percentage(get_total_enemies(), self.initial_enemy_number) #7 LISTO 
		self.t_between_hits = get_percentage(self.t_between_hits, self.TIME_WINDOWS) #8 LISTO
		self.t_between_shoots = get_percentage(self.t_between_shoots, self.TIME_WINDOWS) #9 LISTO
		self.d_enemies = 0.5 #10 LISTO
		self.t_enemies_to_die  = get_percentage(self.initial_enenmy_alive_time, self.TIME_WINDOWS) #11 LISTO
		self.p_health_packages = get_percentage(get_total_curas(), self.initial_cura_number) #12 LISTO
		self.t_alive_health = get_percentage(self.initial_health_alive_time, self.TIME_WINDOWS) #13 LISTO
		self.p_ammo_packages = get_percentage(get_total_ammo(), self.initial_ammo_number)
		self.t_ammo_alive = get_percentage(self.initial_ammo_alive_time, self.TIME_WINDOWS)
		self.p_damage_received = get_percentage(self.p_damage_received, self._player.max_salud)
		self.n_directions = get_percentage(self.n_directions / 2, self.TIME_WINDOWS)
		#DATA NORMALIZATION:
		self.n_directions = round_to_one(self.n_directions)
		
		
		
		#EVALUATIING IN NEURAL NETWORK
		print(ann.data_to_evaluate(self.p_running_time, self.n_new_areas, self.n_shoots_made, self.p_objective_shoots, self.n_hits_made, self.p_objective_hits, self.p_dead_enemies, self.t_between_hits, self.t_between_shoots, self.d_enemies, self.t_enemies_to_die, self.p_health_packages, self.t_alive_health, self.p_ammo_packages, self.t_ammo_alive, self.p_damage_received, self.n_directions))
		print(ann.evaluate())
		
		self.openness = ann.get_ope()
		self.concientuness = ann.get_cons()
		self.neurocitism = ann.get_neuro()

		self.openness = (Global.g_open * (1.0 - INFLUENCE_BEHAVIOR_INDEX)) + (self.openness * INFLUENCE_BEHAVIOR_INDEX)
		self.concientuness = (Global.g_cons * (1.0 - INFLUENCE_BEHAVIOR_INDEX)) + (self.concientuness * INFLUENCE_BEHAVIOR_INDEX)
		self.neurocitism = (Global.g_neu * (1.0 - INFLUENCE_BEHAVIOR_INDEX)) + (self.neurocitism * INFLUENCE_BEHAVIOR_INDEX)
		
		Global.g_open = self.openness
		Global.g_cons = self.concientuness
		Global.g_neu = self.neurocitism

		#Updating Player behavior index
		self._player.opens = self.openness
		self._player.consc = self.concientuness
		self._player.neuros = self.neurocitism
		
		#print("Openness: ", ann.get_ope())
		#print("Conscientiuness: ", ann.get_cons())
		#print("Neuroticism: ", ann.get_neuro())
		#self.print_values()
	else:
		pass

func print_values():
	print("VENTANA NUMERO ----> ", self.ACTUAL_WINDOWS, " <---------------")
	print("Running Time: ", self.p_running_time)
	print("Areas exploradas: ", self.n_new_areas)
	print("Disparos hechos: ", self.n_shoots_made)
	print("Disparos acertados: ", self.p_objective_shoots)
	print("Golpes dados: ", self.n_hits_made)
	print("Folpes acertados: ", self.p_objective_hits)
	print("Porcentaje de enemigos muertos: ", self.p_dead_enemies)
	print("Tiempo entre rafagas de golpes ", self.t_between_hits)
	print("Tiempo entre rafagas de disparos: ", self.t_between_shoots)
	print("Distancia de los enemigos muertos: ", self.d_enemies)
	print("Tiempo promedio de muerte en los enemigos: ", self.t_enemies_to_die)
	print("Porcentaje de curas recogidas: ", self.p_health_packages)
	print("Las curas duraron por: ", self.t_alive_health)
	print("Porcentaje de municiones recogidas: ", self.p_ammo_packages)
	print("Las municiones duraron por: ", self.t_ammo_alive)
	print("Porcentaje de daño recibido: ", self.p_damage_received)
	print("Cambio de direcciones: ", self.n_directions)

#Contador que indica el inicio de una nueva sesion del mapa
func _on_TimerWindows_timeout():
	GET_DATA = true
	pass # Replace with function body.

func is_objective_alive():
	if self.has_node(self.objective_author):
		return true
	else:
		return false
	
func get_percentage(var val_a, var val_b): #Porcentaje de A respecto a B
	if val_b == 0.0:
		return 0.5
	else:	
		var answer = (val_a * 100.0) / val_b
		answer = answer / 100.0 #Reduciendo a 0 y 1
		return answer
	
func get_total_enemies():
	var answer = 0
	if self.has_node(subjective_enemy):
		answer += 1
		
	for i in range(MAX_CONSIDERED_ENEMIES):
		var temp_enemy = self.subjective_enemy + str(i)
		var circs_enemy = "@" + self.subjective_enemy + "@" + str(i)
		if self.has_node(temp_enemy):
			answer += 1
		if self.has_node(circs_enemy):
			answer += 1
	#print("Numero de enemigos: ", answer)
	return answer

func get_total_curas():
	var answer = 0
	if self.has_node("Cura"):
		answer += 1
	
	for i in range(MAX_CONSIDERED_CURAS):
		var temp_cura = "Cura" + str(i)
		var circs_cura = "@Cura@" + str(i)
		if self.has_node(temp_cura):
			answer += 1
		if self.has_node(circs_cura):
			answer += 1
	#print("Numero de curas: ", answer)
	return answer		

func get_total_ammo():
	var answer = 0
	if self.has_node("Ammo"):
		answer += 1
	
	for i in range(MAX_CONSIDERED_AMMO):
		var temp_ammo = "Ammo" + str(i)
		var circs_ammo = "@Ammo@" + str(i)
		if self.has_node(temp_ammo):
			answer += 1
		if self.has_node(circs_ammo):
			answer += 1
	return answer
	
func reset_own_values():
	self.p_objective_shoots = 0
	self.p_objective_hits = 0
	self.initial_enemy_number = self.get_total_enemies()
	self.initial_cura_number = self.get_total_curas()
	self.initial_ammo_number = self.get_total_ammo()
	self.initial_enenmy_alive_time = TIME_WINDOWS / 2 # BECAREFUL
	self.initial_health_alive_time = TIME_WINDOWS / 2 # BECAREFUL
	self.initial_ammo_alive_time = TIME_WINDOWS / 2 #BECAREFUL

func receive_objective_shoot():
	self.p_objective_shoots += 1

func receive_objective_hits():
	self.p_objective_hits += 1

func receive_enemy_death_time(var _time):
	#print("Tiempo de vida: ", _time)
	self.initial_enenmy_alive_time = (self.initial_enenmy_alive_time + _time ) / 2
	
func receive_health_death_timer(var _time):
	#print("Tiempo de vida de salud: ", _time)
	self.initial_health_alive_time = (self.initial_health_alive_time + _time) / 2

func receive_ammo_death_timer(var _time):
	print("Tiempo de vida de ammo: ", _time)
	self.initial_health_alive_time = (self.initial_health_alive_time + _time) / 2

#
func receive_enemy_spawn_alert():
	self.get_closest_spawner()
		
func get_closest_spawner():
	#BECAREFUL siempre debe existir un Spawer sin indice 
	var spawner_name = "AreaSpawner"
	var minimal_distance = 0.0
	var selected_spawner = "AreaSpawner"
	
	minimal_distance = distance_beetwen_two_points(self._player.global_position, get_node(spawner_name).global_position)
	#print("Distancia a spawner mas proximo: ", minimal_distance)
	for i in range(MAX_CONSIDERED_SPAWNERS):
		var temp_spawner_name = spawner_name + str(i)
		if self.has_node(temp_spawner_name):
			var temp_distance = distance_beetwen_two_points(self._player.global_position, get_node(temp_spawner_name).global_position)
			if minimal_distance > temp_distance:
				minimal_distance = temp_distance
				selected_spawner = temp_spawner_name
	
	print("Spawner seleccionado: ", selected_spawner)
	get_node(selected_spawner).activate_spawner()

func distance_beetwen_two_points(var a, var b):
	var answer = pow((b.x - a.x), 2) +  pow((b.y - a.y), 2)
	answer = sqrt(answer)
	return answer

func round_to_one(var a):
	if a > 1.0:
		return a
	else:
		return a
















