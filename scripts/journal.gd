extends Node
## Journal — discovered-logs system.
##
## Autoloaded as `Journal` (see project.godot). DialogueManager reports every
## set_flag here; canonical flags set truthy become discovered entries, keyed by
## the flag name. Entries persist through GameState's save/load and are wiped
## on New Game. Reader UI still to come.

signal entry_added(id: String)

## The canonical narrative flags from narrative/flags-and-branches.md. Only these
## produce journal entries; incidental or debug flags are ignored.
const CANONICAL_FLAGS: Array[String] = [
	"skeptic",
	"believer",
	"trusted_edith",
	"radioed_tom",
]

var _entries: Array[String] = []


func _ready() -> void:
	entry_added.connect(func(id: String) -> void: print("Journal: discovered '%s'" % id))
	print("Journal: ready (%d entries)" % _entries.size())


func discover(id: String) -> void:
	if id in _entries:
		return
	_entries.append(id)
	entry_added.emit(id)


## Called by DialogueManager for every flag a node or choice sets. Records an
## entry when the flag is canonical and truthy. A flag set to false (e.g. the
## "keep it quiet" branch writing trusted_edith = false) records nothing, since
## the entry id is the flag name and there is no separate id for the negative.
func record_flag(name: String, value: Variant) -> void:
	if name in CANONICAL_FLAGS and value:
		discover(name)


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
