extends Node

func _ready() -> void:
	TreeGeneratorGlobals.save_tree_signal.connect(_save_tree)
	TreeGeneratorGlobals.load_tree_signal.connect(_load_tree)

func _save_tree() -> void:
	var saved_data := SavedData.new()
	saved_data.version = SavedData.CURRENT_VERSION
	get_tree().call_group("SavableTreeElements", "on_tree_save", saved_data)
	ResourceSaver.save(saved_data, "user://saved_tree_template.tres")

func _load_tree() -> void:
	var saved_data := load("user://saved_tree_template.tres") as SavedData
	if saved_data:
		# Check version and handle migrations if needed
		_check_version_and_migrate(saved_data)
		get_tree().call_group("SavableTreeElements", "on_tree_load", saved_data)

func _check_version_and_migrate(saved_data: SavedData) -> void:
	var save_version: int = saved_data.version
	print(save_version)
	
	if save_version < SavedData.CURRENT_VERSION:
		print("[SaveLoad] Detected old save version ", save_version,
			  ". Current version is ", SavedData.CURRENT_VERSION)
		
		# Future migrations can be added here
		# Example:
		# if save_version < 2:
		#     _migrate_v1_to_v2(saved_data)
		# if save_version < 3:
		#     _migrate_v2_to_v3(saved_data)
		
		# Update version after migration
		saved_data.version = SavedData.CURRENT_VERSION
		print("[SaveLoad] Migration completed. Save is now version ", SavedData.CURRENT_VERSION)
	elif save_version > SavedData.CURRENT_VERSION:
		push_warning("[SaveLoad] Save file version (", save_version,
					") is newer than current version (", SavedData.CURRENT_VERSION,
					"). Some data may not load correctly.")
