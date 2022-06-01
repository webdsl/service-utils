module auth

imports fetch
imports src/entities

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

test testLoginService {
  var d : WebDriver := getFirefoxDriver();

  var hunter2 := User{ 
		name := "hunter", 
		email := "hunter2@testuser.com", 
		password := ("hunter2" as Secret).digest()
	};
  hunter2.save();

  var body := JSONObject();
  body.put("email", hunter2.email);
  body.put("password", "hunter2");

  var options := FetchOptions()
    .set("method", "POST")
    .addHeader("Content-Type", "application/json")
    .set("body", body.toString());

  var res := fetch(d, "/mainappfile/api/currentUser", options);
  
  assert(res.getState() == "fulfilled", "Expected the request to succeed");
  assert(res.getStatus() == 200, "Expected the status to be ok");

  var resBody := JSONObject(res.getBody());
  assert(resBody.getJSONArray("errors").length() == 0);
  assert(resBody.getJSONObject("data").getString("id") == hunter2.email);
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


//test test_login {
//  var d : WebDriver := HtmlUnitDriver();
//
//  d.get(navigate(currentUserService()));
//
//  log(d.getPageSource());
//
//  assert(!d.getPageSource().contains("404"), "No 404");
//}

access control rules
  rule page loginService(){ true }
  rule page logoutService(){ true }
  rule page registerService(){ true }
  rule page currentUserService(){ true }
