module utils

// Supported HTTP methods are GET, HEAD, POST, PUT, TRACE, OPTIONS
// so no DELETE or PATCH -> no POST/GET/PUT/DELETE for CRUD
// HTTP response codes cannot be changed, 
// so GET 404 is resolved to pagenotfound() with status 200
// 
// Because of this, I decided to 1. do everything using POST and JSON bodys
// 2. somewhat reimplement HTTP statuses in the JSON bodys

// after using services for a bit, there seem to be many use cases which
// 1. occur often and are repeating boilerplate (e.g. retrieving JSON params)
// and 2. are somewhat boilerplate
// => I know Java JSON handling is bad, but some utilities for services would be nice
// I tried to make the usage a bit nicer with the helpers below, 
// at the end is an idea how this could be improved

function isPOST(): Bool {
  return getHttpMethod() == "POST";
}

// since it is arbitrary I choose QUERY,CREATE,UPDATE,DELETE
function requestMethod(req: JSONObject): String {
  if(req.has("_method")){
    return req.getString("_method");
  } else {
    return null;
  }
}

function optionalBool(req: JSONObject, key: String, default: Bool): Bool {
  if(req.has(key)){
    return req.getBoolean(key);
  } else {
    return default;
  }
}
function optionalString(req: JSONObject, key: String, default: String): String {
  if(req.has(key)){
    return req.getString(key);
  } else {
    return default;
  }
}
function optionalColor(req: JSONObject, key: String, default: Color): Color {
  // I'm being very explicit with if/elses since WebDSL sometimes ignores returns...
  if(req.has(key)){
    var c := findColor(req.getString(key));
    if( c != null ){
      return c;
    } else {
      return default;
    }
  } else {
    return default;
  }
}

// expects the value to be not null as well
function expectString(req: JSONObject, res: JSONObject, key: String): String {
  if(req.has(key) && req.getString(key) != null){
    return req.getString(key);
  } else {
    Err(res, "Field \"~key\" is missing");
    return null;
  }
}
function expectBool(req: JSONObject, res: JSONObject, key: String): Bool {
  if(req.has(key) && req.getBoolean(key) != null){
    return req.getBoolean(key);
  } else {
    Err(res, "Field \"~key\" is missing");
    return null;
  }
}
function expectDate(req: JSONObject, res: JSONObject, key: String): Date {
  if(req.has(key) && req.getString(key) != null){
    var value := Date(req.getString(key), "yyyy-MM-dd");
    if( value == null ){
      Err(res, "Invalid date format, expected \"yyyy-MM-dd\"");
    }
    return value;
  } else {
    Err(res, "Field \"~key\" is missing");
    return null;
  }
}

function Request(res: JSONObject): JSONObject {
  var body := readRequestBody();
  if( body.isNullOrEmpty() ){
    Err(res, "Invalid request body");
    return null;
  } else {
    return JSONObject(body);
  }
}

// hacky response building
function Response(): JSONObject {
  var res := JSONObject();
  res.put("error", JSONArray());
  res.put("data", JSONObject());
  return res;
}

function Err(res: JSONObject, err: Int, msg: String): JSONObject {
  var e := JSONObject();
  e.put("message", msg);
  e.put("status", err);
  res.getJSONArray("error").put(e);
  return res;
}

function Err(res: JSONObject, msg: String): JSONObject {
  // per default answer w/ 400
  return Err(res, 400, msg);
}

function isOk(res: JSONObject): Bool {
  return res.getJSONArray("error").length() == 0;
}

function isOk(res: JSONObject, validationResults: ValidationExceptionMultiple): Bool {
  for( ex in validationResults.exceptions ){
    rollback();
    Err(res, ex.message);
  }
  return isOk(res);
}


// according to https://webdsl.github.io/webdsl-docs/reference/services/
// has the signature JSONObject.put(String, Object) but that wouldn't compile
// so here is a fix for all types that I potentially need
function Ok(res: JSONObject, value: String): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, value: Int): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, value: Bool): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, value: Float): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, value: JSONObject): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, value: JSONArray): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, value: JSONNull): JSONObject {
  res.put("data", value);
  return res;
}
function Ok(res: JSONObject, key: String, value: String): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}
function Ok(res: JSONObject, key: String, value: Int): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}
function Ok(res: JSONObject, key: String, value: Bool): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}
function Ok(res: JSONObject, key: String, value: Float): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}
function Ok(res: JSONObject, key: String, value: JSONObject): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}
function Ok(res: JSONObject, key: String, value: JSONArray): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}
function Ok(res: JSONObject, key: String, value: JSONNull): JSONObject {
  var d : JSONObject := res.getJSONObject("data");
  d.put(key, value);
  res.put("data", d);
  return res;
}


// // Something like this would be nice to make things more convenient...
// // ... but nativeJava classes wrapping the JSON lib would be more appropriate
// // (but I did not want to spend the time needed to try either approach and settled for the helpers below)
// 
// entity HTTPError {
//   status: Int (default = 400)
//   message: String
// 
//   function json(): JSONObject {
//     var o := JSONObject();
//     o.put("status", status);
//     o.put("message", message);
//     return o;
//   }
// }
// 
// enum JSONValueType {
//   bool("Bool")
//   int("Int")
//   float("Float")
//   str("String")
// }
// 
// // would need to be generic
// // usage would still be a bit clunky though: JSONValue{ key := "key" }.string("value");
// // alternatively the constructor would take key and value and set the type to the non null value
// entity JSONValue {
//   key: String
//   type: JSON
//   _bool: Bool
//   _int: Int
//   _float: Float
//   _str: String
// 
//   function bool(v: Bool){
//     type := bool;
//     _bool := v;
//   }
//   // same as bool function
//   function int(v: Int){...}
//   function float(v: Float){...}
//   function str(v: String){...}
//   // should also support JSONObject and JSONArray
//   
//   function value(): Object {
//     case(type){
//       bool { return _bool; }
//       int { return _int; }
//       float { return _float; }
//       str { return _str; }
//       default { return null; }
//     }
//   }
// }
// 
// entity JSONThing {
//   data: [JSONValue] (default = List<JSONValue>())
//   isArray: Bool (default = false)
// 
//   function array(){ isArray := true; }
//   function object(){ isArray := false; }
// 
//   function asObject(): JSONObject {
//     var o := JSONObject();
//     for(v in data){
//       o.put(v.key, v.value());
//     }
//     return o;
//   }
// 
//   function asArray(): JSONArray {
//     var a := JSONArray();
//     for(v in data){
//       a.put(v.value());
//     }
//     return a;
//   }
// }
// 
// entity HTTPResponse {
//   error: [HTTPError] (default = List<HTTPERROR>())
//   data: JSONThing
// 
//   // actual convenience methods
//   function error(int: status, message: String){
//     error.add(HTTPError{ status := status, message := message });
//   }
// 
//   // would need to be done for each possible value type instead of Object, probably
//   function put(value: Object){
//     if (!data.data.isArray && data.data.length > 0){ log("TYPE ERROR"); }
//     data.data.add(JSONValue{key := data.data.length.toString()}.valueType(value));
//     data.array();
//   }
// 
//   function put(key: String, value: Object){
//     if (data.data.isArray && data.data.length > 0){ log("TYPE ERROR"); }
//     data.data.add(JSONValue{key := key}.valueType(value));
//     data.object();
//   }
// 
//   function json(): JSONObject {
//     var o := JSONObject();
//     o.put("error", error);
//     if (data.isArray){
//       o.put("data", data.asArray());
//     } else {
//       o.put("data", data.asObject());
//     }
//     return o;
//   }
// }
