register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/cse344-test-file' USING TextLoader as (line:chararray);
--raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/btc-2010-chunk-000' USING TextLoader as (line:chararray);


ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

objects = group ntriples by (object);

count_by_object = foreach objects generate flatten($0), COUNT($1) as count PARALLEL 50;

count_by_object_ordered = order count_by_object by (count) PARALLEL 50;

counter = group count_by_object all PARALLEL 50;

total_count = foreach counter GENERATE COUNT_STAR(count_by_object) PARALLEL 50;

dump total_count;
