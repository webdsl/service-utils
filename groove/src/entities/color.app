module color

entity Color {
	value: String (id, not null)
	premium: Bool (default = false, not null)
}

var red:     Color := Color{ value := "#ef4444" }
var orange:  Color := Color{ value := "#f97316" }
var amber:   Color := Color{ value := "#f59e0b", premium := true }
var yellow:  Color := Color{ value := "#facc15" }
var lime:    Color := Color{ value := "#84cc16", premium := true }
var green:   Color := Color{ value := "#22c55e" }
var emerald: Color := Color{ value := "#10b981", premium := true }
var teal:    Color := Color{ value := "#14b8a6" }
var cyan:    Color := Color{ value := "#06b6d4", premium := true }
var sky:     Color := Color{ value := "#0ea5e9" }
var blue:    Color := Color{ value := "#3b82f6", premium := true }
var indigo:  Color := Color{ value := "#6366f1" }
var violet:  Color := Color{ value := "#8b5cf6", premium := true }
var purple:  Color := Color{ value := "#a855f7", premium := true }
var fuchsia: Color := Color{ value := "#d946ef", premium := true }
var pink:    Color := Color{ value := "#ec4899", premium := true }
var rose:    Color := Color{ value := "#f43f5e", premium := true }

function allowedColors(): [Color] {
  if ( !loggedIn() ) {
    return List<Color>();
  } else if( principal.isPremium ){
    return from Color;
  } else {
    return from Color as c where c.premium = false;
  }
}

function randomColor(): Color {
	var colors : [Color] := from Color as c where c.premium = false;
	return colors.random();
}