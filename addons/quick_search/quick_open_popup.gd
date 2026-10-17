@tool
extends PopupPanel
class_name MyQuickSearcher

@onready var quick_open_vbox: VBoxContainer = $quick_open_vbox
@onready var search_input_line_edit: LineEdit = $quick_open_vbox/search_input_line_edit
const SINGLE_QUICK_OPEN_RESULT = preload("uid://csowm63k0r6dc")
const SINGLE_SECTION_CONTAINER = preload("uid://btbqy2uilikeh")

var results = []
var selected_label: SingleQuickOpenResult = null
var original_file_when_window_opened
var original_file_line
var original_file_col
signal searched_new_string(new_text)

var prev_search = ""
var selected_result_index = 0:
    set(val):
        selected_result_index = val
        update_highlight(val)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    search_input_line_edit.text_changed.connect(search_for)
    search_input_line_edit.text_changed.connect(searched_new_string.emit)
    search_input_line_edit.grab_focus()
    original_file_when_window_opened = EditorInterface.get_script_editor().get_current_script()
    original_file_line = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit).get_caret_line()
    original_file_col = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit).get_caret_column()
    print("setting start search")
    set_starting_search()
    search_input_line_edit.select()
    print("about to search")
    print("got loaded")

func set_starting_search():
    var cur_selected_text = (EditorInterface.get_script_editor().get_current_editor().get_base_editor() as CodeEdit).get_selected_text(0)
    print("cur_selected_text", cur_selected_text)
    print("prev_search", prev_search)
    if cur_selected_text:
        print("top")
        search_input_line_edit.insert_text_at_caret(cur_selected_text)
        search_for(cur_selected_text)
    elif prev_search != "":
        print("bottom")
        search_for(prev_search)
    print("end")
        

func set_search_text(new_search):
    search_input_line_edit.text = new_search

func update_highlight(new_index):
    var remaining = new_index
    print("remaining",remaining)
    prints("child count", quick_open_vbox.get_child_count())
    for i in range(1, quick_open_vbox.get_child_count()):
        prints("i", i)
        var cur_section = quick_open_vbox.get_child(i) as SingleSectionContainer
        if cur_section.get_contained_matches_count() > remaining:
            if selected_label:
                selected_label.is_selected = false
            selected_label = cur_section.get_child(remaining + 1)
            selected_label.is_selected = true
            break
        else:
            remaining -= cur_section.get_contained_matches_count()

func remove_all_old_results():
    while quick_open_vbox.get_child_count() > 1:
        var to_remove = quick_open_vbox.get_child(-1)
        quick_open_vbox.remove_child(to_remove)
        to_remove.queue_free()

func search_for(to_find: String):
    print('opened search')
    if len(to_find) == 0:
        results.clear()
        print("original_file_when_window_opened is now ", original_file_when_window_opened)
        #remove_all_old_results()
    if len(to_find) >= 2:
        find_all_matches("res://", to_find)
        var prev_file_name = ""
        var current_file_results_section: SingleSectionContainer = null
        for res in results:
#            cur_path, line_num, line_content.substr(trimmed_start, trimmed_end - trimmed_start), col - trimmed_start, col
            var file_name = res[0]
            var line_num = res[1]
            var line_content = res[2]
            var col = res[3]
            if file_name != prev_file_name:
                current_file_results_section = SINGLE_SECTION_CONTAINER.instantiate() as SingleSectionContainer
                quick_open_vbox.add_child(current_file_results_section)
                current_file_results_section.set_file(file_name)
                prev_file_name = file_name
                
            current_file_results_section.add_match(res)
        selected_result_index = 0
        if results:
            EditorInterface.set_main_screen_editor("Script")
    prev_search = to_find
    
func read_file(path):
    return FileAccess.open(path, FileAccess.READ).get_as_text()

func get_all_gd_paths(path: String):
    var dir = DirAccess.open(path)
    var all_gd_files = []
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir():
                #print("Found directory: " + file_name)
                #if file_name != "addons":
                    all_gd_files.append_array(get_all_gd_paths(path.path_join(file_name)))
            else:
                #print("Found file: " + file_name)
                if file_name.ends_with(".gd"):
                    var joined_path = path.path_join(file_name)
                    all_gd_files.append(path.path_join(file_name))
            file_name = dir.get_next()
        
    else:
        print("An error occurred when trying to access the path.")
    return all_gd_files
        
func find_all_matches(path: String, to_find: String):
    var all_gd_files = get_all_gd_paths(path)
    all_gd_files.sort_custom(func(file_path1, file_path2):
            return FileAccess.get_modified_time(file_path1) > FileAccess.get_modified_time(file_path2)
    )
    #print(all_gd_files)
    print("all_gd_files end")
    results.clear()
    remove_all_old_results()
    to_find = to_find.to_lower()
    for cur_path in all_gd_files:
        var contents = read_file(cur_path)
        var lines = contents.split("\n")
        for line_num, line_content: String in enumerate(lines, 1):
            for col, letter in enumerate(line_content):
                if line_content.substr(col, len(to_find)).to_lower() == to_find:
                    results.append([cur_path, line_num, line_content, col, to_find])
            
    #print(results)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_down"):
        selected_result_index = posmod(selected_result_index + 1, len(results))
        update_highlight(selected_result_index)
        set_input_as_handled()
    if event.is_action_pressed("ui_up"):
        selected_result_index = posmod(selected_result_index - 1, len(results))
        update_highlight(selected_result_index)
        set_input_as_handled()
    if selected_label:
        selected_label.open_linked_script()
    if event.is_action_pressed("ui_cancel"):
        print("heard cancel")
        prints("original_file_when_window_opened", original_file_when_window_opened)
        EditorInterface.edit_script(original_file_when_window_opened, original_file_line + 1, original_file_col + 1)
        
    if event.is_action_pressed("ui_text_submit"):
        hide()
        #var root := EditorInterface.get_edited_scene_root()
        #if root:
            #var scene := PackedScene.new()
            #scene.pack(root)
            #ResourceSaver.save(scene, "res://saved_popup.tscn")
        #hide()
    #print_tree_pretty()
            #if (ResourceLoader.exists(selected_label.)):
                #var res: Resource = load(file)
            #EditorInterface.edit_script()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
