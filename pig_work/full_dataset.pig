register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-*' USING TextLoader as (line:chararray);
--raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

subjects = group ntriples by (subject) PARALLEL 50;

count_by_subject = FOREACH subjects generate group, COUNT_STAR($1) as count PARALLEL 50;

group_by_count = group count_by_subject by count PARALLEL 50;

intermediate_counts = FOREACH group_by_count generate group, COUNT_STAR($1) as frequency PARALLEL 50;

--dump intermediate_counts;

counter = group intermediate_counts all PARALLEL 50;

total_count = foreach counter GENERATE COUNT_STAR(intermediate_counts) PARALLEL 50;

dump total_count;

