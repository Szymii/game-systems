class_name ItemData 
extends Resource

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i
@export var rarity: Rarity.RARITY = Rarity.RARITY.COMMON
@export var tags: Array[ItemTags.ITEM_TAGS]

# @export var item_modifiers: Array
