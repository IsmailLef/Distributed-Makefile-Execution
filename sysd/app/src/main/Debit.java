package scheduler.app;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

public class Debit {
     public static void main(String[] args) {
        // Set up Spark configuration
        SparkConf conf = new SparkConf().setAppName("SparkJavaTest").setMaster("spark://localhost:7077");;

        // Initialize Spark context
        JavaSparkContext sc = new JavaSparkContext(conf);

        List<Double> tempsAllerRetour = new ArrayList<>();
        // Créer une liste avec un seul octet de données
        
        try {
            PrintWriter writer = new PrintWriter(new FileWriter("debit.txt"));
            for (int i = 1; i <= 30; i++) {
                try {
                    Thread.sleep(1000); // en millisecondes
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                int megaByteSize = 10 * 1024 * 1024;
                // Créer une liste de mégaoctets
                List<Byte> megaByteList = new ArrayList<>(megaByteSize);

                // Remplir la liste avec des valeurs bidon, par exemple, des zéros
                for (int j = 0; j < megaByteSize; j++) {
                    megaByteList.add((byte) 0);
                }


                JavaRDD<Byte> rdd = sc.parallelize(megaByteList, 1);
                
                long startTime = System.nanoTime();
                
                rdd.collect();
                
                long endTime = System.nanoTime();
                double elapsedTime = (endTime - startTime) / 1e6;
                
                tempsAllerRetour.add(elapsedTime);
                System.out.println("\nTemps d'aller-retour : " + elapsedTime + " ms\n");

                writer.println(elapsedTime);
            }

            double moyenne = tempsAllerRetour.stream().mapToDouble(Double::doubleValue).average().orElse(0.0);
            System.out.println("\n\nMoyenne des temps d'aller-retour : " + moyenne + " ms\n\n");
            writer.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Stop Spark context
        sc.stop();
    }
}
