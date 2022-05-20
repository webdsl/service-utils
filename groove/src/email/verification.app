module verification

imports src/entities

email verificationEmail(u: User){
	to(u.email)
	from("noreply@groove.app")
	subject("Verify your email")
	
	<h2>"Hi ~u.name,"</h2>
	<p>"please verify your email with this link:"</p>
	<p>navigate(verify(u.email as String, u.verificationToken.id.toString())){"Verify"}</p>
}

function sendVerificationEmail(u: User){
	u.verificationToken := Token{};
	u.save();
	email verificationEmail(u);
	message("Verification email sent successfully");
}

// given a token, verify this user or return an error message (null = success)
function verifyUser(u: User, t: Token) : String {
	if (u.verified){ return "Already verified"; }
	if (u.verificationToken != t || now().after(t.expiresAt)) { return "Verification token invalid"; }
	u.verified := true;
	u.verificationToken := null;
	u.save();
	// log this user in (if the verification is to be trusted then this is fine)
	securityContext.principal := u;
	return null;
}

// page verify(u: User, t: Token){ // doesn't work for null values per default
page verify(uid: String, tid: String){
  var error := "Invalid page arguments"
  init {
    var u : User := null;
    var t : Token := null;
    if(!uid.isNullOrEmpty() && !tid.isNullOrEmpty()){
      u := findUser(uid);
      t := loadToken(tid.parseUUID());
    }
    if(u != null && t != null){
      error := verifyUser(u, t);
    }
  }

	<h2>"Verify your email"</h2>
  
  if(error != null){
    output(error)
  } else {
    "Email successfully verified"
  }

  navigate root(){"Home"}
}

access control rules
  rule page verify(u: String, t: String){ true }