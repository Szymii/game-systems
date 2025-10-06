class_name PointSavedData
extends Resource

@export var is_starting_point: bool = false
@export var scene_path: String
@export var point_id: int
@export var point_name: String = ""
@export var position: Vector2
@export var texture_path: String
@export var texture_name: String
@export var size: PointSize.POINT_SIZE = PointSize.POINT_SIZE.SM
@export var stats: Array[PointStat] = []

# Legacy fields for backward compatibility (will be migrated to stats array)
@export var stat: Stat.STAT = Stat.STAT.DEX
@export var stat_mode: StatMode.STAT_MODE = StatMode.STAT_MODE.FLAT
@export var value: int = 0
