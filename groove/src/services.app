module services

imports src/services/auth       // login, logout, register
imports src/services/habit      // habits, habit
imports src/services/completion // completions, completion
imports src/services/color      // colors
imports src/services/user       // users, user

service testService(param: String){
  var res := JSONObject();
  log(getHttpMethod());
  res.put("method", getHttpMethod());
  res.put("param", param);
  res.put("body", readRequestBody());
  return res;
}

test testNocacheServices {
  var options := FetchOptions()
    .set("method", "GET")
    .addHeader("Content-Type", "application/json");

  var res := fetch("/mainappfile/api/test/1", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  var data := JSONObject(res.getBody());
  assert(data.getString("method") == "GET");
  assert(data.getString("param") == "1");
  assert(data.getString("body") == "");

  var body := JSONObject();
  body.put("hello", "world");

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json")
    .set("body", body.toString());

  res := fetch("/mainappfile/api/test/1?nocache", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "1");
  assert(data.getString("body").trim() == body.toString().trim());

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json");

  res := fetch("/mainappfile/api/test/2", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "2");
  assert(data.getString("body") == "");

  options := FetchOptions()
    .set("method", "GET")
    .addHeader("Content-Type", "application/json");

  res := fetch("/mainappfile/api/test/2?nocache", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "GET");
  assert(data.getString("param") == "2");
  assert(data.getString("body") == "");
}

test testServiceMethods {
  // GET
  var options := FetchOptions()
    .set("method", "GET")
    .addHeader("Content-Type", "application/json");

  var res := fetch("/mainappfile/api/test", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  var data := JSONObject(res.getBody());
  assert(data.getString("method") == "GET");
  assert(data.getString("param") == "");
  assert(data.getString("body") == "");

  options := FetchOptions()
    .set("method", "GET")
    .addHeader("Content-Type", "application/json");

  res := fetch("/mainappfile/api/test/somevalue", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "GET");
  assert(data.getString("param") == "somevalue");
  assert(data.getString("body") == "");

  // PUT
  var body := JSONObject();
  body.put("hello", "world");

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json")
    .set("body", body.toString());

  res := fetch("/mainappfile/api/test/42", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "42");
  assert(data.getString("body").trim() == body.toString().trim());

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json");

  res := fetch("/mainappfile/api/test?nocache", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "");
  assert(data.getString("body") == "");

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json");

  res := fetch("/mainappfile/api/test/somevalue?nocache", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "somevalue");
  assert(data.getString("body") == "");

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json")
    .set("body", body.toString());

  res := fetch("/mainappfile/api/test?nocache", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "");
  assert(data.getString("body").trim() == body.toString().trim());

  options := FetchOptions()
    .set("method", "PUT")
    .addHeader("Content-Type", "application/json")
    .set("body", body.toString());

  res := fetch("/mainappfile/api/test/somevalue?nocache", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "PUT");
  assert(data.getString("param") == "somevalue");
  assert(data.getString("body").trim() == body.toString().trim());

  // POST
  options := FetchOptions()
    .set("method", "POST")
    .addHeader("Content-Type", "application/json")
    .set("body", body.toString());

  res := fetch("/mainappfile/api/test", options);

  assert(res.getState() == "fulfilled");
  assert(res.getStatus() == 200);

  data := JSONObject(res.getBody());
  assert(data.getString("method") == "POST");
  assert(data.getString("param") == "");
  assert(data.getString("body").trim() == body.toString().trim());
}

service testReturnService(condition1: String, condition2: String){
  var res := "~condition1/~condition2/";
  if( condition1 == "true" ){
    if( condition2 == "true"){
      return res + "1+2";
    }
    return res + "1";
  }
  if( condition2 == "true"){
    return res + "2";
  }
  return res + "0";
}

test testServiceMethods {
  // no arg
  assert(fetch("/mainappfile/api/testReturn").getBody() == "//0");

  // one arg
  assert(fetch("/mainappfile/api/testReturn/false").getBody() == "false//0");
  assert(fetch("/mainappfile/api/testReturn/true").getBody() == "true//1");

  // both args
  assert(fetch("/mainappfile/api/testReturn/false/false").getBody() == "false/false/0");
  assert(fetch("/mainappfile/api/testReturn/false/true").getBody() == "false/true/2");
  assert(fetch("/mainappfile/api/testReturn/true/false").getBody() == "true/false/1");
  assert(fetch("/mainappfile/api/testReturn/true/true").getBody() == "true/true/1+2");
}

/// Reroutes API requests to the corresponding service.
///
/// Rewrites `api/{endpoint}` URLs to the `{endpoint}Service` service.
routing {
  receive(urlargs:[String]) {
    if( urlargs[0] == "api" && urlargs.length > 1 ){
      var url := [urlargs[1] + "Service"].addAll(urlargs.subList(2, urlargs.length));
      return url;
    } else {
      return null;
    }
  }
  construct (appurl: String, pagename: String, pageargs: [String]) {
    if( pagename == "api" && pageargs.length > 0 ) {
      var url := [appurl, pageargs[0] + "Service"].addAll(pageargs.subList(1, pageargs.length));
      return url;
    } else {
      return null;
    }
  }
}

access control rules
  rule page testService(param: String){ true }
  rule page testReturnService(condition1: String, condition2: String){ true }