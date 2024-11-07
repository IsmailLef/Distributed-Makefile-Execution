# Exemple de code pour calculer la latence et la bande passante
# Spécifie le répertoire de travail
#setwd("/user/9/hermetj/3a/sysd/sysd/sysd/mesure")

latency <- read.csv("latency_measurements.csv")
latency_mean <- mean(latency)
latency_ci <- t.test(latency, conf.level = 0.95)$conf.int

# Affichage des résultats pour la latence de la première paire de séries
cat("Latence moyenne  :", latency_mean, "\n")
cat("La moyenne de latence est égale à", round(latency_mean, 3), 
    "avec un intervalle de confiance à 95% compris entre",
    round(latency_ci[1], 3), "et", round(latency_ci[2], 3), "ms.")

# ajouter histogramme et donnée brutes a cotes

# Graphique 1 : Distribution brute de la latence avec des points
plot(1:n, latency, main = "Distribution brute de la latence (t1-t2)", col = "lightblue", pch = 16, xlab = "Observation", ylab = "Latence")

# Graphique 2 : Histogramme de la latence
hist(latency, breaks = 15, col = "lightblue", main = "Histogramme de la latence (t2-t1)")

# Rétablir la configuration par défaut pour éviter des problèmes graphiques ultérieurs
par(mfrow = c(1, 1))

# Génère des valeurs aléatoires pour t3 et t4
t3 <- rnorm(n, mean = 20, sd = 2)
t4 <- t3 + rnorm(n, mean = 1000, sd = 2)

# Crée un data frame pour la deuxième paire de séries
mes_donnees_2 <- data.frame(t3 = t3, t4 = t4)

# Calcul de la bande passante pour la deuxième paire de séries
M <- 100
bande_passante <- 1 / ((mes_donnees_2$t4 - mes_donnees_2$t3 - 2 * latency) / M)

# Affichage des résultats pour la bande passante de la deuxième paire de séries
cat("\nBande passante moyenne :", mean(bande_passante), "octets/s\n")




