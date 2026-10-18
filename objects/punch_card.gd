extends Node3D
class_name PunchCard

@onready var board: CSGBox3D = $board
const SINGLE_PUNCH = preload("uid://cjdkjr7547vmk")
const PUNCH_CARD_LABEL = preload("uid://dblij8pytyn62")
@onready var hole_punch: AudioStreamPlayer3D = $audio_holder/hole_punch
@onready var multi_punch: AudioStreamPlayer3D = $audio_holder/multi_punch
@onready var move_paper_sound: AudioStreamPlayer3D = $audio_holder/move_paper_sound
@onready var particle_holder: Node3D = $particle_holder

const CIRCLE_PARTICLE = preload("uid://droiodh1dyifc")
const SQUARE_PARTICLES = preload("uid://c4srd08vdurrp")

var placed_particle_poses = {}
var pattern = []
const row_count = 8
const col_count = 4
var og_position: Vector3

func reset_state():
    reset_pattern()
    Globals.remove_all_children_of(particle_holder)
    position = og_position
    placed_particle_poses.clear()

func play_moving_paper_sound():
    move_paper_sound.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    og_position = position
    reset_pattern()
    #apply_pattern(0, [[1,0,0,1],[0,0,1,1]])
    #apply_pattern(4, [[1,0,0,1],[0,0,1,1]])
    #show_pattern()
    
    #while true:
        #multi_punch.play()
        #await get_tree().create_timer(1).timeout
        #hole_punch.play()
        #await get_tree().create_timer(1).timeout


func show_pattern():
    for y in range(row_count):
        print(pattern[y])

func reset_pattern():
    pattern = []
    for y in range(row_count):
        pattern.append([])
        for x in range(col_count):
            pattern[-1].append(0)

func does_match_pattern(goal):
    return pattern == goal

func apply_pattern(starting_row_zero_indexed, array_array_to_apply):
    #print("applying", array_array_to_apply)
    for y in range(len(array_array_to_apply)):
        var num_pressed = 0
        #print("y", y)
        for x in range(col_count):
            if array_array_to_apply[y][x] == 1:
                pattern[y+starting_row_zero_indexed][x] = 1
                num_pressed += 1
        if num_pressed == 1:
            hole_punch.play()
        if num_pressed >= 2:
            multi_punch.play()
    update_visuals()

func update_visuals():
    Globals.remove_all_children_of(board)
    
    var half_size = board.size / 2.0
    var corner = board.position + Vector3(
        half_size.x,
        half_size.y,
        -half_size.z
    )
    for y in range(row_count):
        for x in range(col_count):    
            var cur_label = PUNCH_CARD_LABEL.instantiate() as Label3D
            board.add_child(cur_label)
            cur_label.text = "ABCD".substr(x, 1)
            
            cur_label.position = corner + Vector3(-.75,0,.75) + Vector3(-y*1.5, 0, x*1.5)
            cur_label.position.y = .1
            if pattern[y][x] == 1:
                var new_punch = SINGLE_PUNCH.instantiate() as CSGSphere3D
                board.add_child(new_punch)
                new_punch.position = corner + Vector3(-.75,0,.75) + Vector3(-y*1.5, 0, x*1.5)
                cur_label.modulate.a8 = 1
                
                var cur_spot = Vector2(x, y)
                if cur_spot in placed_particle_poses:
                    continue
                placed_particle_poses[cur_spot] = true
                #var circle_particle = CIRCLE_PARTICLE.instantiate() as CPUParticles3D
                #for particle in [square_particle]:
                var goal_pos = new_punch.global_position
                #await get_tree().process_frame
                var square_particle = SQUARE_PARTICLES.instantiate() as CPUParticles3D
                add_child(square_particle)
                square_particle.one_shot = true
                square_particle.finished.connect(square_particle.queue_free)
                square_particle.global_position = goal_pos
                
                #cur_label.position.y = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    update_visuals()
