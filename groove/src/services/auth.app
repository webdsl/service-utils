module auth

imports src/services/utils
imports src/email

// req body
// {
//  "email": String,
//  "password": String,
//  "stayLoggedIn": Boolean, (optional)
// }
service loginService(){
  var res := Response();
  if( isPOST() ){
    var req := Request(res);
    if( isOk(res) ){
      var email := expectString(req, res, "email");
      var password := expectString(req, res, "password");
      var stayLoggedIn := optionalBool(req, "stayLoggedIn", false);

      if ( isOk(res) ){
        if( authenticate(email, password) ){
          getSessionManager().stayLoggedIn := stayLoggedIn;

          return Ok(res, principal.json());
        } else {
          return Err(res, 401, "Invalid credentials");
        }
      } else {
        return res;
      }
    } else {
      return res;
    }
  } else {
    return Err(res, "Invalid request");
  }
}

service logoutService(){
  var res := Response();
  if( isPOST() ){
    if( loggedIn() ){
      securityContext.principal := null;

      return Ok(res, null as JSONObject);
    } else {
      return Err(res, 401, "Not authenticated");
    }
  } else {
    return Err(res, "Invalid request");
  }
}

// req body
// {
//  "name": String
//  "email": String,
//  "password": String,
//  "newsletter": Boolean, (optional)
// }
service registerService(){
  var res := Response();
  if( isPOST() ){
    var req := Request(res);
    if( isOk(res) ){
      var name := expectString(req, res, "name");
      var email := expectString(req, res, "email");
      var password := expectString(req, res, "password");
      var newsletter := optionalBool(req, "newsletter", false);

      if ( isOk(res) ){
        var u := User {
          name := name
          email := email
          password := (password as Secret).digest()
          verified := false
          newsletter := newsletter
        };
        u.save();

        if( isOk(res, u.validateSave()) ){
          securityContext.principal := u;
          sendVerificationEmail(u);
          return Ok(res, u.json());
        } else {
          return res;
        }
      } else {
        return res;
      }
    } else {
      return res;
    }
  } else {
    return Err(res, "Invalid request");
  }
}

service currentUserService(){
  var res := Response();
  if( isPOST() ){
    if ( loggedIn() ){
      return Ok(res, principal.json());
    } else {
      return Err(res, 401, "Not authenticated");
    }
  } else {
    return Err(res, "Invalid request");
  }
}

access control rules
  rule page loginService(){ true }
  rule page logoutService(){ true }
  rule page registerService(){ true }
  rule page currentUserService(){ true }
