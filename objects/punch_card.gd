extends Node3D

@onready var board: CSGBox3D = $board
const SINGLE_PUNCH = preload("uid://cjdkjr7547vmk")
const PUNCH_CARD_LABEL = preload("uid://dblij8pytyn62")

var pattern = []
const row_count = 8
const col_count = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    init_pattern()
    apply_pattern(0, [[1,0,0,1],[0,0,1,1]])
    apply_pattern(4, [[1,0,0,1],[0,0,1,1]])
    show_pattern()
    update_visuals()

func show_pattern():
    for y in range(row_count):
        print(pattern[y])

func init_pattern():
    pattern = []
    for y in range(row_count):
        pattern.append([])
        for x in range(col_count):
            pattern[-1].append(0)

func apply_pattern(starting_row_zero_indexed, to_apply):
    for y in range(len(to_apply)):
        for x in range(col_count):
            if to_apply[y][x] == 1:
                pattern[y+starting_row_zero_indexed][x] = 1

func update_visuals():
    Globals.remove_all_children_of(board)
    var half_size = board.size / 2.0
    var corner = board.global_position + Vector3(
        half_size.x,
        half_size.y,
        -half_size.z
    )
    for y in range(row_count):
        for x in range(col_count):    
            var cur_label = PUNCH_CARD_LABEL.instantiate() as Label3D
            board.add_child(cur_label)
            cur_label.text = "ABCD".substr(x, 1)
            
            if pattern[y][x] == 1:
                var new_punch = SINGLE_PUNCH.instantiate() as CSGSphere3D
                board.add_child(new_punch)
                new_punch.position = corner + Vector3(-.75,0,.75) + Vector3(-y*1.5, 0, x*1.5)
                cur_label.modulate.a8 = 1
            cur_label.position = corner + Vector3(-.75,0,.75) + Vector3(-y*1.5, 0, x*1.5)
            cur_label.position.y = .1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    update_visuals()
