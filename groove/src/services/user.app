module user

imports src/entities
imports src/email
imports src/services/utils

service usersService(){
  var res := Response();
  if( isPOST() ){
    if( loggedIn() ){
      if( principal.isAdmin ){
        var req := Request(res);
        if( isOk(res) ){
          case( requestMethod(req) ){
            "QUERY" {
              var arr := JSONArray();
              for(u : User in from User){
                arr.put(u.json());
              }
              return Ok(res, arr);
            }
            default { return Err(res, "Invalid request method"); }
          }
        } else {
          return res;
        }
      } else {
        return Err(res, 403, "Not authorized");
      }
    } else {
      return Err(res, 401, "Not authenticated");
    }
  } else {
    return Err(res, "Invalid request");
  }
}

service userService(){
  var res := Response();
  if( isPOST() ){
    if( loggedIn() ){
      var req := Request(res);
      if( isOk(res) ){

        case( requestMethod(req) ){
          // "CREATE" // not needed, done by register endpoint
          // "QUERY"  // not needed, only currentUserService used
          "UPDATE" {  // update + return new user
            var userId := expectString(req, res, "id");

            if( isOk(res) ){
              var user := findUser(userId);
              if( user != null ){
                if( principal == user || principal.isAdmin ){

                  var name := optionalString(req, "name", null);
                  if( !name.isNullOrEmpty() ){ user.name := name; }

                  var emailChanged := false;
                  var email : Email := optionalString(req, "email", null) as Email;
                  if( !email.isNullOrEmpty() && email != user.email ){
                    if(!email.isValid()){
                      return Err(res, "Invalid email");
                    } else {
                      // db handles id errors so that should be fine
                      user.email := email;
                      emailChanged := true;
                    }
                  }

                  var password := optionalString(req, "password", null) as Secret;
                  if( !password.isNullOrEmpty() ){
                    // we don't really care about password validation here :)
                    user.password := password.digest();
                  }

                  var newsletter := optionalBool(req, "newsletter", user.newsletter);
                  user.newsletter := newsletter;

                  // we only allow promoting, not demoting...
                  var isPremium := optionalBool(req, "isPremium", false);
                  if( isPremium ){
                    if( principal.isAdmin ){
                      user.roles.add(PREMIUM);
                    } else {
                      return Err(res, 403, "Not authorized");
                    }
                  }
                  var isAdmin := optionalBool(req, "isAdmin", false);
                  if( isAdmin ){
                    if( principal.isAdmin ){
                      user.roles.add(ADMIN);
                    } else {
                      return Err(res, 403, "Not authorized");
                    }
                  }

                  user.save();

                  if( isOk(res, user.validateSave()) ){
                    if( emailChanged ){
                      sendVerificationEmail(user);
                    }
                    return Ok(res, user.json());
                  } else {
                    return res;
                  }
                } else {
                  return Err(res, 403, "Not authorized");
                }
              } else {
                return Err(res, 404, "User not found");
              }
            } else {
              return res;
            }
          }
          "DELETE" {  // delete + return nothing
            var userId := expectString(req, res, "id");

            if( isOk(res) ){
              var user := findUser(userId);
              if( user != null ){
                if( principal == user || principal.isAdmin ){
                  
                  // weirldy here I need to manually unlink the habits
                  // and in the WebDSL app it seemed to work out of the box?
                  for(h: Habit in user.habits){
                    user.habits.remove(h);
                  }
                  user.delete();
                  return Ok(res, null as JSONObject);

                } else {
                  return Err(res, 403, "Not authorized");
                }
              } else {
                return Err(res, 404, "User not found");
              }
            } else {
              return res;
            }
          }
          default { return Err(res, "Invalid request method"); }
        }
      } else {
        return res;
      }
    } else {
      return Err(res, 401, "Not authenticated");
    }
  } else {
    return Err(res, "Invalid request");
  }
}

access control rules
  // so here I tried using the built-in access control
  // it kind of works but sometimes one gets back HTML
  // and a unexpected < at position 0 in JSON body...
  rule page usersService(){ loggedIn() && principal.isAdmin }
  rule page userService(){ loggedIn() }