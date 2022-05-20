module habit

imports src/services/utils
imports src/entities

// service to find all habits of a user
service habitsService(){
  var res := Response();
  if( isPOST() ){
    if ( loggedIn() ){
      var habits := JSONArray();
      for(h in from Habit as h where h.user = ~principal){
        habits.put(h.json());
      }

      return Ok(res, habits);
    } else {
      return Err(res, 401, "Not authenticated");
    }
  } else {
    return Err(res, "Invalid request");
  }
}

// service for a single habit
service habitService(){
  var res := Response();
  if( isPOST() ){
    if ( loggedIn() ){
      var req := Request(res);
      if( isOk(res) ){
        case( requestMethod(req) ){

          "QUERY" { // id -> habit
            var habitId : String := expectString(req, res, "id");
            if ( isOk(res) ){
              var habit : Habit := findHabit(habitId);
              if ( habit != null && habit.user == principal ){
                return Ok(res, habit.json());
              } else {
                return Err(res, 404, "Habit \"~habitId\" not found");
              }
            } else {
              return res;
            }
          }


          "CREATE" { // data => new habit
            var name := expectString(req, res, "name");
            var description := optionalString(req, "description", "");
            var color := optionalColor(req, "color", randomColor());

            if( isOk(res) ){
              if ( color.premium && !principal.isPremium ) {
                return Err(res, "Invalid color");
              } else if( (from Habit as h where h.name = ~name and h.user = ~principal limit 1).length == 0 ) {
                var habit := Habit { 
                  name := name, 
                  description := description, 
                  color := color, 
                  user := principal
                };
                habit.save();
    
                if( isOk(res, habit.validateSave()) ){
                  return Ok(res, habit.json());
                } else {
                  return res;
                }
              } else {
                return Err(res, "Habit with name \"~name\" already exists");
              }
            } else {
              return res;
            }
          }


          "UPDATE" { // id + partial habit -> updated habit
            var habitId : String := expectString(req, res, "id");
            if ( isOk(res) ){
              var habit : Habit := findHabit(habitId);
              if ( habit != null && habit.user == principal ){

                var newName := optionalString(req, "name", habit.name);
                var color := optionalColor(req, "color", habit.color);
                
                if( color.premium && !principal.isPremium ) {
                  return Err(res, "Invalid color");
                } else if( habit.name == newName || (from Habit as h where h.name = ~newName and h.user = ~principal limit 1).length == 0 ){
                  habit.name := newName;
                  habit.color := color;
                  habit.description := optionalString(req, "description", habit.description);
                  habit.save();

                  if( isOk(res, habit.validateSave()) ){
                    return Ok(res, habit.json());
                  } else {
                    return res;
                  }
                } else {
                  return Err(res, "Habit with name \"~newName\" already exists");
                }
              } else {
                return Err(res, 404, "Habit \"~habitId\" not found");
              }
            } else {
              return res;
            }
          }


          "DELETE" { // id -> delete
            var habitId : String := expectString(req, res, "id");
            if ( isOk(res) ){
              var habit : Habit := findHabit(habitId);
              if ( habit != null && habit.user == principal ){
                principal.habits.remove(habit);
                principal.save();

                if( isOk(res, principal.validateSave()) ){
                  return Ok(res, null as JSONObject);
                } else {
                  return res;
                }
              } else {
                return Err(res, 404, "Habit \"~habitId\" not found");
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
  rule page habitService(){ true }
  rule page habitsService(){ true }
