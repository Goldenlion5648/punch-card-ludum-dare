@tool
extends EditorPlugin

const QUICK_OPEN_POPUP = preload("uid://5w33ey67m5b3")
var current_spawned_popup: PopupPanel = null
var current_shortcut_for_quick_search: Shortcut
var current_shortcut_for_quick_move_up: Shortcut
var current_shortcut_for_quick_move_down: Shortcut
var current_shortcut_for_swap_to_processed: Shortcut
var current_shortcut_for_move_to_bracket: Shortcut

var previous_search = ""
var open_to_close = {
    "(" : ")",
    "{" : "}",
    "[" : "]",
}
var close_to_open = {
    ")" : "(",
    "}" : "{",
    "]" : "[",
}

func _enable_plugin() -> void:
    print("loaded plugin")
    
    
func _disable_plugin() -> void:
    # Remove autoloads here.
    pass

    
func show_search_popup():
    current_spawned_popup = QUICK_OPEN_POPUP.instantiate() as MyQuickSearcher
    current_spawned_popup.searched_new_string.connect(func(searched):
        previous_search = searched)
    current_spawned_popup.prev_search = previous_search
    current_spawned_popup.popup_exclusive_on_parent(EditorInterface.get_script_editor(), get_top_of_script_editor(Vector2(700, 200)))
    
# this is from script-ide
func get_top_of_script_editor(pref_size: Vector2) -> Rect2i:
    var script_editor: ScriptEditor = EditorInterface.get_script_editor()
    #pref_size.y = 0
    var position: Vector2 = script_editor.global_position + Vector2(script_editor.size.x / 2, script_editor.size.y / 3) - pref_size / 2
    position.y = 100
    return Rect2i(position, pref_size)

func _enter_tree():
    add_shortcuts()
    
func add_shortcuts():
    const prefix = "plugin/quicksearch/"
    const quick_search_shortcut_path = prefix + "search_shortcut"
    const quick_move_up_shortcut_path = prefix + "quick_move_up"
    const quick_move_down_shortcut_path = prefix + "quick_move_down"
    const swap_to_processed_shortcut_path = prefix + "swap_to_processed"
    const move_to_backet_shortcut_path = prefix + "move_to_backet"
    var editor_settings: EditorSettings = EditorInterface.get_editor_settings()
    if not editor_settings.has_setting(quick_search_shortcut_path):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.keycode = KEY_O
        event.ctrl_pressed = true
        shortcut.events = [ event ]
        editor_settings.set_setting(quick_search_shortcut_path, shortcut)
    if not editor_settings.has_setting(quick_move_up_shortcut_path):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.keycode = KEY_UP
        event.ctrl_pressed = true
        shortcut.events = [ event ]
        editor_settings.set_setting(quick_move_up_shortcut_path, shortcut)
    if not editor_settings.has_setting(quick_move_down_shortcut_path):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.keycode = KEY_DOWN
        event.ctrl_pressed = true
        shortcut.events = [ event ]
        editor_settings.set_setting(quick_move_down_shortcut_path, shortcut)
    if not editor_settings.has_setting(swap_to_processed_shortcut_path):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.keycode = KEY_X
        event.alt_pressed = true
        shortcut.events = [ event ]
        editor_settings.set_setting(swap_to_processed_shortcut_path, shortcut)
    if not editor_settings.has_setting(move_to_backet_shortcut_path):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.keycode = KEY_BACKSLASH
        event.shift_pressed = true
        event.ctrl_pressed = true
        shortcut.events = [ event ]
        editor_settings.set_setting(move_to_backet_shortcut_path, shortcut)
    current_shortcut_for_quick_search = editor_settings.get_setting(quick_search_shortcut_path)
    current_shortcut_for_quick_move_up = editor_settings.get_setting(quick_move_up_shortcut_path)
    current_shortcut_for_quick_move_down = editor_settings.get_setting(quick_move_down_shortcut_path)
    current_shortcut_for_swap_to_processed = editor_settings.get_setting(swap_to_processed_shortcut_path)
    current_shortcut_for_move_to_bracket = editor_settings.get_setting(move_to_backet_shortcut_path)

#func _input(event: InputEvent) -> void:
    #print(event)

func _shortcut_input(event: InputEvent) -> void:
    #if not event.is_pressed():
        #return
    #if current_shortcut_for_quick_search.matches_event(event):
    if event.is_match(current_shortcut_for_quick_search.events[0], true):
        get_viewport().set_input_as_handled()
        show_search_popup()
        #
        #
    if current_shortcut_for_quick_move_up.matches_event(event):
        #print("did quick move up")
        var godot_main_code_edit = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit)
        var line_before = godot_main_code_edit.get_caret_line()
        godot_main_code_edit.set_caret_line(max(0, line_before - 5))
        get_viewport().set_input_as_handled()
    if current_shortcut_for_quick_move_down.matches_event(event):
        var godot_main_code_edit = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit)
        var line_before = godot_main_code_edit.get_caret_line()
        godot_main_code_edit.set_caret_line(min(line_before + 5, godot_main_code_edit.get_line_count()))
        get_viewport().set_input_as_handled()
    if current_shortcut_for_move_to_bracket.matches_event(event) and not event.is_echo() and event.is_pressed():
        var godot_main_code_edit = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit)
        var column_at_start = godot_main_code_edit.get_caret_column()
        var line_at_start = godot_main_code_edit.get_caret_line()
        var text_with_caret = godot_main_code_edit.get_text_with_cursor_char(line_at_start, column_at_start)
        var starting_caret_pos_overall = text_with_caret.find(char(0xFFFF))
        var char_on_left = null
        var char_on_left_pos = -1
        var bracket_stack = []
        for i in range(-1, 600):
            if starting_caret_pos_overall - i < 0:
                break
            if starting_caret_pos_overall-i >= len(text_with_caret):
                continue
            var cur_char = text_with_caret[starting_caret_pos_overall-i]
            if cur_char in close_to_open and i >= 1:
                bracket_stack.append(cur_char)
            if cur_char in open_to_close:
                if bracket_stack and close_to_open[bracket_stack[-1]] == cur_char:
                    bracket_stack.pop_back()
                else:
                    char_on_left = cur_char
                    char_on_left_pos = starting_caret_pos_overall-i
                    break
        var char_on_right = text_with_caret[starting_caret_pos_overall+1]
        var char_on_right_pos = -1
        bracket_stack.clear()
        for i in range(-1, 600):
            if starting_caret_pos_overall + i >= len(text_with_caret):
                break
            if starting_caret_pos_overall + i < 0:
                continue
            var cur_char = text_with_caret[starting_caret_pos_overall+i]
            if cur_char in open_to_close and i >= 1:
                bracket_stack.append(cur_char)
            if cur_char in close_to_open:
                if bracket_stack and open_to_close[bracket_stack[-1]] == cur_char:
                    bracket_stack.pop_back()
                else:
                    char_on_right = cur_char
                    char_on_right_pos = starting_caret_pos_overall+i
                    break
        prints("char_on_left, char_on_right", char_on_left, char_on_right)
        # Check the adjacent positions first
        
        var diff_on_left = abs(char_on_left_pos - starting_caret_pos_overall)
        var diff_on_right = abs(char_on_right_pos - starting_caret_pos_overall)
        prints("diff_on_left", diff_on_left)
        prints("diff_on_right", diff_on_right)
        prints("starting_caret_pos_overall", starting_caret_pos_overall)
        
        if char_on_left and char_on_right:
            if diff_on_right == 1:
                print("bottom")
                move_caret_to_left(text_with_caret, char_on_left_pos + 1, starting_caret_pos_overall, godot_main_code_edit)
            else:
                move_caret_to_right(text_with_caret, char_on_right_pos - 2, starting_caret_pos_overall, godot_main_code_edit)
            
            
        get_viewport().set_input_as_handled()
    if current_shortcut_for_swap_to_processed.matches_event(event) and not event.is_echo() and event.is_pressed():
        var current_file_path = (EditorInterface.get_script_editor().get_current_script()).resource_path
        if current_file_path.get_extension() != "gd" or "plugin" in current_file_path:
            return
        #prints("cur_script_path", cur_script_path)
        get_viewport().set_input_as_handled()
        var backup_path = current_file_path + ".backup"
        var starting_text = FileAccess.open(current_file_path, FileAccess.READ).get_as_text()
        #print(starting_text)
        var starting_lines = starting_text.split("\n")
        var last_lines = starting_lines[-3] + starting_lines[-2] + starting_lines[-1]
        #print("last_lines", last_lines)
        var base_code_edit = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit)
        var starting_file_line = base_code_edit.get_caret_line()
        print("starting_file_line", starting_file_line)
        var starting_file_col = base_code_edit.get_caret_column()
        var word_originally_under_caret = base_code_edit.get_word_under_caret()
        var new_line
        var new_col = starting_file_col
        const steps_back_to_check = 8
        # They were already viewing the processed content.
        if last_lines.rfind("##THIS WAS AUTO GENERATED") != -1:
            print("top")
            if FileAccess.file_exists(backup_path):
                # Restore the original.
                DirAccess.copy_absolute(backup_path, current_file_path)
            else:
                print("no backup was available")
            new_line = starting_lines[starting_file_line].substr(len(starting_lines[starting_file_line]) - steps_back_to_check).to_int()
            prints("new_line", new_line)
            var pos_of_word = starting_lines[starting_file_line].find(word_originally_under_caret)
            if pos_of_word != -1:
                new_col = pos_of_word + 1
        else:
            print("bottom")
            # They started with the code before processing, so backup first.
            var err2 = DirAccess.copy_absolute(current_file_path, backup_path)
            # Load the processed version.
            var processed_path = current_file_path + ".processed"
            if FileAccess.file_exists(processed_path):
                var err = DirAccess.copy_absolute(processed_path, current_file_path)
                
            var processed_text = FileAccess.open(processed_path, FileAccess.READ).get_as_text()
            var first_valid_answer = null
            prints("starting_file_line", starting_file_line)
            for i, line in enumerate(processed_text.split("\n")):
                var source_line_for_this_processed_line = line.substr(len(line) - steps_back_to_check).to_int()
                if source_line_for_this_processed_line - 1 == starting_file_line:
                    if first_valid_answer == null:
                        first_valid_answer = i + 1
                        new_line = i + 1
                    var pos_of_word = line.find(word_originally_under_caret)
                    if pos_of_word != -1:
                        new_col = pos_of_word + 1
                        break
                if source_line_for_this_processed_line > starting_file_line:
                    new_line = first_valid_answer
                    new_col = starting_file_col
                    break
            
        var res: Resource = load(current_file_path)
        #(EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit).get_word_under_caret()
        prints(new_line, new_col)
        EditorInterface.get_script_editor().reload_open_files()
        EditorInterface.edit_script(res, new_line, new_col)
        EditorInterface.get_script_editor().reload_open_files()
        #EditorInterface.re(res, new_line, new_col)
        #var line_before = godot_main_code_edit.resoux
        
func move_caret_to_left(text_with_caret, char_on_left_pos, starting_caret_pos_overall, godot_main_code_edit):
    var new_pos = char_on_left_pos
    if new_pos != -1:
        var new_line_num = text_with_caret.count("\n", 0, new_pos)
        # we subtract 2 because the caret is in the text, and we want to end up on the left side of the closing symbol 
        var new_col = (new_pos - text_with_caret.rfind("\n", new_pos)) - 2
        godot_main_code_edit.set_caret_line(new_line_num)
        godot_main_code_edit.set_caret_column(new_col)
        
func move_caret_to_right(text_with_caret, char_on_right_pos, starting_caret_pos_overall, godot_main_code_edit):
    var new_pos = char_on_right_pos
    print("new_pos", new_pos)
    if new_pos != -1:
        var new_line_num = text_with_caret.count("\n", 0, new_pos)
        var new_col = (new_pos - text_with_caret.rfind("\n", new_pos))
        godot_main_code_edit.set_caret_line(new_line_num)
        godot_main_code_edit.set_caret_column(new_col)

func _exit_tree() -> void:
    if current_spawned_popup:
        current_spawned_popup.queue_free()
        print("freed")
