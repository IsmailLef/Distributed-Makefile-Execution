#!/usr/bin/env python3

import sys
import re

ackstuple = []
seqstuple = []
latencies = []

def parse_tcpdump(lines):
    lines = list(lines)
    for line in lines[1:-1] :
        words = re.split(r'\s+', line)
        timestamp = words[0]
        if words[7] == "seq" :
            comp_seq = words[8].split(":")
            if len(comp_seq) > 1:
                seq = comp_seq[1][:-1]
            else:
                seq = comp_seq[0][:-1]
            length = words[-2]
            seqstuple.append((seq, timestamp, length))
        else :
            seq = -1
            ack = words[8][:-1]
            ackstuple.append((ack, timestamp))

        

def sub_time(time1, time2):
    t1 = float(time1.split(":")[-1])
    t2 = float(time2.split(":")[-1])
    return t2 - t1


def measure_latency(lines):
    parse_tcpdump(lines)
    acks = [tup[0] for tup in ackstuple]

    start_time = 0
    length = 0
    for seq in seqstuple:
        if seq[0] not in acks:
            start_time = seq[1]
            length += int(seq[2])
        else:
            length += int(seq[2])
            seq_time = seq[1]
            ack_time = next((time for ack, time in ackstuple if ack == seq[0]), seq_time)
            ackstuple.remove((seq[0], ack_time))
            acks.remove(seq[0])

            if start_time == 0:
                latencies.append((sub_time(seq_time, ack_time), length))
            else:
                latencies.append((sub_time(start_time, ack_time), length))
            
            start_time = 0
            length = 0


measure_latency(sys.stdin)
sorted(latencies, key=lambda l : l[1])
print(latencies)