class_name DangerJournal
extends Node

var discovered_dangers: Dictionary = {}


# add a new danger into journal
func discover(data: DangerData) -> void:
	if data == null or data.type == &"":
		return

	if discovered_dangers.has(data.type):
		return

	discovered_dangers[data.type] = data


# get all danger datas from journal
func get_entries() -> Array[DangerData]:
	var entries: Array[DangerData] = []

	for data in discovered_dangers.values():
		entries.append(data)

	return entries
