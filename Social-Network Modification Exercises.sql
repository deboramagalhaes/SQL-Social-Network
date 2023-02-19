-- Q1 Remove all 12th graders from Highschooler.

delete from Highschooler
where grade = 12

--Q2 If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.

delete from Likes
where ID1 in (	select A -- it is necessary to select only a columm from Aux table, to be able compare with ID1
				from (	select F.ID1 as A, L1.ID2 as A_Likes,
								F.ID2 as B, L2.ID2 as B_Likes
						from Friend F
						 left join Likes L1 -- this join gets the person who A likes
							on F.ID1 = L1.ID1
						left join Likes L2 -- this join gets the person who B likes
							on F.ID2 = L2.ID1
						where (L1.ID2 = F.ID2 and L2.ID2 <> F.ID1) -- this condition compares if A and B like each other
								or (L1.ID2 is null and L2.ID2 = F.ID1) -- this condition checks if A likes no one whereas B likes A
								or (L2.ID2 is null and L1.ID2 = F.ID2)) -- this condition checks if B likes no one whereas A likes B
								as Aux )
		and ID2 in ( select B -- it is necessary to select only a columm from Aux table, to be able compare with ID2
					 from (	select F.ID1 as A, L1.ID2 as A_Likes,
									F.ID2 as B, L2.ID2 as B_Likes
							from Friend F
							 left join Likes L1 -- this join gets the person who A likes
								on F.ID1 = L1.ID1
							left join Likes L2 -- this join gets the person who B likes
								on F.ID2 = L2.ID1
							where (L1.ID2 = F.ID2 and L2.ID2 <> F.ID1) -- this condition compares if A and B like each other
									or (L1.ID2 is null and L2.ID2 = F.ID1) -- this condition checks if A likes no one whereas B likes A
									or (L2.ID2 is null and L1.ID2 = F.ID2)) -- this condition checks if B likes no one whereas A likes B
									as Aux )

-- Q3 For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. 
-- Do not add duplicate friendships, friendships that already exist, or friendships with oneself.

insert into Friend
select F1.ID1 A, F2.ID2 C -- first create the pairs of students A and C
from Friend F1
left join Friend F2 
	on F1.ID2 = F2.ID1
where F1.ID1 <> F2.ID2 -- then remove pairs where A = C
except
select * from Friend -- finally remove friendships that already exist