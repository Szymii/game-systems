class_name Rarity

enum RARITY {
	COMMON = 1,
	SUPERIOR = 2,
	HEROIC = 3,
	FABLE = 4
}

static func get_rarity_color(rarity: Rarity.RARITY) -> Color:
	match rarity:
		Rarity.RARITY.COMMON:
			return Color.WHITE
		Rarity.RARITY.SUPERIOR:
			return Color.GREEN
		Rarity.RARITY.HEROIC:
			return Color.BLUE
		Rarity.RARITY.FABLE:
			return Color.GOLD
		_:
			return Color.WHITE
