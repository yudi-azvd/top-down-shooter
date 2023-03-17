# Notas

## Detectar segurando mouse

```py
# https://godotengine.org/qa/77484/how-do-i-detect-holding-down-the-mouse
if event is InputEventMouseButton:
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if weapon_state != WeaponState.RELOAD and weapon_state != WeaponState.MELEE:
			if weaponManager.shoot():
				weapon_state = WeaponState.SHOOT
				_play_sfx_handgun_shot()
```
