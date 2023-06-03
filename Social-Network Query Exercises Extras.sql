-- Q1 For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.

select H1.name as nameA, H1. grade as gradeA,
	H2.name as nameB, H2. grade as gradeB,
	H3.name as nameC, H3. grade as gradeC
from Likes L1
left join Likes L2 -- this join gathers students A, B and C in each tuple of the table 
	on L1.ID2 = L2.ID1
	left join Highschooler H1  -- this join is necessary to find name and grade of student A
		on L1.ID1 = H1.ID
		left join Highschooler H2 -- this join is necessary to find name and grade of student B
			on L1.ID2 = H2.ID
			left join Highschooler H3 -- this join is necessary to find name and grade of student C
				on L2.ID2 = H3.ID
where L1.ID1 <> L2.ID2 --  this condition brings the results where A likes B, but B likes C

-- Q2 Find those students for whom all of their friends are in different grades from themselves. 
-- Return the students' names and grades.
select name, grade
from Highschooler
where ID not in (	-- this subquery finds the IDs of studentes who have any friends in their grades
					select ID1 -- The ID is used as a reference because this number is unique for each student
					from Friend F
					left join Highschooler H1
						on F.ID1 = H1.ID
					left join Highschooler H2
						on F.ID2 = H2.ID
					where H1.grade = H2.grade)

-- Q3 What is the average number of friends per student? 

select avg(count_friends) 'average_friends_per_student'
from (	select ID1, count(ID1) 'count_friends'
		from Friend
		group by ID1) as Aux

-- Q4 Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra

select count(ID1)
from (	-- this query finds all friends of Cassandra's friends
	select ID1 
	from Friend
	where ID2 in (	-- this query finds all Cassandra's friends
			select ID1 
			from Friend
			where ID2 = (	--  this query finds Cassandra's ID
					select ID 
					from Highschooler
					where name = 'Cassandra'))) as Aux

-- Q5 Find the name and grade of the student(s) with the greatest number of friends.

select name, grade
from (	select distinct name, grade, count(id1) as 'number of friends'
	from Friend F
	left join Highschooler H
		on F.id1 = H.id
	group by name, grade) as Aux
where [number of friends] =  (	select max([number of friends])
								from (	select distinct name, grade, count(id1) as 'number of friends'
										from Friend F
										left join Highschooler H
											on F.id1 = H.id
										group by name, grade) as Aux)
