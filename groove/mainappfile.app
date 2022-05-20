application groove

imports src/auth
imports src/entities
imports src/services

init {
  var adminUser := User{ 
		name := "admin", 
		email := "admin@app.com", 
		password := ("123" as Secret).digest(), 
		verified := false,
		newsletter := true,
		roles := {PREMIUM, ADMIN}
	};

	var grooveHabit := Habit{ name := "Groove", user := adminUser, color := teal };
	adminUser.habits.add(grooveHabit);
	adminUser.save();

	var proUser := User{ 
		name := "Jane Doe", 
		email := "pro@example.com", 
		password := ("123" as Secret).digest(), 
		verified := false,
		newsletter := true,
		roles := {PREMIUM}
	};
	proUser.save();

	var plebUser := User{ 
		name := "John Doe", 
		email := "doe@example.com", 
		password := ("123" as Secret).digest(), 
		verified := false,
		newsletter := true
	};
	plebUser.save();
}

page root(){
	"Nothing to see here"
}

access control rules
	rule page root(){ true }