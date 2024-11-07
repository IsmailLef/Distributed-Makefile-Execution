export SPARK_MASTER_NODE=$(hostname)
echo "export SPARK_MASTER_NODE=$SPARK_MASTER_NODE" >> ~/.bashrc
. ~/.bashrc

start-master.sh
start-worker.sh $SPARK_MASTER_NODE:7077

