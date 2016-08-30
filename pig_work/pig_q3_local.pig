-- pig q3
register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

subjects = group ntriples by (subject);

count_by_subject = FOREACH subjects generate group, COUNT_STAR($1) as count;

group_by_count = group count_by_subject by count;

intermediate_counts = FOREACH group_by_count generate group, COUNT_STAR($1) as frequency;

dump intermediate_counts;