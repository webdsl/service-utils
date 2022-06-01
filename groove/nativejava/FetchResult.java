package nativejava;

/**
 * Strongly typed wrapper around fetch results
 */
public class FetchResult {
    private Integer status;
    private String state;
    private String body;

    public FetchResult(Integer status, String state, String body){
        this.status = status;
        this.state = state;
        this.body = body;
    }

    public Integer getStatus(){ return this.status; }
    public String getState(){ return this.state; }
    public String getBody(){ return this.body; }

    @Override
    public String toString(){
        return "{\n  state: " + this.state
            + ",\n  status: " + String.valueOf(this.status)
            + ",\n  body: " + this.body + "\n}";
    }
}
