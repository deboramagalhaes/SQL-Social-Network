-- Students at your hometown high school have decided to organize their social network using databases. 
-- So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema:
-- Highschooler ( ID, name, grade ) --> There is a high school student with unique ID and a given first name in a certain grade.
-- Friend ( ID1, ID2 ) --> The student with ID1 is friends with the student with ID2. Friendship is mutual.
-- Likes ( ID1, ID2 ) --> The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual.


-- Q1 Find the names of all students who are friends with someone named Gabriel.

select name
from Friend F
left join Highschooler H
	on F.ID1 = H.ID
where ID2 in (	select id -- this query finds the ID for all stundents named Gabriel
		from Highschooler
		where name = 'Gabriel')

-- Q2 For every student who likes someone 2 or more grades younger than themselves, 
-- return that student's name and grade, and the name and grade of the student they like.

select H1.name as 'name_student1', H1.grade as 'grade_student1', 
		H2.name as 'name_student2', H2.grade as 'grade_student2'
from Likes L
left join Highschooler H1
	on L.ID1 = H1.ID
left join Highschooler H2
	on L.ID2 = H2.ID
where H1.grade >= H2.grade + 2

-- Q3 For every pair of students who both like each other, return the name and grade of both students. 
-- Include each pair only once.

select	H1.name as nameA, H1.grade as gradeA, 
		H2.name as nameB, H2.grade as gradeB
from Likes L1
left join Likes L2 -- this join gathers students A, B, and who B likes, in each tuple of the table 
	on L1.ID2 = L2.ID1
	left join Highschooler H1 -- this join gathers name and grade informations for student A
		on L1.ID1 = H1.ID
		left join Highschooler H2 -- this join gathers name and grade informations for student B
			on L1.ID2 = H2.ID
where	L1.ID1 = L2.ID2 -- this condition guarantees A and B like each other
		and L1.ID1 < L1.ID2 -- with this condition and both conditions in the order by bellow, we select each pair only once
order by L1.ID1, L1.ID2 desc

-- Q4 Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. 
-- Sort by grade, then by name within each grade.

select name, grade
from Highschooler
where	ID not in (select ID1 from Likes) 
	and ID not in (select ID2 from Likes)
order by grade, name

-- Q5 For every situation where student A likes student B, but we have no information about 
-- whom B likes (that is, B does not appear as an ID1 in the Likes table), 
-- return A and B's names and grades.

select H1.name as 'name student 1', H1.grade as 'grade student 1', 
	H2.name as 'name student 2', H2.grade as 'grade student 2'
from Likes L
left join Highschooler H1 -- this join is necessary to gather name and grade for student 1
	on L.ID1 = H1.ID
left join Highschooler H2 -- this join is necessary to gather name and grade for student 2
	on L.ID2 = H2.ID
where ID2 in (	select distinct ID2 -- this subquery finds every student with no information in Likes of whom they like
		from Likes
		where ID2 not in (select ID1
				 from Likes))

-- Q6 Find names and grades of students who only have friends in the same grade. 
-- Return the result sorted by grade, then by name within each grade.

select name, grade
from Highschooler
where ID not in (-- this subquery finds the IDs of studentes who have friends in different grades
			select ID1 -- The ID is used as a reference because this number is unique for each student
			from Friend F
			left join Highschooler H1
				on F.ID1 = H1.ID
				left join Highschooler H2
					on F.ID2 = H2.ID
			where H1.grade <> H2.grade)
order by grade, name

--Q7 For each student A who likes a student B where the two are not friends, find if they have a friend C in common. 
-- For all such trios, return the name and grade of A, B, and C.

select	H1.name nameA, H1.grade gradeA,
	H2.name nameB, H2.grade gradeB,
	H3.name nameC, H3.grade gradeC
from (select *
	from Likes
	where ID1 not in -- this condition selects student A and who they like, student B, only if they are not friends
							(select Aux.ID1
							from (
							select distinct L.ID1, L.ID2, F.ID2 as likes -- this query selects students who are friends with whom they like
							from Likes L
							left join Friend F
								on L.ID1 = F.ID1
							where L.ID2 = F.ID2) Aux)	) as Aux2
left join Friend F1 -- this query includes C, who is friends with A
	on Aux2.ID1 = F1.ID1
left join Friend F2 -- this query includes C, who is friends with B
	on Aux2.ID2 = F2.ID1
left join Highschooler H1 -- this query includes A's name and grade
	on Aux2.ID1 = H1.ID
left join Highschooler H2 -- this query includes B's name and grade
	on Aux2.ID2 = H2.ID
left join Highschooler H3 -- this query includes C's name and grade
	on F1.ID2 = H3.ID
where F1.ID2 = F2.ID2 -- this condition compares A and B's friends, looking for a C in common

-- Q8 Find the difference between the number of students in the school and the number of different first names.

select (select count(distinct(id))
	from Highschooler) -
	(select count(distinct(name))
	from Highschooler)

-- Q9 Find the name and grade of all students who are liked by more than one other student.

select name, grade
from ( -- this query finds the students who are liked by more than one other student
		select ID2, count(ID2) 'count' 
		from likes
		group by ID2
		having count(ID2) > 1) as Aux
left join Highschooler H
	on Aux.ID2 = H.ID
