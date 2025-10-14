# Plan Implementacji - Character Loading & Level Transitions

## Architektura Docelowa

```
Root
├── GameController (autoload)
├── Global (autoload) - Event Bus
├── SavesManager (autoload)
└── Game (Main Scene)
    ├── World (Node2D)
    │   ├── Player (persists między levelami)
    │   └── CurrentLevel (zmienia się)
    └── UI (CanvasLayer)
```

---

## KROK 1: Przygotowanie Global Event Bus

### 1.1 Dodaj sygnały do `src/Globals/Global.gd`

```gdscript
# Na końcu pliku dodaj nowe sygnały:
signal game_started_signal(character_id: String)
signal level_change_requested_signal(level_path: String, spawn_id: String)
signal player_spawned_signal(player: CharacterBody2D)
```

### 1.2 Dodaj trigger functions do `src/Globals/Global.gd`

```gdscript
# Na końcu pliku dodaj funkcje:
func trigger_game_started(character_id: String) -> void:
    game_started_signal.emit(character_id)

func trigger_level_change(level_path: String, spawn_id: String = "") -> void:
    level_change_requested_signal.emit(level_path, spawn_id)

func trigger_player_spawned(player: CharacterBody2D) -> void:
    player_spawned_signal.emit(player)
```

**Rezultat:** Event Bus gotowy do komunikacji między systemami.

---

## KROK 2: Modyfikacja CharacterSelection

### 2.1 Zmień `_on_new_game_pressed()` w `src/Systems/CharacterSelection/character_selection.gd`

```gdscript
# Zastąp obecną implementację:
func _on_new_game_pressed() -> void:
    if _selected_character_id:
        Global.trigger_game_started(_selected_character_id)
```

**Rezultat:** CharacterSelection emituje sygnał zamiast bezpośrednio zmieniać sceny.

---

## KROK 3: Rozbudowa Player

### 3.1 Dodaj properties do `src/Systems/Player/player.gd`

```gdscript
# Na początku klasy, po @export:
var basic_data: BasicCharacterData
var stats_table: StatsTable
var _is_initialized: bool = false
```

### 3.2 Dodaj funkcję `initialize()` do `src/Systems/Player/player.gd`

```gdscript
# Przed _physics_process:
func initialize(data: SavedCharacterData) -> void:
    basic_data = data.basic_character_data
    stats_table = data.character_stats
    _apply_stats()
    _is_initialized = true

func _apply_stats() -> void:
    # TODO: Gdy StatsTable będzie integrowany z resztą systemu
    # movement_speed = stats_table.movement_speed
    # itp.
    pass
```

### 3.3 Dodaj Player do grupy w `src/Systems/Player/player.gd`

```gdscript
# Dodaj funkcję _ready() jeśli nie istnieje:
func _ready() -> void:
    add_to_group("player")
```

**Rezultat:** Player może być inicjalizowany danymi z zapisu.

---

## KROK 4: Przygotowanie SavesManager

### 4.1 Dodaj publiczną funkcję `load_character_data()` w `src/Systems/SavesManager/saves_manager.gd`

```gdscript
# Zmień _load_character_data() na publiczną:
func load_character_data(character_id: String) -> SavedCharacterData:
    var file_path := "user://" + character_id + ".tres"
    if not FileAccess.file_exists(file_path):
        push_error("Character data not found: " + character_id)
        return null

    var character_data := load(file_path) as SavedCharacterData
    return character_data
```

**Rezultat:** SavesManager może być używany przez GameController do ładowania danych.

---

## KROK 5: Przygotowanie Level Structure

### 5.1 Dodaj SpawnPoint do `src/Levels/Level_0.tscn`

**W edytorze Godot:**

1. Otwórz `src/Levels/Level_0.tscn`
2. Dodaj węzeł `Marker2D` jako dziecko Level_0
3. Nazwij go "SpawnPoint"
4. Ustaw pozycję (np. `position = Vector2(640, 360)`)

**Struktura:**

```
Level_0 (Node2D)
├── ColorRect (istniejący)
└── SpawnPoint (Marker2D) - NOWY
```

### 5.2 Stwórz skrypt `src/Levels/level_0.gd`

```gdscript
extends Node2D

func get_spawn_position(spawn_id: String = "") -> Vector2:
    if spawn_id.is_empty():
        var spawn = get_node_or_null("SpawnPoint")
        if spawn:
            return spawn.global_position
    else:
        var spawn = get_node_or_null("SpawnPoints/" + spawn_id)
        if spawn:
            return spawn.global_position

    return Vector2(640, 360)  # Fallback position
```

### 5.3 Przypisz skrypt do Level_0.tscn

**W edytorze:** Przypisz `level_0.gd` do głównego węzła Level_0

**Rezultat:** Każdy level wie gdzie spawnować gracza.

---

## KROK 6: Rozbudowa GameController - Core Logic

### 6.1 Dodaj zmienne do `src/game_controller.gd`

```gdscript
# Po istniejących zmiennych:
var _player: CharacterBody2D
var _current_level_path: String
```

### 6.2 Połącz sygnały w `_ready()` w `src/game_controller.gd`

```gdscript
# W funkcji _ready(), po istniejącym kodzie:
func _ready() -> void:
    Global.game_controller = self
    current_gui_scene = %MainMenu

    # DODAJ TO:
    Global.game_started_signal.connect(_on_game_started)
    Global.level_change_requested_signal.connect(_on_level_change_requested)
```

### 6.3 Dodaj nowe funkcje do `src/game_controller.gd`

```gdscript
# Na końcu pliku dodaj:

func _on_game_started(character_id: String) -> void:
    var character_data = SavesManager.load_character_data(character_id)
    if character_data == null:
        push_error("Failed to load character: " + character_id)
        return

    _spawn_player(character_data)
    _load_level("res://src/Levels/Level_0.tscn")
    clear_gui_scene()

func _spawn_player(data: SavedCharacterData) -> void:
    var player_scene = preload("res://src/Systems/Player/Player.tscn")
    _player = player_scene.instantiate()
    _player.initialize(data)

    world.add_child(_player)
    Global.trigger_player_spawned(_player)
    print("Player spawned: ", data.basic_character_data.character_name)

func _load_level(level_path: String, spawn_id: String = "") -> void:
    # Usuń poprzedni level jeśli istnieje
    if current_world_scene:
        world.remove_child(current_world_scene)
        current_world_scene.queue_free()

    # Załaduj nowy level
    var level = load(level_path).instantiate()
    world.add_child(level)
    current_world_scene = level
    _current_level_path = level_path

    # Pozycjonuj gracza
    _position_player_at_spawn(spawn_id)
    print("Level loaded: ", level_path)

func _position_player_at_spawn(spawn_id: String = "") -> void:
    if not _player or not current_world_scene:
        return

    if current_world_scene.has_method("get_spawn_position"):
        _player.global_position = current_world_scene.get_spawn_position(spawn_id)
    else:
        var spawn = current_world_scene.get_node_or_null("SpawnPoint")
        if spawn:
            _player.global_position = spawn.global_position
        else:
            _player.global_position = Vector2(640, 360)  # Fallback

    print("Player positioned at: ", _player.global_position)

func _on_level_change_requested(level_path: String, spawn_id: String) -> void:
    _load_level(level_path, spawn_id)
```

**Rezultat:** GameController orkiestruje cały flow gry od wyboru postaci do spawnu w levelu.

---

## KROK 7: Testing Flow

### 7.1 Test podstawowego flow

1. **Uruchom grę** (F5)
2. **W Main Menu:** Kliknij "Character Selection"
3. **Wybierz postać** (jeśli nie masz, stwórz nową)
4. **Kliknij "New Game"**

### 7.2 Oczekiwane rezultaty

✅ **W konsoli powinny pojawić się:**

```
Player spawned: [Nazwa postaci]
Level loaded: res://src/Levels/Level_0.tscn
Player positioned at: Vector2(x, y)
```

✅ **W grze:**

- Menu znika
- Level_0 się ładuje
- Player pojawia się na spawn point
- Możesz sterować Playerem (WASD/strzałki)

### 7.3 Troubleshooting

**Problem:** Player się nie pojawia

- Sprawdź czy SpawnPoint jest w Level_0
- Sprawdź konsole pod kątem błędów
- Zweryfikuj czy `_player` nie jest null

**Problem:** "Failed to load character"

- Sprawdź czy postać została zapisana przez SavesManager
- Sprawdź `user://` folder (Project → Open User Data Folder)

**Problem:** Player nie reaguje na input

- Sprawdź czy Player.gd ma kod movement w `_physics_process()`
- Sprawdź Input Map w Project Settings

---

## KROK 8: Level Transitions (Portal System)

### 8.1 Stwórz Portal scene `src/Common/Portal.tscn`

**Struktura:**

```
Portal (Area2D)
├── CollisionShape2D (RectangleShape2D lub CircleShape2D)
└── Sprite2D (opcjonalnie - wizualizacja portalu)
```

### 8.2 Stwórz skrypt `src/Common/portal.gd`

```gdscript
extends Area2D

@export var target_level_path: String = "res://src/Levels/Level_1.tscn"
@export var target_spawn_id: String = ""
@export var is_active: bool = true

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not is_active:
        return

    if body.is_in_group("player"):
        Global.trigger_level_change(target_level_path, target_spawn_id)
```

### 8.3 Przypisz skrypt do Portal.tscn

**W edytorze:** Przypisz `portal.gd` do głównego węzła Portal

### 8.4 Dodaj Portal do Level_0.tscn

**W edytorze:**

1. Otwórz `src/Levels/Level_0.tscn`
2. Instancjonuj `Portal.tscn` jako dziecko Level_0
3. Ustaw pozycję portalu
4. W Inspectorze ustaw:
   - `target_level_path`: `"res://src/Levels/Level_1.tscn"` (gdy stworzysz Level_1)
   - `target_spawn_id`: `"entrance_from_level0"`

**Rezultat:** System portali gotowy do użycia.

---

## KROK 9: Physics Layers Setup (Opcjonalnie)

### 9.1 Skonfiguruj Layer Names

**Project → Project Settings → Layer Names → 2D Physics:**

- Layer 1: "Player"
- Layer 2: "Enemies"
- Layer 3: "Environment"
- Layer 4: "Interactables"

### 9.2 Player collision setup

**W `src/Systems/Player/Player.tscn`:**

- `collision_layer`: Zaznacz tylko "Player" (Layer 1)
- `collision_mask`: Zaznacz "Environment" i "Interactables" (Layer 3, 4)

### 9.3 Portal collision setup

**W `src/Common/Portal.tscn`:**

- `collision_layer`: Zaznacz tylko "Interactables" (Layer 4)
- `collision_mask`: Zaznacz tylko "Player" (Layer 1)

**Rezultat:** Czysta separacja collision detection między systemami.

---

## KROK 10: Stworzenie Level_1 (Dla testowania transitions)

### 10.1 Duplikuj Level_0

1. W FileSystem: Kliknij PPM na `Level_0.tscn`
2. Wybierz "Duplicate"
3. Nazwij: `Level_1.tscn`

### 10.2 Zmodyfikuj Level_1

**W edytorze:**

1. Zmień kolor ColorRect na inny (żeby odróżnić levele)
2. Dodaj dodatkowy SpawnPoint:
   - Dodaj Node2D o nazwie "SpawnPoints"
   - Jako dziecko dodaj Marker2D o nazwie "entrance_from_level0"
3. Dodaj Portal prowadzący z powrotem do Level_0

**Struktura:**

```
Level_1 (Node2D)
├── ColorRect (inny kolor)
├── SpawnPoint (domyślny spawn)
├── SpawnPoints (Node2D)
│   └── entrance_from_level0 (Marker2D)
└── Portal (prowadzi do Level_0)
```

### 10.3 Stwórz skrypt level_1.gd

```gdscript
extends Node2D

func get_spawn_position(spawn_id: String = "") -> Vector2:
    if spawn_id.is_empty():
        var spawn = get_node_or_null("SpawnPoint")
        if spawn:
            return spawn.global_position
    else:
        var spawn = get_node_or_null("SpawnPoints/" + spawn_id)
        if spawn:
            return spawn.global_position

    return Vector2(640, 360)
```

**Rezultat:** Masz drugi level do testowania transitions.

---

## KROK 11: Final Testing

### 11.1 Pełny test flow

1. Uruchom grę
2. Wybierz/Stwórz postać
3. Kliknij "New Game"
4. **Sprawdź:** Player spawns w Level_0
5. Podejdź do Portalu
6. **Sprawdź:** Przejście do Level_1
7. **Sprawdź:** Player spawns przy "entrance_from_level0"
8. Podejdź do Portalu powrotnego
9. **Sprawdź:** Powrót do Level_0

### 11.2 Sprawdź persistence

**Ważne:** Po przejściu między levelami:

- Player powinien zachować te same statystyki
- `basic_data` i `stats_table` nie powinny się resetować
- Możesz dodać temporary print w Player.\_physics_process():
  ```gdscript
  if Input.is_action_just_pressed("ui_accept"):
      print("Character: ", basic_data.character_name if basic_data else "Not initialized")
  ```

---

## Podsumowanie Implementacji

| Krok | Komponent          | Czas   | Priorytet        |
| ---- | ------------------ | ------ | ---------------- |
| 1    | Global Event Bus   | 5 min  | ⭐⭐⭐ Krytyczny |
| 2    | CharacterSelection | 2 min  | ⭐⭐⭐ Krytyczny |
| 3    | Player             | 10 min | ⭐⭐⭐ Krytyczny |
| 4    | SavesManager       | 3 min  | ⭐⭐⭐ Krytyczny |
| 5    | Level Setup        | 5 min  | ⭐⭐⭐ Krytyczny |
| 6    | GameController     | 15 min | ⭐⭐⭐ Krytyczny |
| 7    | Testing            | 10 min | ⭐⭐⭐ Krytyczny |
| 8    | Portal System      | 15 min | ⭐⭐ Ważny       |
| 9    | Physics Layers     | 10 min | ⭐ Opcjonalny    |
| 10   | Level_1            | 10 min | ⭐⭐ Testowanie  |
| 11   | Final Testing      | 15 min | ⭐⭐⭐ Krytyczny |

**Łączny czas:** ~1.5-2 godziny

---

## Kolejność Implementacji (Recommended)

### Faza 1: Core System (Kroki 1-7)

- Zaimplementuj podstawowy flow od wyboru postaci do spawnu w levelu
- **Po tej fazie:** Powinieneś móc wybrać postać i zagrać w Level_0

### Faza 2: Transitions (Kroki 8-10)

- Dodaj system portali i drugi level
- **Po tej fazie:** Możesz poruszać się między levelami

### Faza 3: Polish (Krok 9, 11)

- Dopracuj collision layers
- Finalne testy

---

## Przyszłe Rozszerzenia (TODO)

- [ ] Auto-save przy przejściach między levelami
- [ ] Fade transitions (płynne przejścia)
- [ ] Loading screen dla dużych levelów
- [ ] Death/Respawn system
- [ ] Checkpoint system
- [ ] Fast travel / World map
- [ ] Multiplayer support (gracze w tym samym World)

---

## Troubleshooting

### Player nie pojawia się w levelu

- Sprawdź czy `world` node istnieje w Game.tscn
- Sprawdź czy `_spawn_player()` się wywołuje (dodaj print)
- Zweryfikuj ścieżkę do Player.tscn

### Level się nie ładuje

- Sprawdź ścieżki do levelów (czy są poprawne)
- Sprawdź czy level ma przypisany skrypt z `get_spawn_position()`

### Portal nie działa

- Sprawdź czy Player ma grupę "player"
- Sprawdź collision layers (Portal musi wykrywać Layer 1)
- Sprawdź czy CollisionShape2D ma kształt (shape)

### "Failed to load character"

- Sprawdź czy SavesManager zapisał plik w `user://`
- Otwórz "Project → Open User Data Folder" i poszukaj pliku `.tres`
- Sprawdź czy `character_id` jest poprawny

---

## Kontakt z Kodem

Jeśli coś nie działa:

1. Sprawdź konsole pod kątem błędów (czerwony tekst)
2. Dodaj debug printy w kluczowych miejscach
3. Użyj debuggera Godot (breakpointy)
4. Sprawdź czy wszystkie sceny są zapisane

---

**Powodzenia z implementacją! 🚀**
