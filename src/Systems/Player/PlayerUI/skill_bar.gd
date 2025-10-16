class_name SkillBar
extends Panel

@onready var slot_1: TextureRect = %Slot1
@onready var slot_2: TextureRect = %Slot2
@onready var slot_3: TextureRect = %Slot3
@onready var slot_4: TextureRect = %Slot4
@onready var slot_5: TextureRect = %Slot5
@onready var slot_6: TextureRect = %Slot6
@onready var slot_7: TextureRect = %Slot7

var _skills: Array[SkillResource] = [null, null, null, null, null, null, null]

func _get_slots() -> Array[TextureRect]:
	return [slot_1, slot_2, slot_3, slot_4, slot_5, slot_6, slot_7]

func _find_slot_at_position(at_position: Vector2) -> int:
	var slots := _get_slots()
	for i in range(slots.size()):
		var slot := slots[i]
		var slot_rect := Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(at_position + global_position):
			return i
	return -1

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is SkillResource

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not data is SkillResource:
		return
	
	var skill: SkillResource = data
	var slot_index := _find_slot_at_position(at_position)
	
	if slot_index >= 0 and slot_index < _skills.size():
		_skills[slot_index] = skill
		var slots := _get_slots()
		slots[slot_index].texture = skill.skill_icon
