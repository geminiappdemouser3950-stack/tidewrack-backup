extends Control
class_name JournalReader
## JournalReader — the in-game journal screen. Lists discovered entries and
## shows the selected one. Built entirely in code (no scene file), in the same
## style as settings.gd: instantiate with JournalReader.new() and add it as a
## child of whatever overlay is on top — the pause menu adds it on "Journal".
##
## Input: ui_up / ui_down move through the list, ui_cancel closes. Both work
## on keyboard and gamepad because they go through the ui_* actions.

const PANEL_SIZE := Vector2(840, 480)
const LIST_WIDTH := 260

var _list: ItemList
var _title: Label
var _body: RichTextLabel
var _empty: Label
var _close_button: Button
var _ids: Array[String] = []
## The control that had focus when the reader opened (the pause menu's Journal
## button). Focus is handed back on close so a gamepad player is not left with
## nothing focused — otherwise the pause menu becomes unnavigable on a pad.
var _return_focus: Control = null


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_return_focus = get_viewport().gui_get_focus_owner()
	_build_ui()
	_populate()
	tree_exiting.connect(_restore_focus)


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var heading := Label.new()
	heading.text = "Journal"
	heading.add_theme_font_size_override("font_size", 28)
	vbox.add_child(heading)

	# Two columns: entry list on the left, selected entry on the right.
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(columns)

	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(LIST_WIDTH, 0)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.add_theme_font_size_override("font_size", 18)
	_list.item_selected.connect(_on_item_selected)
	columns.add_child(_list)

	var reading := VBoxContainer.new()
	reading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reading.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reading.add_theme_constant_override("separation", 8)
	columns.add_child(reading)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 22)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reading.add_child(_title)

	_body = RichTextLabel.new()
	_body.bbcode_enabled = false
	_body.fit_content = false
	_body.scroll_active = true
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("normal_font_size", 18)
	reading.add_child(_body)

	# Shown instead of the columns when nothing has been discovered yet.
	_empty = Label.new()
	_empty.text = "Nothing recorded yet.\nRead the keeper's log, or raise the mainland on the radio."
	_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_empty.modulate = Color(1, 1, 1, 0.6)
	_empty.add_theme_font_size_override("font_size", 18)
	_empty.hide()
	vbox.add_child(_empty)

	_close_button = Button.new()
	_close_button.text = "Back"
	_close_button.custom_minimum_size = Vector2(200, 40)
	_close_button.add_theme_font_size_override("font_size", 20)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_close_button.pressed.connect(_close)
	vbox.add_child(_close_button)

	# Explicit focus neighbours so a pad can move between the list and Back
	# with the stick/d-pad instead of relying on Godot's distance-based guess.
	_list.focus_neighbor_right = _close_button.get_path()
	_list.focus_neighbor_bottom = _close_button.get_path()
	_close_button.focus_neighbor_left = _list.get_path()
	_close_button.focus_neighbor_top = _list.get_path()

	var hint := Label.new()
	hint.text = "Up / Down: browse    B / Esc: back"
	hint.modulate = Color(1, 1, 1, 0.45)
	hint.add_theme_font_size_override("font_size", 14)
	vbox.add_child(hint)


func _populate() -> void:
	_ids = Journal.entries()
	_list.clear()
	if _ids.is_empty():
		_list.get_parent().hide()
		_empty.show()
		# Nothing to navigate, so focus goes straight to Back for gamepad users.
		_close_button.grab_focus()
		return

	for id in _ids:
		_list.add_item(Journal.title_for(id))
	_list.select(0)
	_on_item_selected(0)
	_list.grab_focus()


func _on_item_selected(index: int) -> void:
	if index < 0 or index >= _ids.size():
		return
	var id := _ids[index]
	_title.text = Journal.title_for(id)
	_body.text = Journal.body_for(id)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	queue_free()


func _restore_focus() -> void:
	if is_instance_valid(_return_focus) and _return_focus.is_inside_tree():
		_return_focus.grab_focus()
