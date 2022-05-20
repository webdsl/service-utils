module completion

imports src/services/utils
imports src/entities

// get all completions (but different format than entities...)
service completionsService(){
  var res := Response();
  if( isPOST() ){
    if( loggedIn() ){
      var req := Request(res);
      if( isOk(res) ){

        var habitId : String := expectString(req, res, "habit");
        var start : Date := expectDate(req, res, "start");
        var end : Date := expectDate(req, res, "end");

        if ( isOk(res) && !start.after(end)){ // can be same day 
          var habit : Habit := findHabit(habitId);
          if ( habit != null && habit.user == principal ){
            var arr := JSONArray();
            for(d in habit.completionRange(DateRange{ start := start, end := end })){
              arr.put(d.json());
            }
            return Ok(res, arr);
          } else {
            return Err(res, 404, "Habit \"~habitId\" not found");
          }
        } else {
          return res;
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

service completionService(){
  var res := Response();
  if( isPOST() ){
    if ( loggedIn() ){
      var req := Request(res);
      if( isOk(res) ){
        case( requestMethod(req) ){

          "QUERY" { // habit + day -> completion
            var habitId : String := expectString(req, res, "habit");
            var date : Date := expectDate(req, res, "date");

            if ( isOk(res)){
              var habit : Habit := findHabit(habitId);
              if ( habit != null && habit.user == principal ){
                var candidates : [Completion] := from Completion as c where c.habit = ~habit and c.date = ~date limit 1;
      
                var c := JSONObject();
                c.put("date", date.format("yyyy-MM-dd"));
                c.put("completed", candidates.length > 0);
                return Ok(res, c);
              } else {
                return Err(res, 404, "Habit \"~habitId\" not found");
              }
            } else {
              return res;
            }
          }

          "UPDATE" { // habit + day + completed -> completion
            var habitId : String := expectString(req, res, "habit");
            var date : Date := expectDate(req, res, "date");
            var completed : Bool := expectBool(req, res, "completed");
      
            if ( isOk(res)){
              var habit : Habit := findHabit(habitId);
              if ( habit != null && habit.user == principal ){
                // completion id not necessarily accurate and plain lookup would need date/habit verification anyway
                var candidates : [Completion] := from Completion as c where c.habit = ~habit and c.date = ~date limit 1;
      
                if ( (completed && candidates.length == 0) || (!completed && candidates.length > 0) ) {
                  if( completed ){
                    habit.completions.add(Completion{ habit := habit, date := date});
                  } else {
                    habit.completions.remove(candidates[0]);
                  }
      
                  habit.save();
                  isOk(res, habit.validateSave());
                }
                
                if ( isOk(res) ){
                  var c := JSONObject();
                  c.put("date", date.format("yyyy-MM-dd"));
                  c.put("completed", completed);
                  return Ok(res, c);
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
  rule page completionsService(){ true }
  rule page completionService(){ true }
