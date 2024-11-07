mv /tmp/spark-metrics/ ~/res/

if [ "$1" = "Latency" ]; then
    output=$(find spark-3.5.0-bin-hadoop3/work -name latence.txt)
    mv $output ~/res/
else
    mkdir /tmp/rrscript
    for i in $(seq 0 "$2"); do
        file_path="spark-3.5.0-bin-hadoop3/work/app*/$i" 
        cp -r $file_path /tmp/rrscript
    done
    mv /tmp/rrscript ~/res/
fi
