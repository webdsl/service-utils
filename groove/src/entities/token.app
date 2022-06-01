module token

/// A token used for resetting passwords or verifying emails
/// Contains an UUID id and an expiry DateTime (default: 30minutes).
entity Token {
	expiresAt: DateTime (not null, default = now().addMinutes(30))
}