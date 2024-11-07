package scheduler.app;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

import java.nio.file.FileAlreadyExistsException;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.List;



public class App {

    public static void main(String[] args) throws IOException {
        // argFile is ithe file we're trying to "make" and masterURL for spark conf, should be opaque to the user
        String argFile = args[0];
        String masterURL = String.format("spark://%s:7077", args[1]);
        String instances = args[2];
        int nbCores = 64*Integer.parseInt(instances);

        SparkConf conf = new SparkConf()
                .setAppName("Scheduler")
                .setMaster(masterURL)
                .set("spark.executor.instances", instances);

        JavaSparkContext sc = new JavaSparkContext(conf);
        sc.setLogLevel("ERROR"); // Making the output more readable. Some logs are redirected to stderr of the driver

        int executors = sc.getConf().getInt("spark.executor.instances", 1);
        ArrayList<String> executorsDir = new ArrayList<String>();
        for (int i = 0; i < executors; i++) {
            String dir = String.format("../%d/", i);
            executorsDir.add(dir);
        }


        /**
         * Beginning of parsing
         */
        FileReader fr = new FileReader(argFile);
        BufferedReader reader = new BufferedReader(fr);
        boolean readNext = true;
        String line1 = null;
        String line2;
        HashMap<String, Task> tasks = new HashMap<String, Task>();

        while (readNext) {
            line1 = "";
            while (line1 != null && !line1.contains(":")) {
                line1 = reader.readLine();
            }
            line2 = reader.readLine();

            if (line1 != null) {
                parseTask(line1, line2, tasks);
            }
            else
                readNext = false;

        }
        reader.close();
        /**
         * End of parsing
         */

        // Topological sort algorithm used to sort tasks' order minding the dependencies
        DAGraph graph = new DAGraph(tasks);
        LinkedList<Task> orderedTasks = graph.topSort();

        // Topological sort gives the reversed list of the order needed
        Collections.reverse(orderedTasks);

        // This function is used for mapping tasks in the upcoming RDD and therefore executes the task properly
        Function<Task, String> executeTask = task -> {
            String exitVal = null;
            
            // In case the dependencies are not yet ready.
            // A maximum number of 50 tries (5 seconds) for each dependency is set to avoid blocking threads.
            if (task.dependencies != null) {
                for (String taskName : task.dependencies) {
                    Path dir = waitForFile(taskName, executorsDir);
                    if (dir != null) {
                        try {
                            Files.createLink(Paths.get(taskName), dir);
                        } catch (FileAlreadyExistsException faee) {
                            continue; // do nothing because file exists already
                        }
                    }
                    else {
                        System.out.println("Process " + task.getTaskName() + " waited too long for process " + taskName + ". Retrying...");
                    }
                }
            }
            
            
            String env = argFile.substring(0, argFile.lastIndexOf("/"));
            try {
                exitVal = task.execute(env);
            } catch (IOException e) {
                e.printStackTrace();
            }
            return exitVal;
        };


        // Measuring time of the execution of the Makefile
        long taskStartTime = System.currentTimeMillis();
        
        JavaRDD<String> sortedTasks = sc.parallelize(orderedTasks, nbCores).map(executeTask);
        sortedTasks.collect().forEach(x -> System.out.println(x));
        
        long tastEndTime = System.currentTimeMillis();
        System.out.println("Tasks completed in : " + (tastEndTime - taskStartTime));

        sc.stop();
    }


    public static void parseTask(String line1, String line2, HashMap<String, Task> tasks) {
        String[] parsedLine1 = line1.split(":\\s+");
        String target = parsedLine1[0].replace(":", "");
        line2 = line2.trim();

        Task task = new Task(target, line2);

        if (parsedLine1.length > 1) {
            task.dependencies = Arrays.asList(parsedLine1[1].split(" "));
        }
        else
            task.dependencies = null;

        tasks.put(target, task);
    }


    private static Path waitForFile(String filePath, ArrayList<String> executorsDir) {
        int nbTries = 500;

        Path file = filesExist(executorsDir, filePath);
        while (file == null && nbTries != 0) {
            try {
                Thread.sleep(50);
            } catch (InterruptedException ie) {
                ie.printStackTrace();
            }
            nbTries--;
            file = filesExist(executorsDir, filePath);
        }

        if (nbTries != 0)
            return file;

        return null;
    }

    /**
     * Checks whether all files in parameters exist
     * @param files
     * @return
     */
    private static Path filesExist(ArrayList<String> executorsDir, String fileName) {
        for (String dir : executorsDir) {
            Path path = Paths.get(dir, fileName);
            if (Files.exists(path))
                return path;
        }

        return null;
    }

    
}
