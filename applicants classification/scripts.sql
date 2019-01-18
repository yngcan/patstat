 USE `your_database`;

-- STEP 1 Create table with probably legal entities where inventors sequence is equal than 1 
CREATE TABLE entities_recognition_probably_legal AS
SELECT doc_std_name_id,
       doc_std_name,
       person_id,
       person_name,
       invt_seq_nr
FROM applt_addr_ifris
WHERE invt_seq_nr = 0
GROUP BY doc_std_name_id;
 
-- STEP 2 Create table with unkown entities where inventors sequence is different than 0
CREATE TABLE entities_recognition_unkown AS
SELECT doc_std_name_id,
       doc_std_name,
       person_id,
       person_name,
       invt_seq_nr
FROM applt_addr_ifris
WHERE invt_seq_nr > 0
GROUP BY doc_std_name_id;

-- Clean repeated data
DELETE
FROM entities_recognition_unkown
WHERE doc_std_name_id IN
    (SELECT doc_std_name_id
     FROM entities_recognition_probably_legal);

-- STEP 3  Create table with probably individuals where source is different than “Missing”
CREATE TABLE entities_recognition_probably_person AS
SELECT doc_std_name_id,
       doc_std_name,
       person_id,
       person_name,
       invt_seq_nr
FROM entities_recognition_unkown
WHERE doc_std_name_id IN
    (SELECT doc_std_name_id
     FROM patstat_database.invt_addr_ifris
     WHERE SOURCE <> "MISSING");

-- CLEAN REPEATED DATA
DELETE
FROM entities_recognition_unkown
WHERE doc_std_name_id IN
    (SELECT doc_std_name_id
     FROM entities_recognition_probably_person);

-- STEP 4 The applicants with no more than 1 application
INSERT INTO prob_person
SELECT   
		 a.person_id,
		 a.person_name,	 
		 a.doc_std_name_id,
		 a.doc_std_name,
		 a.invt_seq_nr
FROM     unkown as a
INNER JOIN applt_addr_ifris AS b ON a.doc_std_name_id = b.doc_std_name_id  
GROUP BY doc_std_name_id
HAVING   COUNT(a.doc_std_name_id) < 2

-- CLEAN REPEATED DATA
DELETE FROM known WHERE known.doc_std_name_id in (SELECT prob_person.doc_std_name_id FROM prob_person); 

-- STEP 5 From probable legal to probable person set

INSERT INTO prob_person
SELECT   
		 a.person_id,
		 a.person_name,	 
		 a.doc_std_name_id,
		 a.doc_std_name,
		 a.invt_seq_nr
FROM     prob_legal as a
INNER JOIN applt_addr_ifris AS b ON a.doc_std_name_id = b.doc_std_name_id  
WHERE a.doc_std_name_id IN (SELECT doc_std_name_id FROM invt_addr_ifris)
GROUP BY doc_std_name_id
HAVING   COUNT(a.doc_std_name_id) < 21
ORDER BY COUNT(a.doc_std_name_id) DESC 


-- CLEAN REPEATED DATA
DELETE FROM prob_legal WHERE prob_legal.doc_std_name_id in (SELECT doc_std_name_id FROM prob_person); 

-- STEP 6 From probable legal to probable person set2

INSERT INTO prob_person
  SELECT   
		 a.person_id,
		 a.person_name,	 
		 a.doc_std_name_id,
		 a.doc_std_name,
		 a.invt_seq_nr
FROM     prob_legal as a
INNER JOIN applt_addr_ifris AS b ON a.doc_std_name_id = b.doc_std_name_id  
WHERE (a.person_name LIKE "%,%" OR a.person_name LIKE "%;%") AND (a.doc_std_name_id IN (SELECT doc_std_name_id FROM invt_addr_ifris))
GROUP BY doc_std_name_id
HAVING   COUNT(a.doc_std_name_id) < 200

-- CLEAN REPEATED DATA
DELETE FROM prob_legal WHERE prob_legal in (SELECT prob_person.doc_std_name_id FROM prob_person); 


-- STEP 7 Create temporal table

CREATE TABLE temporal AS
 SELECT
	   a.person_id,
	   a.person_name,	 
	   a.doc_std_name_id,
	   a.invt_seq_nr,
	   a.cnt,
	   b.cnt as cnt2
	FROM (
	  SELECT 
	  person_id,
	  person_name,	 
	  doc_std_name_id,
	  invt_seq_nr,
	  count(*) as cnt
	  from applt_addr_ifris
	  where invt_seq_nr < 1
	  GROUP BY doc_std_name_id
	) AS a
	INNER JOIN (
	  SELECT 
	  doc_std_name_id,
	  count(*) as cnt
	  from applt_addr_ifris
	  where invt_seq_nr > 0
	  GROUP BY doc_std_name_id
	) AS b ON a.doc_std_name_id = b.doc_std_name_id
HAVING (a.cnt*100 / (b.cnt + a.cnt)) < 20 

-- CLEAN REPEATED DATA
DELETE FROM prob_legal WHERE prob_legal.doc_std_name_id in (SELECT doc_std_name_id FROM temporal); 
