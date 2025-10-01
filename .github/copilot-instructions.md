# GitHub Copilot Instructions

## Code Style

- **Avoid unnecessary comments** - Write readable code instead
- **Comment only complex logic** - When the "why" isn't obvious
- **Use descriptive names** - Make code self-documenting
- **Private and public functions** - private starts with \_, public not

### Examples

```gdscript
# Bad
var health = 100  # Player health

# Good
var player_health_points = 100
```

## Project Context

- **Framework**: Godot 4.x, GDScript
- **Style**: snake_case variables, PascalCase classes

## Event Bus Pattern

Use **TreeGeneratorGlobals** as centralized event bus for all cross-component communication.

### When to use Event Bus

- ✅ Communication between different managers (GraphManager ↔ GridManager)
- ✅ UI interactions that affect multiple systems
- ✅ Global state changes (point selection, tree save/load)
- ✅ Decoupled component interactions

### When NOT to use Event Bus

- ❌ Parent-child node communication (use direct calls)
- ❌ Simple data passing within same class
- ❌ Performance-critical frequent updates

### Pattern Structure

```gdscript
# 1. Add signal to [...]Globals
signal my_action_signal(data: MyType)

# 2. Add public function to [...]Globals
func trigger_my_action(data: MyType) -> void:
    my_action_signal.emit(data)

# 3. Connect in components
[...]Globals.my_action_signal.connect(_on_my_action)

# 4. Trigger from anywhere
[...]Globals.trigger_my_action(my_data)
```

### Examples

- `spawn_point_requested_signal` - GridManager → GraphManager
- `starting_positions_changed_signal` - TreeCenter → GraphManager
- `point_selected_signal` - Point → UI components
