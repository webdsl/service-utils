package nativejava;

import java.util.HashMap;
import java.util.Map;

/**
 * Java wrapper for the JavaScript Fetch API options
 */
public class FetchOptions {
    private Map<String, String> options;
    private Map<String, String> headers;

    public FetchOptions(){
        this.options = new HashMap<>();
        this.headers = new HashMap<>();
    }

    public FetchOptions set(String key, String value){
        if (key.equals("body")){
            // make sure this is a string, not a JSON object...
            this.options.put(key, value.replace("\"", "\\\"").replace("\n", "\\n"));
        } else {
            this.options.put(key, value);
        }
        return this;
    }

    public FetchOptions addHeader(String header, String value){
        this.headers.put(header, value);
        return this;
    }

    private static String map2json(Map<String,String> m){
        String entries = m.entrySet().stream()
            .map(e -> { // the headers should not be escaped
                String escape = e.getKey().equals("headers") ? "" : "\"";
                return "\"" + e.getKey() + "\":" + escape + e.getValue() + escape;
            })
            .reduce("", (a,b) -> a + "," + b);
        return "{" 
            // remove "," at beginning if present
            + (entries.length() > 0 ? entries.substring(1) : "") 
            + "}";
    }

    @Override
    public String toString(){
        this.options.put("headers", map2json(this.headers));
        return map2json(this.options);
    }
}