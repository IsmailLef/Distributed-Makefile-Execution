import os
import fnmatch
import pandas as pd
import matplotlib.pyplot as plt

# Répertoire contenant les fichiers CSV
dir = '/tmp/spark-metrics'

# Liste des motifs génériques pour les fichiers CSV que vous voulez inclure
motifs_inclus = [
    "*.driver.CodeGenerator.compilationTime.csv",
    # "*.driver.ExecutorMetrics.MappedPoolMemory.csv",
]

# Initialiser une figure
plt.figure(figsize=(20, 20))

# Couleurs pour les courbes
couleurs = ['blue', 'orange', 'green', 'red', 'purple', 'brown', 'pink', 'gray', 'olive']

# Parcourir chaque fichier dans le répertoire
for i, fichier in enumerate(os.listdir(dir)):
    # Vérifier si le fichier correspond à l'un des motifs inclus
    if any(fnmatch.fnmatch(fichier, motif) for motif in motifs_inclus):
        complete_path = os.path.join(dir, fichier)

        # Charger le fichier CSV dans un DataFrame Pandas
        df = pd.read_csv(complete_path)
        print(df)

        # Tracer la courbe avec une couleur différente
        plt.plot(df['t'], df['value'], label=fichier, color=couleurs[i % len(couleurs)])

# Configurations du graphique global
plt.title('Graphique avec Plusieurs Courbes')
plt.xlabel('Temps')
plt.ylabel('Valeur')
plt.legend()
plt.grid(True)

# Afficher le graphique
plt.show()
