package scheduler.app;

import java.io.IOException;
import java.io.Serializable;
import java.util.List;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Task implements Serializable {

    public String taskName;
    public List<String> dependencies;
    protected String cmd;


    public Task(String taskName, String cmd) {
        this.taskName = taskName;
        this.cmd = cmd;
    }

    public String getTaskName() {
        return taskName;
    }

    public List<String> getDependencies() {
        return dependencies;
    }

    public String getCmd() {
        return cmd;
    }


    public void addDependency(String task) {
        dependencies.add(task);
    }

    public String execute(String env) throws IOException {
        ProcessBuilder processBuilder = new ProcessBuilder("bash", "-c", "export PATH=\"" + env + ":$PATH\"; " + cmd);
        processBuilder.redirectErrorStream(true);
        Process proc = processBuilder.start();

        // InputStream inputStream = proc.getInputStream();
        // InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
        // BufferedReader reader = new BufferedReader(inputStreamReader);
        

        // String line;
        // while ((line = reader.readLine()) != null) {
        //     System.out.println("Output: " + line);
        // }

        int exitVal = -1;
        try {
            exitVal = proc.waitFor();
        } catch (InterruptedException ie) {
            ie.printStackTrace();
        }
        return "Process " + taskName + " exited with status " + exitVal;

    }
}
