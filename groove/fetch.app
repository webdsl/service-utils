module fetch

page fetch {
  head {
    <style>
      :root { --accent: lightgray; --radius: 8px; }
      h4 { font-size: 1.25rem; margin: 1rem 0 .25rem; }
      body { margin: 0; font-family: monospace; padding: 1rem; }
      label { display: block; font-size: 1rem; }
      label > input,
      label > textarea {
          margin: .25rem 0 1rem;
          display: block;
          min-width: 100%;
          border: 1px solid var(--accent);
          border-radius: var(--radius);
          font-size: 1rem;
          padding: .5rem;
          box-sizing: border-box;
          resize: vertical;
      }
      button[type="submit"] {
          margin: .25rem 0;
          display: block;
          min-width: 100%;
          background: var(--accent);
          border: 0;
          padding: .5rem 1.25rem;
          font-size: 1rem;
          border-radius: var(--radius);
          cursor: pointer;
      }
      #status,
      #state {
          float: right;
          margin-left: .5rem;
          font-variant: all-small-caps;
          font-size: 1.15rem;
          border-radius: var(--radius);
      }
      #status::after, #state::after { content: ""; clear: both; }
      pre {
          background: var(--accent);
          padding: 1rem;
          border-radius: var(--radius);
          margin: 0;
          filter: brightness(1.1);
      }
    </style>

    // polyfill for selenium firefox version using https://polyfill.io/v3/url-builder/
    <script type="text/javascript" src="https://polyfill.io/v3/polyfill.min.js?version=3.111.0&features=fetch%2Ces5"></script>
  }
  <script type="text/javascript">
    function handleSubmit(e){
      e.preventDefault(); // no redirect
      const url = document.getElementById('url').value;
      const options = JSON.parse(document.getElementById('options').value || "null");

      fetch(url, options)
        .then(r => {
          document.getElementById('status').textContent = r.status;
          return r.text();
        })
        .then(t => {
          document.getElementById('response').textContent = t;
          document.getElementById('state').textContent = "fulfilled";
        })
        .catch(e => {
          console.error(e);
          document.getElementById('state').textContent = "rejected";
        });
      document.getElementById('state').textContent = "pending";
      return false;
    }
  </script>
  
  <h2>"Fetch API"</h2>

  <form onsubmit="return handleSubmit(event);">
    <h4>"Request"</h4>
    <label>"URL"
      <input type="text" id="url"/>
    </label>

    <label>"Options"
      <textarea id="options"></textarea>
    </label>

    <button type="submit" id="send">"Send"</button>
  </form>

  <div id="res">
    <h4>"Response"
      <span id="state"></span>
      <span id="status"></span>
    </h4>
    <pre><code id="response"></code></pre>
  </div>
}

native class nativejava.FetchOptions as FetchOptions {
  constructor()
  set(String,String): FetchOptions
  addHeader(String,String): FetchOptions
  toString(): String
}

native class nativejava.FetchResult as FetchResult {
  constructor(Int, String, String)
  getStatus(): Int
  getState(): String
  getBody(): String
  toString(): String
}

/// Wraps the browser Fetch API, useful for testing services with request bodies.
/// See https://developer.mozilla.org/en-US/docs/Web/API/fetch#parameters
/// 
/// URLs beginning with "/" are prefixed with the project base URL
function fetch(d: WebDriver, url: String): FetchResult {
  return fetch(d, url, FetchOptions());
}
function fetch(d: WebDriver, url: String, options: FetchOptions): FetchResult {
  d.get(navigate(fetch()));
  // set url
  d.findElement(SelectBy.id("url")).sendKeys(url);
  // set options
  d.findElement(SelectBy.id("options")).sendKeys(options.toString());
  // execute request
  d.findElement(SelectBy.id("send")).submit();

  // wait until the promise is fulfilled/rejected
  awaitFetch(d, 10000);

  var res := FetchResult(
    d.findElement(SelectBy.id("status")).getText().parseInt(),
    d.findElement(SelectBy.id("state")).getText(),
    d.findElement(SelectBy.id("response")).getText()
  );

  return res;
}

function awaitFetch(d: WebDriver, maxWait: Int){
  sleep(1000);
  var state := d.findElement(SelectBy.id("state")).getText();
  if(state != "fulfilled" && state != "rejected") {
    log(".");
    awaitFetch(d, maxWait - 1000);
    return;
  }
}

test test_fetch {

  //var d : WebDriver := HtmlUnitDriver();
  var d : WebDriver := getFirefoxDriver();

  var options := FetchOptions()
    .set("method", "POST")
    .addHeader("Content-Type", "application/json")
    .set("body", "{}");

  var res := fetch(d, "/mainappfile/api/currentUser", options);

  log(res.toString());

  assert(res.getState() == "fulfilled", "Expected the request to succeed");
  assert(res.getStatus() == 200, "Expected the status to be ok");
}

access control rules
  rule page fetch(){ true }