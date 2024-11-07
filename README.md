# Distributed Computing Project

This project utilizes distributed computing with Apache Spark and Hadoop. Below are the instructions to set up and run the application on Grid5000.

## Prerequisites

1. **Install Spark and Hadoop**: Download and install Apache Spark 3.5.0 and Hadoop.
2. **Install JDK 11**:
   Download and set up JDK 11 by running the following command:
   ```bash
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home
   ```
3. **Install Gradle**: Gradle is used to run the application.

## Running the Application

Run the application using Gradle with the following command:
```bash
./gradlew run --args="{PATH_TO_REPO}/makefiles/premier/Makefile"
```

---

## Download Spark Package

To download the Spark package, run:
```bash
curl https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz --output spark-3.5.0-bin-hadoop3.tgz
tar xzvf spark-3.5.0-bin-hadoop3.tgz
```

## Starting the Spark Cluster

1. Transfer the files in `{PATH_TO_REPO}/env` (e.g., `script-worker.sh`, `script-master.sh`, `.bashrc`) to the Grid5000 frontend.
   - Place `.bashrc` in `~/`.
2. Reserve nodes on Grid5000 with:
   ```bash
   oarsub -I -l nodes=2,walltime=1:00
   ```
3. On the allocated node, run:
   ```bash
   uniq $OAR_FILE_NODES
   ```
   Then, SSH into other reserved nodes in separate terminals.
4. On the master node, start the master script:
   ```bash
   source script-master.sh
   ```
5. On each worker node, start the worker script:
   ```bash
   source script-worker.sh
   ```

6. On the master node, submit the Spark job:
   ```bash
   spark-submit --class scheduler.app.App --master spark://$SPARK_MASTER_NODE:7077 --num-executors 2 --executor-cores 2 --deploy-mode cluster ./app/build/libs/app.jar ./makefiles/premier/Makefile $SPARK_MASTER_URL
   ```

   To view job results, check the `spark-3.5.0-bin-hadoop3/work/` directory under the relevant driver corresponding to the submitted job.

---

## Using `grid5000_deployment.py` Script for Automated Deployment

The `grid5000_deployment.py` script automates the allocation of two machines on Grid5000 and runs the application. 

### Requirements:
- Spark installed on the frontend.
- An SSH key and the `{PATH_TO_REPO}` folder set up on your session.
- A configured `ProxyCommand` named `grid5000_deployment` (see [Grid5000 documentation](https://www.grid5000.fr/w/SSH)).

### Running the Script

Run the script with:
```bash
python3 grid5000_deployment.py
```
