class_name SavedData
extends Resource

const CURRENT_VERSION: int = 2

@export var version: int
@export var points: Array[PointSavedData] = []
@export var connections: Array[ConnectionLineSaveData] = []
@export var tree_center: TreeCenterSavedData
