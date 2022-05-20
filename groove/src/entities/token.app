module token

entity Token {
	// already has an implicit uuid 
	// value: UUID
	expiresAt: DateTime (not null, default = now().addMinutes(30))
}