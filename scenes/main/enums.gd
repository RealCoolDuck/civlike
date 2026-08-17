class_name Enums

enum UnitType {
	SWORDSMAN,
	ARCHER,
	PIKEMAN
}

const UNIT_TYPE_TO_STRING: Dictionary[UnitType, String] = {
	UnitType.SWORDSMAN: "Swordsmen",
	UnitType.ARCHER: "Archers",
	UnitType.PIKEMAN: "Pikemen"
}
