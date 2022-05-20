module user

imports src/entities

entity User {
	name: String (not null, validate(!name.isNullOrEmpty(), "Required"))
	email: Email (id, not null, iderror = "Address not available", idemptyerror = "Required")
	password: Secret (not null)
	passwordResetToken: Token
	
	verified: Bool (default = false)
	verificationToken: Token
	newsletter: Bool (default = false)
	
	roles: {Role} (default = Set<Role>())
	habits: {Habit} (inverse = user, default = Set<Habit>())

	isPremium : Bool := PREMIUM in roles
	isAdmin : Bool := ADMIN in roles
	
	search mapping {
		name
		name as partialName using customAnalyzer;
		email
		email as partialEmail customAnalyzer;
	}

	cached function habitInfo() : HabitInfo {
		var longestStreak : Int := 0;
		var longestActiveStreak: Int := 0;
		var info : StreakInfo := null;
		// by accumulating I don't need a very simple query I guess
		var totalCompletions : Int := 0;
		for(h: Habit in habits){
			totalCompletions := totalCompletions + h.completions.length;
			info := h.streakInfo();
			if(info.longest > longestStreak){
				longestStreak := info.longest;
			}
			if(info.current > longestActiveStreak){
				longestActiveStreak := info.current;
			}
		}

		return HabitInfo {
			count := habits.length,
			totalCompletions := totalCompletions,
			longestStreak := longestStreak,
			longestActiveStreak := longestActiveStreak
		};
	}

	// maybe the JSON representation could be derived w/ annotations to make API development more convenient
	cached function json(): JSONObject{
		var o := JSONObject();
		o.put("id", email);
		o.put("name", name);
		o.put("email", email);
		o.put("isAdmin", isAdmin);
		o.put("isPremium", isPremium);
		o.put("verified", verified);
		o.put("newsletter", newsletter);
		// o.put("habitInfo", this.habitInfo().json());
		return o;
	}
}

analyzer customAnalyzer {
  tokenizer = StandardTokenizer 
  //tokenizer=PatternTokenizer(pattern="([a-z])", group="1")
  token filter = LowerCaseFilter
  //token filter = StopFilter()
  token filter = NGramFilter(minGramSize = "1", maxGramSize = "50")
}
