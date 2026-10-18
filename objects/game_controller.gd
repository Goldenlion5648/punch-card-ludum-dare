extends Node

var is_sim_running = false
@onready var punch_card: PunchCard = %punch_card
@onready var controls_overlay: ControlsOverlay = $controls_overlay
@onready var goal_punch_card: PunchCard = %goal_punch_card

var goal_patterns = []
var current_level = 0

func set_goal_patterns():
    goal_patterns = [
        [
            [0,1,0,0],
            [0,1,0,0],
            [0,1,0,0],
            [0,1,0,0],
            [0,1,0,0],
            [0,1,0,0],
            [0,1,0,0],
            [0,1,0,0],
        ],
        [
            [0,1,0,0],
            [0,0,1,0],
            [0,1,0,0],
            [0,0,1,0],
            [0,1,0,0],
            [0,0,1,0],
            [0,1,0,0],
            [0,0,1,0],
        ],
    ]
    goal_punch_card.apply_pattern(0, get_current_goal())

func get_current_goal():
    return goal_patterns[current_level]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_goal_patterns()


func run_sim():
    if is_sim_running:
        #TODO: reset state here
        return
    var pattern = controls_overlay.get_pattern()
    is_sim_running = true
    for y in range(Globals.row_count):
        var move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
        var final_pos = punch_card.position + Vector3(1, 0, 0)
        move_tween.tween_property(punch_card, "position", final_pos, .5)
        await move_tween.finished
        punch_card.apply_pattern(y, [pattern[y % len(pattern)]])
        await get_tree().create_timer(.6).timeout
    print("does match?", punch_card.does_match_pattern(get_current_goal()))

    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("run_sim"):
        run_sim()
