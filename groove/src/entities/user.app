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
		return o;
	}
}