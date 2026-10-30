extends Node
## Journal — discovered-logs system.
##
## Autoloaded as `Journal` (see project.godot). Dialogue nodes and choices will
## record discovered entries here via a "journal" key; the journal screen
## renders them. Current state: storage + helpers; discovery hook, persistence
## and reader UI still to come.

signal entry_added(id: String)

var _entries: Array[String] = []


func _ready() -> void:
	entry_added.connect(func(id: String) -> void: print("Journal: discovered '%s'" % id))
	print("Journal: ready (%d entries)" % _entries.size())


func discover(id: String) -> void:
	if id in _entries:
		return
	_entries.append(id)
	entry_added.emit(id)


func entries() -> Array[String]:
	return _entries.duplicate()


func has(id: String) -> bool:
	return id in _entries


func clear() -> void:
	_entries.clear()
# TODO: persist entries through GameState.save_game() and add the reader UI.
