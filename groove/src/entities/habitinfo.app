module habitinfo

entity HabitInfo {
	count: Int
	totalCompletions: Int
	longestStreak: Int
	longestActiveStreak: Int

	cached function json(): JSONObject{
		var o := JSONObject();
		o.put("count", count);
		o.put("totalCompletions", totalCompletions);
		o.put("longestStreak", longestStreak);
		o.put("longestActiveStreak", longestActiveStreak);
		return o;
	}
}