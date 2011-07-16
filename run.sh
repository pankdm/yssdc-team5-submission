#!/bin/bash

if [ $# -ne 2 ] ; then
    echo "Usage $0 <input-gbk> <output-file>"
    exit 1
fi

DATA=$1
OUTPUT=$2
ROOTDIR=`dirname $0`
SPLITTED="gbk-splitted"
MAPPER="genefinder"
HADOOP=hadoop/bin/hadoop
HADOOP=hadoop
BINDIR="$DIRNAME/bin-cpp"
WORK="$DIRNAME/work"
HADOOP_STREAMING="/usr/lib/hadoop-0.20/contrib/streaming/hadoop-streaming-0.20.2-cdh3u0.jar"

mkdir -p $WORK

cat $DATA | $BINDIR/splitter  > $WORK/data-splitted.txt


$HADOOP dfs -rmr $SPLITTED
$HADOOP fs -put $WORK/data-splitted.txt $SPLITTED

$HADOOP dfs -rmr gbk
$HADOOP dfs -rmr tmp

$HADOOP jar $HADOOP_STREAMING \
    -D mapred.map.tasks=1000 \
    -file "$BINDIR/$MAPPER" \
    -input "$SPLITTED" \
    -output "gbk" \
    -mapper "./$MAPPER" \
    -reducer org.apache.hadoop.mapred.lib.IdentityReducer \
    
$HADOOP jar team5.jar gbk/part-00000 tmp $WORK/result.txt
cp $WORK/result.txt $OUTPUT

#$BINDIR/rnachecker $DATA $WORK/result.txt
