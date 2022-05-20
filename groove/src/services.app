module services

imports src/services/auth       // login, logout, register
imports src/services/habit      // habits, habit
imports src/services/completion // completions, completion
imports src/services/color      // colors
imports src/services/user       // users, user

// reroute api requests to the right service
// each service has the name <path>Service, so /api/<path>/...args becomes <path>Service/...args
routing {
  receive(urlargs:[String]) {
    if(urlargs[0] == "api" && urlargs.length > 1){
      var url := [urlargs[1] + "Service"].addAll(urlargs.subList(2, urlargs.length));
      //log("[routing]: ~urlargs -> ~url");
      return url;
    }
    else{
      return null; // will use default
    }
  }
  // construct is not necessarily the same as receive, e.g. when using the domain name to specify one of the arguments in a multitenant application
  construct (appurl:String,pagename:String, pageargs:[String]) {
    if(pagename == "api" && pageargs.length > 0){
      var url := [appurl, pageargs[0] + "Service"].addAll(pageargs.subList(1, pageargs.length));
      //log("[construct]: ~pagename/~pageargs -> ~url");
      return url;
    }
    else{
      return null;
    }
  }
}