-- pig q5
register /Users/jmbeck/Documents/Learning/UW_Coursera/datasci_course_materials/assignment4/pigtest/myudfs.jar

raw = LOAD '/Users/jmbeck/Documents/Learning/UW_Coursera/proj_data/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

ntriples_filtered = FILTER ntriples BY (subject matches '.*rdfabout\\.com.*');

right_side = FOREACH ntriples_filtered GENERATE subject as right_subject, predicate as right_pred, object as right_object;

joined = JOIN ntriples_filtered by object, right_side by right_subject;

joined_uniq = DISTINCT joined;

store joined_uniq into '/Users/jmbeck/Desktop/q5_chunk0/' using PigStorage();