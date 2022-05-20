module color

service colorsService(){
  var res := Response();
  if( isPOST() ){
    if ( loggedIn() ){
      var colors : [Color] := allowedColors();
      var json := JSONArray();
      for(c in colors){
        json.put(c.value);
      }
      return Ok(res, json);
    } else {
      return Err(res, 401, "Not authenticated");
    }
  } else {
    return Err(res, "Invalid request");
  }
}

access control rules
  rule page colorsService(){ true }