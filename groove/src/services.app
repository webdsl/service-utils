module services

imports src/services/auth       // login, logout, register
imports src/services/habit      // habits, habit
imports src/services/completion // completions, completion
imports src/services/color      // colors
imports src/services/user       // users, user

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