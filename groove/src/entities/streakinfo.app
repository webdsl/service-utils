module streakinfo

entity StreakInfo {
	longest: Int
	avg: Float
	current: Int
	completionRate: Float

	cached function json(): JSONObject{
		var o := JSONObject();
		o.put("longest", longest);
		o.put("avg", avg);
		o.put("current", current);
		o.put("completionRate", completionRate);
		return o;
	}
}