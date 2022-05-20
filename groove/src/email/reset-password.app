module reset-password

imports src/entities

email passwordResetEmail(u: User){
	to(u.email)
	from("noreply@groove.app")
	subject("Reset your password")
	
	<h2>"Hi ~u.name,"</h2>
	<p>"you can reset your password with this link:"</p>
  <p>navigate(resetPassword(u.email as String, u.passwordResetToken.id.toString())){"Reset password"}</p>
}

function sendPasswordResetEmail(email: Email){
	var u : User := findUser(email);
	if (u != null){
		u.passwordResetToken := Token{};
		u.save();
		email passwordResetEmail(u);
	}
	// give no info about the email actually being in the system
	message("Reset link sent to your email address");
}

// given a token, verify this user or return an error message (null = success)
function canResetPassword(u: User, t: Token) : String {
	if (u.passwordResetToken != t || now().after(t.expiresAt)) { return "Verification token invalid"; }
	return null;
}

page requestReset(){
	var email : Email := ""
	
	action requestReset(){
		sendPasswordResetEmail(email);
		refresh();
	}

  <h2>Request password reset</h2>
  input(email)[placeholder="Email"]
	submit requestReset(){ "Request reset" }
}

// page resetPassword(u: User, t: Token){ // doesn't work for null values per default
page resetPassword(uid: String, tid: String){
  var u : User := null;
  var t : Token := null;
  var error := "Invalid page arguments"
  init {
    if(!uid.isNullOrEmpty() && !tid.isNullOrEmpty()){
      u := findUser(uid);
      t := loadToken(tid.parseUUID());
    }
    if(u != null && t != null){
      error := canResetPassword(u, t);
    }
  }

  var password : Secret := ""
	var repeatPassword : Secret := ""
	
	action resetPassword() {
		u.password := password.digest();
		u.passwordResetToken := null;
		// log this user in (if the verification is to be trusted then this is fine)
		securityContext.principal := u;
		u.save();
		message("Password reset successful");
	  return root();
	}
	
	<h2>"Reset your password"</h2>
		  		
	if (error == null){
	  <label>"Password"</label>
    inputajax(password)[type="password", class="input input-bordered"] {
      validate(password.length() >= 8, "Password needs to be at least 8 characters")
      validate(/[a-z]/.find(password), "Password must contain a lower-case character")
      validate(/[A-Z]/.find(password), "Password must contain an upper-case character")
      validate(/[0-9]/.find(password), "Password must contain a digit")
    }
    
    <label>"Repeat Password"</label>
    inputajax(repeatPassword)[type="password", class="input input-bordered"] {
      validate(repeatPassword == password, "Passwords must match")
    }
    
    submit resetPassword(){ "Reset password" }
  
  } else {
    output(error)
  }
  navigate root()[]{"Home"}
}

access control rules
  rule page requestReset(){ true }
  rule page resetPassword(u: String, t: String){ true }