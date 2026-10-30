extends Node
## Journal — discovered-logs system.
##
## Autoloaded as `Journal` (see project.godot). DialogueManager reports every
## set_flag here; canonical flags set truthy become discovered entries, keyed by
## the flag name. Entries persist through GameState's save/load and are wiped
## on New Game. JournalReader (scripts/journal_reader.gd) renders them.

signal entry_added(id: String)

## The canonical narrative flags from narrative/flags-and-branches.md. Only these
## produce journal entries; incidental or debug flags are ignored.
const CANONICAL_FLAGS: Array[String] = [
	"skeptic",
	"believer",
	"trusted_edith",
	"radioed_tom",
]

## Display text per entry id, rendered by JournalReader. Ids are the canonical
## flag names above. Written in the keeper's voice, first person, as notes made
## after the fact. DRAFT (2026-10-30): review and revise before launch.
const ENTRY_TEXT: Dictionary = {
	"skeptic": {
		"title": "Edith's last page",
		"body": "Third night of fog, she wrote. A light off the north rocks that answered hers — three flashes, then dark, keeping her rhythm. Not the buoy. Not a ship. She told no one, because there was no one to tell.\n\nShe meant to row out and meet it. Relight the lamp first, she said, so whoever came next could find the way back. That was eleven days ago. The dinghy is gone from the boathouse and the lamp above me is cold.\n\nFog does strange work on a person alone. Eleven days of it, no voice but the radio, and the radio off. I want that to be all this is. I'll keep the light and keep my head, and I won't go looking for lights that answer.\n\nThe handwriting gets smaller toward the bottom of the page. I noticed that. I'm choosing not to think about it.",
	},
	"believer": {
		"title": "Edith's last page",
		"body": "Third night of fog, she wrote. A light off the north rocks that answered hers — three flashes, then dark, keeping her rhythm. Not the buoy. Not a ship. She told no one, because there was no one to tell.\n\nShe meant to row out and meet it. Relight the lamp first, she said, so whoever came next could find the way back. That was eleven days ago. The dinghy is gone from the boathouse and the lamp above me is cold.\n\nI believe her. I read it twice and I believe her. She was a keeper for longer than I've been anything, and she knew a buoy from a ship from a light that keeps time. Whatever it was, it was out there, and it was answering.\n\nShe relit nothing. Or she did, and it went out again after. I don't know which is worse. I'll find out tonight, when the fog comes back.",
	},
	"trusted_edith": {
		"title": "Told the mainland",
		"body": "I decided this isn't mine to keep. A keeper is missing, a boat is missing, and the last thing she wrote was a plan. Someone on shore should know that much, whatever they make of the rest.\n\nTom Salish ran her last supply out here. If anyone will take this seriously, it's him. If anyone will tell me I'm being a fool, it's also him. Either way I'd rather hear it than stand up here with it alone.\n\nShe told no one. I'm not going to make the same choice. That might be the only thing I've decided so far that I'm sure about.",
	},
	"radioed_tom": {
		"title": "Salish, on the mainland",
		"body": "Raised Tom Salish on the set. Mainland side — he runs the supply boat out here, ran Edith's for however long she kept this light. He said it took me long enough to switch the radio on. Fair.\n\nWeather turns by the weekend. He'll bring the next supply Thursday if the water lets him. Thursday, then. Something to count toward.\n\nOn Edith: the line went quiet before he answered. He said she wouldn't come down to the dock the last time — just waved from the gallery. And he said if I find anything in that logbook I'm to tell him first. Not the county. Him.\n\nI don't know what he thinks is in it. I don't know what he's afraid is in it. I'll keep the kettle on and the light steady, like he said, and I'll remember that he asked.",
	},
}

var _entries: Array[String] = []


## Title for an entry id, falling back to the id itself for unknown entries.
func title_for(id: String) -> String:
	return str(ENTRY_TEXT.get(id, {}).get("title", id))


## Body text for an entry id. Unknown ids get a visible placeholder rather than
## an empty panel, so a missing ENTRY_TEXT row is obvious in play.
func body_for(id: String) -> String:
	return str(ENTRY_TEXT.get(id, {}).get("body", "(no entry text for '%s')" % id))


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
