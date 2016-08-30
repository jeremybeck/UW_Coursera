-- pig q1



-- pig q2
register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/cse344-test-file' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

subjects = group ntriples by (subject);

count_by_subject = FOREACH subjects generate group, COUNT_STAR($1) as count;

group_by_count = group count_by_subject by count;

intermediate_counts = FOREACH group_by_count generate group, COUNT_STAR($1) as frequency;

--dump intermediate_counts;

counter = group intermediate_counts all;

total_count = foreach counter GENERATE COUNT_STAR(intermediate_counts);

dump total_count;


-- pig q3
register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

subjects = group ntriples by (subject);

count_by_subject = FOREACH subjects generate group, COUNT_STAR($1) as count;

group_by_count = group count_by_subject by count;

intermediate_counts = FOREACH group_by_count generate group, COUNT_STAR($1) as frequency;

dump intermediate_counts;


-- pig q4
register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/cse344-test-file' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

ntriples_filtered = FILTER ntriples BY (subject MATCHES '.*business.*');

right_side = FOREACH ntriples_filtered GENERATE subject as right_subject, predicate as right_pred, object as right_object;

joined = JOIN ntriples_filtered by subject, right_side by right_subject;

joined_uniq = DISTINCT joined;

store joined_uniq into '/Users/jmbeck/Desktop/q4_testfile/' using PigStorage();


-- pig q5
register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

ntriples_filtered = FILTER ntriples BY (subject matches '.*rdfabout\\.com.*');

right_side = FOREACH ntriples_filtered GENERATE subject as right_subject, predicate as right_pred, object as right_object;

joined = JOIN ntriples_filtered by object, right_side by right_subject;

joined_uniq = DISTINCT joined;

store joined_uniq into '/Users/jmbeck/Desktop/q5_chunk0/' using PigStorage();



-- full dataset
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




register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/cse344-test-file' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);
subjects = group ntriples by (subject);

count_by_subject = foreach subjects generate group, COUNT($1) as count;

intermediate_group = group count_by_subject by (count);
countbyintermediatecount = foreach intermediate_group generate group as subjectcount, COUNT($1) as entriespersubjectcount;
countbyintermediatecountordered = order countbyintermediatecount by entriespersubjectcount;