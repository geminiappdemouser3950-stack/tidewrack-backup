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


## Wipe all entries. Called by GameState.new_game() so a fresh run starts empty.
func clear() -> void:
	_entries.clear()


## Replace the in-memory entries with the list from a save file. Called by
## GameState.load_game(). Non-string or duplicate ids are dropped so a hand-edited
## or partially corrupt save cannot poison the list.
func restore(ids: Array) -> void:
	_entries.clear()
	for id in ids:
		if typeof(id) == TYPE_STRING and not (id in _entries):
			_entries.append(id)
	print("Journal: restored %d entries from save" % _entries.size())
# TODO: dialogue discovery hook and the reader UI.
