class_name EquipmentRules

enum SLOT_TYPE_ENUM {
	WEAPON = 1,
	SHIELD = 2,
	HELMET = 3,
	BODY_ARMOUR = 4,
	GLOVES = 5,
	BOOTS = 6,
	NECKLACE = 7,
	EARRING = 8,
	RING = 9,
	BELT = 10,
}

static func can_equip(item_data: ItemData, slot_type: SLOT_TYPE_ENUM) -> bool:
	match slot_type:
		SLOT_TYPE_ENUM.WEAPON:
			return item_data.tags.has(ItemTags.ITEM_TAGS.WEAPON)
		SLOT_TYPE_ENUM.SHIELD:
			return item_data.tags.has(ItemTags.ITEM_TAGS.WEAPON) or item_data.tags.has(ItemTags.ITEM_TAGS.SHIELD)
		SLOT_TYPE_ENUM.HELMET:
			return item_data.tags.has(ItemTags.ITEM_TAGS.HELMET)
		SLOT_TYPE_ENUM.BODY_ARMOUR:
			return item_data.tags.has(ItemTags.ITEM_TAGS.BODY_ARMOUR)
		SLOT_TYPE_ENUM.GLOVES:
			return item_data.tags.has(ItemTags.ITEM_TAGS.GLOVES)
		SLOT_TYPE_ENUM.BOOTS:
			return item_data.tags.has(ItemTags.ITEM_TAGS.BOOTS)
		SLOT_TYPE_ENUM.NECKLACE:
			return item_data.tags.has(ItemTags.ITEM_TAGS.NECKLACE)
		SLOT_TYPE_ENUM.EARRING:
			return item_data.tags.has(ItemTags.ITEM_TAGS.EARRING)
		SLOT_TYPE_ENUM.RING:
			return item_data.tags.has(ItemTags.ITEM_TAGS.RING)
		SLOT_TYPE_ENUM.BELT:
			return item_data.tags.has(ItemTags.ITEM_TAGS.BELT)
		_:
			return false
