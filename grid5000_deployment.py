import datetime
import subprocess
import re
import time
import shutil
import argparse
from datetime import datetime
import sys

# à améliorer : le possibilité de choisir le type de noeud, le nombre de noeuds , et nettoyer et installer l'env
# manque la deletion du job, la partie fichiers prom, enlver si possible les fichiers id_rsa, modifier spark submlit pour prendre en compte le nombre de machines, ajouter un fichier pour dire comment lancer



def parse_arguments():
    parser = argparse.ArgumentParser(description="Script pour lancer des manipulations sur Grid5000")
    parser.add_argument("--nombre-machines", type=int, default=2, help="Nombre de machines à utiliser")
    parser.add_argument("--g5kid", required=True, help="Identifiant Grid5000 : id")
    parser.add_argument("--g5kpwd", required=True, help="Mot de Passe Grid5000 : pwd")
    parser.add_argument("--makefile", required=True)
    parser.add_argument("--city", required=False, default="lille")
    parser.add_argument("--app", required=True)
    return parser.parse_args()

# Parse les arguments de ligne de commande
args = parse_arguments()
g5kid = args.g5kid
g5kpwd = args.g5kpwd
makefile = args.makefile
city = args.city
nombre_noeuds = args.nombre_machines
app = args.app

# Vérifier si g5k est fourni
if not g5kid:
    print("Erreur: L'argument --g5kid est obligatoire. Veuillez fournir un identifiant Grid5000.")
    # Vous pouvez choisir de quitter le script ici en utilisant sys.exit()
    sys.exit(1)  # 1 indique une sortie avec erreur

# configuration ssh
print("Copie des identités sur grid5000 pour ssh. Entrez le mot de passe pour la clef ~/.ssh/id_rsa...")
copyid_ssh_command = f'ssh-copy-id -i auth/id_rsa {g5kid}@access.grid5000.fr'
subprocess.run(copyid_ssh_command, shell=True)

print("Configuration de l'accès simplifié g5k. Entrez le mot de passe pour la clef ~/.ssh/id_rsa...")
config_ssh_command = f'ssh -o StrictHostKeyChecking=no -t {city}.g5k \'echo "Host g5k\\n  User {g5kid}\\n  Hostname access.grid5000.fr\\n  ForwardAgent no\\n" >> ~/.ssh/config\'; mkdir ~/res '
subprocess.run(config_ssh_command, shell=True)

# installer l'environnement pour lancer les manips
print("Lancement du script...")
# Vérifie si le dossier spark-3.5.0-bin-hadoop3 existe, sinon télécharge et installe Spark
spark_directory_check = f'ssh  -o StrictHostKeyChecking=no -i auth/id_rsa {g5kid}@access.grid5000.fr \'[ -d {city}/spark-3.5.0-bin-hadoop3 ]\''

if subprocess.run(spark_directory_check, shell=True).returncode != 0:
    print("Installation du package spark-3.5.0-bin-hadoop3... \n")
    # Télécharge Spark
    download_spark_command =  f'ssh -o StrictHostKeyChecking=no -t {city}.g5k \'curl https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz --output spark-3.5.0-bin-hadoop3.tgz && tar xzvf spark-3.5.0-bin-hadoop3.tgz\' '
    subprocess.run(download_spark_command, shell=True, check=True)

    # Décompresse Spark et supprime le fichier .tgz
    extract_spark_command = f'ssh  -o StrictHostKeyChecking=no -i auth/id_rsa {g5kid}@access.grid5000.fr \'rm {city}/spark-3.5.0-bin-hadoop3.tgz\''
    subprocess.run(extract_spark_command, shell=True, check=True)
   
    add_files_command =  f'ssh  -o StrictHostKeyChecking=no  -i auth/id_rsa {g5kid}@access.grid5000.fr \'curl https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.19.0/jmx_prometheus_javaagent-0.19.0.jar --output {city}/jmx_prometheus_javaagent-0.19.0.jar && mv {city}/jmx_prometheus_javaagent-0.19.0.jar {city}/spark-3.5.0-bin-hadoop3/jars/\' '
    subprocess.run(add_files_command, shell=True, check=True)
    
    

  
else:
    print("Package spark-3.5.0-bin-hadoop3 est déjà installé... \n")

subprocess.run(f'scp -i auth/id_rsa sysd/app/metrics/metrics.properties {g5kid}@access.grid5000.fr:{city}/spark-3.5.0-bin-hadoop3/conf/', shell=True)

spark_directory_check = f'ssh  -o StrictHostKeyChecking=no  -i auth/id_rsa {g5kid}@access.grid5000.fr \'[ -f ~/{city}/app.jar ]\' '

if subprocess.run(spark_directory_check, shell=True).returncode != 0:
    print("Installation des dépendances de l'application... \n")
    # Télécharge Spark
    download_appjar_command =  f' scp -i auth/id_rsa app.jar {g5kid}@access.grid5000.fr:{city}/'
    subprocess.run(download_appjar_command, shell=True, check=True)

    print("Installation de l'environnement du makefile... \n")
    download_makefile_command =  f' scp -i auth/id_rsa -r sysd/makefiles/{makefile} {g5kid}@access.grid5000.fr:{city}/{makefile}/'
    subprocess.run(download_makefile_command, shell=True)


else:
    print("Dépendances de l'application déjà installées... \n")


# Commande SSH initiale
initial_command = f'ssh -i auth/id_rsa {city}.g5k \'oarsub -l nodes={nombre_noeuds} -i ~/.ssh/id_rsa "while(true); do sleep 5; echo \\"awake\\"; done"\' '


print("Réservation des noeuds...")
# Exécute la commande SSH initiale et redirige la sortie vers job_settings.txt
subprocess.run(initial_command + ' > job_settings.txt', shell=True)

# Lit le fichier job_settings.txt pour récupérer la valeur de OAR_JOB_ID
with open('job_settings.txt', 'r') as file:
    job_settings_content = file.read()

# Utilise une expression régulière pour extraire la valeur de OAR_JOB_ID
oar_job_id_match = re.search(r'OAR_JOB_ID=(\d+)', job_settings_content)
if oar_job_id_match:
    oar_job_id = oar_job_id_match.group(1)
else:
    raise Exception('Erreur: Impossible de récupérer la valeur de OAR_JOB_ID.')


# Commande Curl pour récupérer les informations sur le job
curl_command = f'curl -u {g5kid}:{g5kpwd} -s https://api.grid5000.fr/stable/sites/{city}/jobs/{oar_job_id} | jq \'.assigned_nodes,.state\''

state_cluster = "empty"

while state_cluster != '''"running"''':
    time.sleep(2)
    res = subprocess.run(curl_command, shell=True)
    res.stdout.split('\n')
    lines = res.stdout.split('\n')

    if lines:
        state_cluster = lines[-2].strip()



# Utilise une expression régulière pour extraire les noms des noeuds avec numéros
oar_nodes_matches = re.findall(fr'"([^"]+\.{city}\.grid5000\.fr)"', lines)
if oar_nodes_matches:
    oar_nodes_list = [re.match(fr'([^\d]+-\d+)\.{city}\.grid5000\.fr', node).group(1) for node in oar_nodes_matches]
else:
    raise Exception('Erreur: Impossible de récupérer les noeuds assignés.')

print(f"Les noeuds réservés sont : {oar_nodes_list}")


print("Mise en place de l'environnement des noeuds... \n")
shutil.copy(".bashrc_template", ".bashrc")

# Ajoute les export SPARK_MASTER_NODE et SPARK_MASTER_URL à la fin de .bashrc
with open(".bashrc", "a") as bashrc_file:
    bashrc_file.write("\nexport SPARK_MASTER_NODE=" + oar_nodes_list[0] + "\n")
    bashrc_file.write('export SPARK_MASTER_URL="spark://' + oar_nodes_list[0] + ':7077"\n')

# Envoie le fichier .bashrc à ~/
download_bashrc_command =  f' scp -i auth/id_rsa sysd/env/.bashrc {g5kid}@access.grid5000.fr:{city}/'
subprocess.run(download_bashrc_command, shell=True)

download_retriever_command =  f' scp -i auth/id_rsa sysd/env/retrieve_results.sh {g5kid}@access.grid5000.fr:{city}/'
subprocess.run(download_retriever_command, shell=True)

download_master_script = f' scp -i auth/id_rsa sysd/env/script-master.sh {g5kid}@access.grid5000.fr:{city}/'
download_worker_script = f' scp -i auth/id_rsa sysd/env/script-worker.sh {g5kid}@access.grid5000.fr:{city}/'
subprocess.run(download_master_script, shell=True)
subprocess.run(download_worker_script, shell=True)


master_node = f'{oar_nodes_list[0]}.{city}.grid5000.fr'

script_master_command = f'ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'taktuk -m {master_node} broadcast exec [ "./script-master.sh" ]\''
print("Setting up the master node...")
subprocess.run(script_master_command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


for i in range(1,nombre_noeuds):
    print("Setting up the worker node " + str(i))
    script_worker_command = f'ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'taktuk -m {oar_nodes_list[i]}.{city}.grid5000.fr broadcast exec [ "./script-worker.sh" ]\''
    subprocess.run(script_worker_command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)


if app == "App":
    spark_submit_command = f'ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'taktuk -m {master_node} broadcast exec [ "mkdir /tmp/spark-metrics;chmod 777 /tmp/spark-metrics; spark-submit --class scheduler.app.App --conf spark.metrics.conf=/home/{g5kid}/spark-3.5.0-bin-hadoop3/conf/metrics.properties --master spark://{master_node}:7077 --num-executors {nombre_noeuds} --deploy-mode cluster app.jar ~/{makefile}/Makefile {master_node} {nombre_noeuds}" ]\''
elif app == "Latency":
    spark_submit_command = f'ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'taktuk -m {master_node} broadcast exec [ "mkdir /tmp/spark-metrics;chmod 777 /tmp/spark-metrics; spark-submit --class scheduler.app.Latency --conf spark.metrics.conf=/home/{g5kid}/spark-3.5.0-bin-hadoop3/conf/metrics.properties --master spark://{master_node}:7077 --num-executors {nombre_noeuds} --deploy-mode cluster app.jar {master_node}" ]\''
    

subprocess.run(spark_submit_command , shell=True)

init = 0
check_term = f'ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'wc -l {city}/spark-3.5.0-bin-hadoop3/work/driver*/stdout \''
while init == 0: 
    input("Appuyez sur Entrée pour continuer dès que les résultats sont prêts...")
    init = subprocess.run(check_term, shell=True).stdout.decode("utf-8", "strict")[:2]
    init = int(init)

retrieve_command = f'ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'taktuk -m {master_node} broadcast exec [ "./retrieve_results.sh {app} {nombre_noeuds}" ]\''
subprocess.run(retrieve_command, shell=True)


rsync_from_grid_command = f'rsync -av {g5kid}@access.grid5000.fr:{city}/res/ app-{app}-result-{nombre_noeuds}nodes-{city}-{g5kid}-{makefile}; ssh -i auth/id_rsa {g5kid}@access.grid5000.fr \'rm -rf {city}/spark-3.5.0-bin-hadoop3/work/*; rm -rf {city}/res\''
subprocess.run(rsync_from_grid_command, shell=True)




# nettoyer l'espace
subprocess.run(['rm', '.bashrc'])
subprocess.run(['rm', 'job_settings.txt'])
delete_command = f'curl -u {g5kid}:{g5kpwd} -i -X DELETE https://api.grid5000.fr/stable/sites/{city}/jobs/{oar_job_id}'
subprocess.run(delete_command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


print("\n Fin du script")

