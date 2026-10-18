extends Node

var is_sim_running = false
@onready var punch_card: PunchCard = %punch_card
@onready var controls_overlay: ControlsOverlay = $controls_overlay
@onready var goal_punch_card: PunchCard = %goal_punch_card

@onready var win_sound: AudioStreamPlayer2D = $sound_holder/win_sound
@onready var wrong_sound: AudioStreamPlayer2D = $sound_holder/wrong_sound
@onready var win_card: MeshInstance3D = %win_card
@onready var action_buttons_holder: VFlowContainer = %action_buttons_holder
@onready var play_again_button: Button = %play_again_button

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
        [
            [0,1,0,1],
            [0,0,1,0],
            [0,1,0,0],
            [0,0,1,0],
            [0,1,0,1],
            [0,0,1,0],
            [0,1,0,0],
            [0,0,1,0],
        ],
    ]
    goal_punch_card.reset_pattern()
    
    goal_punch_card.apply_pattern(0, get_current_goal())

func get_current_goal():
    return goal_patterns[current_level]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_goal_patterns()


func run_sim():
    punch_card.reset_state()
    var pattern = controls_overlay.get_pattern()
    is_sim_running = true
    for y in range(Globals.row_count):
        var move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
        var final_pos = punch_card.position + Vector3(1, 0, 0)
        move_tween.tween_property(punch_card, "position", final_pos, .5)
        move_tween.parallel().tween_callback(punch_card.play_moving_paper_sound)
        await move_tween.finished
        punch_card.apply_pattern(y, [pattern[y % len(pattern)]])
        await get_tree().create_timer(.6).timeout
    var does_match = punch_card.does_match_pattern(get_current_goal())
    print("does match?", does_match)
    is_sim_running = false
    if does_match:
        win_sound.play()
        await get_tree().create_timer(1.5).timeout
        var new_level_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
        var goal_taken_pos = goal_punch_card.position + Vector3(-20, 0, 0)
        var working_copy_taken_pos = punch_card.position + Vector3(-50, 0, 0)
        var left_side_pos = goal_punch_card.position + Vector3(0, 0, -10)
        var right_side_pos = punch_card.og_position + Vector3(0, 0, 20)
        
        new_level_tween.tween_property(punch_card, "position", working_copy_taken_pos, 1)
        new_level_tween.parallel().tween_property(punch_card, "rotation:y", get_random_angle(), 1)
        new_level_tween.parallel().tween_callback(punch_card.play_moving_paper_sound)
        new_level_tween.tween_property(goal_punch_card, "position", goal_taken_pos, 1)
        new_level_tween.parallel().tween_property(goal_punch_card, "rotation:y", get_random_angle(), 1)
        new_level_tween.parallel().tween_callback(goal_punch_card.play_moving_paper_sound)
        new_level_tween.tween_callback(func(): 
            current_level += 1
            controls_overlay.reset_holder()
            goal_punch_card.position = left_side_pos
            goal_punch_card.rotation.y = get_random_angle()
            punch_card.position = right_side_pos
            punch_card.rotation.y = get_random_angle()
            punch_card.reset_pattern()
            if current_level != len(goal_patterns):
                set_goal_patterns()
        )
        await new_level_tween.finished
        var right_side_object = punch_card
        var part2_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
        if current_level == len(goal_patterns):
            right_side_object = win_card
            action_buttons_holder.visible = false
            play_again_button.visible = true
            propagate_call("game_end")
        else:
            part2_tween.tween_property(goal_punch_card, "position", goal_punch_card.og_position, 1)
            part2_tween.parallel().tween_property(goal_punch_card, "rotation:y", 0, 1)
            part2_tween.parallel().tween_callback(goal_punch_card.play_moving_paper_sound)
            
        part2_tween.tween_property(right_side_object, "position", punch_card.og_position, 1)
        part2_tween.parallel().tween_property(right_side_object, "rotation:y", 0, 1)
        part2_tween.parallel().tween_callback(punch_card.play_moving_paper_sound)
    else:
        wrong_sound.play()

func get_random_angle():
    var random_angles = [deg_to_rad(-20), deg_to_rad(5), deg_to_rad(10), deg_to_rad(-10)]
    return random_angles.pick_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("run_sim"):
        run_sim()
    if Input.is_action_pressed("fast_forward") and is_sim_running:
        Engine.time_scale = 4
    else:
        Engine.time_scale = 1


func _on_run_sim_button_pressed() -> void:
    run_sim()


func _on_play_again_button_pressed() -> void:
    get_tree().reload_current_scene()
