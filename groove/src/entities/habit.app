module habit

imports src/entities
imports src/utils

// helper entity for streaks
entity Day {
	date: Date
	habit: Habit
	completed: Bool (default = false)
	completion: Completion (default = null)
	// used to show different svgs
	before: Bool (default = false)
	after: Bool (default = false)

	function toggle(){
		if(completed){
			completed := false;
			habit.completions.remove(completion);
			completion.delete();
			habit.save();
			completion := null;
		} else {
			var c := Completion{ habit := habit, date := date };
			habit.completions.add(c);
			c.save(); habit.save();
			completion := c;
			completed := true;
		}
	}

	cached function json(): JSONObject {
		var o := JSONObject();
		o.put("date", date.format("yyyy-MM-dd"));
		o.put("completed", completed);
		return o;
	}
}

function isValidHabitName(h: Habit): Bool {
	var sameName : [Habit] := from Habit as h where h.name = ~h.name and h.user = ~h.user limit 1;
	return sameName.length == 0 || (sameName.length == 1 && sameName[0] == h);
}

entity Habit {
	// Here the validation is a bit tricky: I want users not to be able to have two habits of the same name,
	// but two different users can have a habit with the same name, so I can not use id.
	// Adding a validation here would be the clean solution, but that did not work as expected.
	// So I left the comment in there but instead validate separately at every point where the name can be changed which is
	// a bit cumbersome.
	// UPDATE 27.03: So apparently validations can be for different crud operations, but I don't want to change things any more...
	// http://codefinder.org/viewFile/validateDelete/https%3A%5Es%5Esgithub.com%5Eswebdsl%5Eswebdsl%5Esblob%5Esmaster%5Estest%5Essucceed%5Esdata-validation%5Esinvariantscrud.app/WebDSL#1
	name: String (searchable, not null)//, validate(!name.isNullOrEmpty(), "Required"), validate(isValidHabitName(this), "You already have a habit with this name"))
	// this would make sense in a production setting, but for testing it is more convenient to take
	// the first completion as start (no completionrates > 100%)
	//start: Date (searchable, default = today(), not null)
	description: Text (searchable, default = "")
	color: Color (not null, default = randomColor(), allowed = from Color as c where c.premium = false or ~principal.isPremium = true)
	user: User (not null) // default = principal, // crashes if i want to init some habits as there is no principal...
	// maybe having ranges/streaks (basically the DateRange entity) instead of single days is more performant, but I don't want to redo it...
	// hindsight is 20/20: if this were to go into production, as the completions/stats are at the core of the app this would be the first
	// thing I would need to optimize. I think updating and collecting the stats (min/max/avg/current/total) could be done in O(1) without
	// changing too much though so thats fine for now.
	completions <> {Completion} (inverse = habit, default = Set<Completion>())
	// the current streak could be kept track of as derived property-ish
	// but modifications to the longest streak would need a re-scan of all completions anyway
	// so to keep things "simple" this is a linear pass collecting max, current and avg streak lengths
	// cached 
	function streakInfo(): StreakInfo {
		var current: DateRange := null;
		var totalStreaks: Int := 0;
		var totalStreakLength : Int := 0;
		var longestStreak :Int := 0;
		var start : Date := today();
		
		for(c: Completion in completions order by c.date asc){
			if(c.date.before(start)){ start := c.date; }
			// stat keeping for last streak
			if (current != null && current.end.addDays(1).before(c.date)){
				totalStreakLength := totalStreakLength + current.length;
				totalStreaks := totalStreaks + 1;
				if (current.length > longestStreak){
					longestStreak := current.length;
				}
				current := null;
			}
			if (current == null){ // new streak
				current := DateRange{ start := c.date, end := c.date};
			} else { // not new and not broken
				current := DateRange{ start := current.start, end := c.date};
			}
		}
		if (current != null){
			totalStreakLength := totalStreakLength + current.length;
			totalStreaks := totalStreaks + 1;
			if (current.length > longestStreak){
				longestStreak := current.length;
			}
		}
		
		var currentStreak : Int := 0;
		// if today was not yet completed, but yesterday was, then the streak is still active
		if (current != null && current.end.addDays(2).after(today())){
			currentStreak := current.length;
		}
		
		var avg: Float := 0.0;
		if(totalStreaks > 0){
			avg := totalStreakLength.floatValue() / totalStreaks.floatValue();
		}
		
		return StreakInfo {
			longest := longestStreak,
			avg := avg,
			current := currentStreak,
			completionRate := (1000.0 * (totalStreakLength.floatValue() / daysBetween(start, today()).floatValue())).round().floatValue() / 10.0
		};
	}

	// This feels stupidly inefficient but works (I think)
	function completionRange(range: DateRange): [Day] {
		var days : [Day] := List<Day>();
		var completionsInRange : [Completion] := from Completion as c where c.habit = ~this and c.date >= ~range.start and c.date <= ~range.end order by c.date asc;
		var idx : Int := 0;
		for(date : Date in range.dates()){
			var d:= Day{ date := date, habit := this };
			// check if completed
			if (idx < completionsInRange.length){
				var cur := completionsInRange.get(idx);
				if(cur.date == d.date){
					d.completed := true;
					d.completion := cur;
					if(idx + 1 < completionsInRange.length){
						d.after := cur.date.addDays(2).after(completionsInRange.get(idx+1).date);
					}
					if(idx > 0){
						d.before := completionsInRange.get(idx-1).date.addDays(2).after(cur.date);
					}
					idx := idx + 1;
				}
			}
			
			days.add(d);
		}
		return days;
	}

	cached function json(): JSONObject{
		var o := JSONObject();
		o.put("id", id);
		o.put("user", user.email);
		o.put("name", name);
		o.put("description", description);
		o.put("color", color.value);
		o.put("info", this.streakInfo().json());
		return o;
	}
}

// as opposed to loadHabit I don't want the error if not found
function findHabit(uuid: String): Habit {
  var matches := from Habit as h where h.id = ~uuid.parseUUID() limit 1;
  if ( matches.length > 0 ){
    return matches[0];
  } else {
    return null;
  }
}
