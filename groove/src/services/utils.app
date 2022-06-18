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
