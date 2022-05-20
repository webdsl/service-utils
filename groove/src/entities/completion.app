module completion

imports src/entities

entity Completion {
	habit: Habit (not null)
	date: Date

	cached function json(): JSONObject{
		var o := JSONObject();
		o.put("id", id);
		o.put("habit", habit.id);
		o.put("date", javaToJsDate(date));
		return o;
	}
}