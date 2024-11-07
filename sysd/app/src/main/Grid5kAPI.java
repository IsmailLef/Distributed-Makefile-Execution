package scheduler.app;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import com.google.gson.JsonObject;
import com.google.gson.Gson;
import java.nio.charset.StandardCharsets;
import java.util.Base64;


public class Grid5kAPI {

    HttpClient httpClient;
    String g5Auth;
    Gson gson;


    public Grid5kAPI(String username, String password) {
        httpClient = HttpClient.newHttpClient();
        g5Auth = String.format("%s:%s", username, password);
        g5Auth = Base64.getEncoder().encodeToString(g5Auth.getBytes(StandardCharsets.UTF_8));
        gson = new Gson();

    }
    
    public int submitTask(String siteID, int nbResources, String cmd, String cluster, String taskName) {
        JsonObject json = new JsonObject();
        json.addProperty("resources", "nodes="+nbResources);
        json.addProperty("command", cmd);
        json.addProperty("properties", String.format("cluster='%s'", cluster));
        json.addProperty("name", taskName);

        String jsonBody = json.toString();

        String jobURL = String.format("https://api.grid5000.fr/stable/sites/%s/jobs", siteID);
        URI uri = URI.create(jobURL);

        HttpRequest request = HttpRequest.newBuilder()
            .uri(uri)
            .header("Content-Type", "application/json")
            .header("Authorization", "Basic " + g5Auth)
            .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
            .build();

        String response = sendRequest(request);
        JsonObject jsonResponse = gson.fromJson(response, JsonObject.class);
        return jsonResponse.get("uid").getAsInt();
    }

    public String getMetrics(String siteID, int jobID) {
        String jobURL = String.format("https://api.grid5000.fr/stable/sites/%s/metrics?job_id=%d", siteID, jobID);
        URI uri = URI.create(jobURL);

        HttpRequest request = HttpRequest.newBuilder()
            .uri(uri)
            .header("Content-Type", "application/json")
            .header("Authorization", "Basic " + g5Auth)
            .GET()
            .build();

        return sendRequest(request);
    }

    public String deleteTask(String siteID, int jobID) {
        String jobURL = String.format("https://api.grid5000.fr/stable/sites/%s/jobs/%d", siteID, jobID);
        URI uri = URI.create(jobURL);

        HttpRequest request = HttpRequest.newBuilder()
            .uri(uri)
            .header("Content-Type", "application/json")
            .header("Authorization", "Basic " + g5Auth)
            .GET()
            .build();

        return sendRequest(request);
    }


    public String sendRequest(HttpRequest request) {
        HttpResponse<String> response = null;
        try {
            response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            System.out.println("Status code : " + response.statusCode());
            System.out.println("Response Body: " + response.body());
        } catch (Exception e) {
            e.printStackTrace();
        
        }
        return response.body();
    }
}
