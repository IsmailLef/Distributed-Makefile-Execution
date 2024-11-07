package scheduler.app;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;

public class DAGraph {
    public HashSet<String> dependencies;
    public ArrayList<Task> vertices;
    public HashSet<String> visitedNodes;
    public LinkedList<Task> orderedTasks;
    public HashMap<String, Task> tasks;
    public DAGraph(HashMap<String, Task> tasks) {
        this.visitedNodes = new HashSet<String>();
        this.dependencies = new HashSet<String>();
        this.orderedTasks = new LinkedList<Task>();
        this.tasks = tasks;
        this.vertices = new ArrayList<>(tasks.values());
    }

    public LinkedList<Task> topSort() {
        preProcessGraph();

        while (vertices.size() != 0) {
            dfs(vertices.get(0));
        }
        return orderedTasks;
    }

    public void preProcessGraph() {
        /**
         * Placing tasks with no dependencies in first places
         */
        Iterator<Task> taskIt = vertices.iterator();
        Task task;
        while (taskIt.hasNext()) {
            task = taskIt.next();
            if (task.dependencies == null) {
                orderedTasks.add(task);
                visitedNodes.add(task.getTaskName());
                taskIt.remove();
            }
        }

        for (Task t : vertices) {
            for (String dependency : t.dependencies)
                dependencies.add(dependency);
        }
        dependencies.removeAll(tasks.keySet());

    }


    public void dfs(Task entryPoint) {
        visitedNodes.add(entryPoint.getTaskName());
        vertices.remove(entryPoint);

        if (entryPoint.dependencies != null) {
            for (String dependencyStr : entryPoint.dependencies) {
                Task dependency = tasks.get(dependencyStr);
                if ((! visitedNodes.contains(dependencyStr)) && (! dependencies.contains(dependencyStr))) {
                    dfs(dependency);
                }
            }
        }
        orderedTasks.push(entryPoint);
    }
}
