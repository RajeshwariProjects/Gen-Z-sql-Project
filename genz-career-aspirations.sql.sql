use genzdataset;

-- 1. percentage of male and female gen-z wants to go to office everyday?

select 
       gender, 
       count(*) AS total_count,
       round(COUNT(*) * 100.0 / sum(count(*)) over(), 2) AS Percentage
from  
       learning_aspirations
inner join
        personalized_info 
on 
        personalized_info.ResponseID = learning_aspirations.ResponseID
where 
        PreferredWorkingEnvironment = 'Every Day Office Environment'
group by 
        gender;

-------------------------------------

-- 2. % ( gen-z who chose their career in BO are most likely to be influenced by their parents?

select
   round(count(*) * 100.0 / (select count(*) 
                               from learning_aspirations 
                                  where ClosestAspirationalCareer like 'Business%'),2) AS percentage
from 
   learning_aspirations
where 
   ClosestAspirationalCareer like 'Business%' 
   and CareerInfluenceFactor like 'My Parents';
   
   -------------------------------------
   
-- 3. % of gen-z prefer opting for higher studies, give a gender wise approach?

select
    gender AS Gender,
    count(*) AS TotalCount,
    count(case when la.HigherEducationAbroad like 'Yes%' then 1 else null end) AS PreferHigherStudiesCount,
    (count(case when la.HigherEducationAbroad like 'Yes%' then 1 ELSE null end) * 100.0) / 
          (select count(*)
	        from learning_aspirations la
		    join personalized_info pi ON la.responseID = pi.responseID) AS PercentagePreferHigherStudies
from
    learning_aspirations la
join
    personalized_info pi ON la.responseID = pi.responseID
group by 
    gender;



-------------------------------------

-- 4. % of gen-z willing or not willing to work for a
--  company whose missions is misaligned with their public actions or even their products?( gender split)

select gender, 
       MisalignedMissionLikelihood, 
       round(count(*) * 100.0 / (select count(*) 
                                   from mission_aspirations 
                                     inner join personalized_info 
                                      on personalized_info.ResponseID = mission_aspirations.ResponseID),2) AS Percentage
from 
     mission_aspirations 
inner join 
     personalized_info 
on 
     personalized_info.ResponseID = mission_aspirations.ResponseID
where 
	 gender is not null
group by 
     gender, MisalignedMissionLikelihood;


-- 5.  Most suitable working environment according to female gen-z?

select 
      PreferredWorkingEnvironment, 
      count(*) AS Fe_prefercount
from 
      learning_aspirations
inner join 
      personalized_info 
on 
      personalized_info.ResponseID = learning_aspirations.ResponseID
where 
      gender like 'Fe%'
group by 
      PreferredWorkingEnvironment
order by 
       count(*) desc;

-------------------------------------

-- 6. % of males who expected a salary 5 years > 50K & also work under employers who appreciates learning
  --    but doesn't enables a learning enivornment?

select 
		round(count(*) * 100.0 / 
           (select  COUNT(distinct ResponseID) AS total_count
             from (select ResponseID from learning_aspirations
				union
                select  ResponseID from manager_aspirations
                union
                select ResponseID from mission_aspirations
                union
                select ResponseID from personalized_info) AS combined_data),2) as Percentage
from 
      manager_aspirations
Inner join 
      mission_aspirations ON manager_aspirations.ResponseID = mission_aspirations.ResponseID
Inner join  
      personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID
where 
      gender like 'M%'
      and PreferredEmployer like 'Employers who appreciates learning but doesn''t enables an learning environment'
	  and ExpectedSalary5Years not like '30k to 50k';

--  (or)

select round(count(*) * 100.0 / 
           (select count(*)
           from manager_aspirations
           inner join mission_aspirations ON manager_aspirations.ResponseID = mission_aspirations.ResponseID
           inner join personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID),2) as Percentage
from 
	manager_aspirations
Inner join 
    mission_aspirations ON manager_aspirations.ResponseID = mission_aspirations.ResponseID
Inner JOIN 
	personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID
where 
      gender like 'M%'
      and PreferredEmployer like 'Employers who appreciates learning but doesn''t enables an learning environment'
	  and ExpectedSalary5Years not like '30k to 50k';

-------------------------------------

-- 8. total number of females who aspire to work in closest aspirational career.. and have no social impact likelihood of 1 to 5?

select 
      count(*) AS total_count
from  
	learning_aspirations
inner join 
    mission_aspirations ON learning_aspirations.ResponseID = mission_aspirations.ResponseID
inner join 
    personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID
where 
	gender like 'Fe%'
	and NoSocialImpactLikelihood in ( 1, 2, 3, 4, 5);
 
 -------------------------------------

-- 9. Retrieve the Males who are interested in higher education aboard and have a career influence factor of my parents?

 -- case 1. if it is the count of males 
 -- >
select 
   count(*) AS total_count
from 
   learning_aspirations
inner join 
   personalized_info on learning_aspirations.ResponseID = personalized_info.ResponseID
where 
	gender like 'M%'
      and HigherEducationAbroad like 'Yes%'
	  and CareerInfluenceFactor = 'My Parents';
      
  -- case 2. if it is the whole details of the males who meets the criteria

select *
from 
    learning_aspirations
inner join 
    manager_aspirations ON learning_aspirations.ResponseID = manager_aspirations.ResponseID
inner join 
    mission_aspirations ON manager_aspirations.ResponseID = mission_aspirations.ResponseID
inner join 
    personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID
where 
      gender like 'M%'
      and HigherEducationAbroad like 'Yes%'
	  and CareerInfluenceFactor = 'My Parents';
 
 -------------------------------------
      
-- 10. % of gender who have no social impact likelihood of 8 to 10 
                -- among those who are interested in higher studies aboard?

select gender, 
       round(count(*) * 100.0 /
	   (select count(*) 
              from learning_aspirations
              inner join mission_aspirations ON learning_aspirations.ResponseID = mission_aspirations.ResponseID
			  inner join personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID
where 
      HigherEducationAbroad = 'Yes, I wil'),2) AS percentage
from
      learning_aspirations
inner join
      mission_aspirations ON learning_aspirations.ResponseID = mission_aspirations.ResponseID
inner join
      personalized_info ON mission_aspirations.ResponseID = personalized_info.ResponseID
where 
      NoSocialImpactLikelihood between 8 and 10
      and HigherEducationAbroad = 'Yes, I wil'
group by 
      gender;

-------------------------------------

-- 11.  gen-z preferences to wrok with teams. 
         -- data should include male, female and overall in counts and also the overall in %
         
select
    gender,
    count(*) AS Count_Generation,
    sum(case when ma.PreferredWorkSetup LIKE '%team%' then 1 else 0 end) AS Count_PreferTeam,
    round((sum(case when ma.PreferredWorkSetup LIKE '%team%' then 1 else 0 end) * 100.0) / 
                                                                        count(*),2) AS Percentage_PreferTeam
from
    manager_aspirations ma
join
    personalized_info pi ON ma.responseID = pi.responseID
where
    gender is not null
group by
       gender;

-------------------------------------

-- 12. detailed breakdown of worklikelihood3years for each gender 

with work_Data AS (
    select
        Gender,
        case
            when WorkLikelihood3Years like '%Will work for 3 years or more%' then 'High Likelihood'
            when WorkLikelihood3Years like '%This will be hard to do, but if it is the right co%' then 'Medium Likelihood'
            when WorkLikelihood3Years like '%No way, 3 years with one employer is crazy%' then 'Low Likelihood'
            when WorkLikelihood3Years like '%No way%' then 'Low Likelihood'
            end AS Work_Likelihood_Category
    from
        manager_aspirations
    inner join
        personalized_info ON manager_aspirations.responseID = personalized_info.responseID)
select
    Gender,
    count(*) AS Count_of_Gender,
    sum(case
        when Work_Likelihood_Category = 'High Likelihood' then 1
        else 0
    end) AS High_Likelihood,
    sum(case
        when Work_Likelihood_Category = 'Medium Likelihood' then 1
        else 0
    end) AS Medium_Likelihood,
    sum(case
        when Work_Likelihood_Category = 'Low Likelihood' then 1
        else 0
    end) AS Low_Likelihood,
    round((count(*) * 100.0) / sum(count(*)) OVER (),2) AS Percentage
from
    work_Data
group by
    Gender;
    
  -------------------------------------  

-- 13. detailed breakdown of worklikelihood3years for each country

with CategorizedData AS (
    select
        currentcountry,
        case
            when WorkLikelihood3Years like '%Will work for 3 years or more%' then 'High Likelihood'
            when WorkLikelihood3Years like '%This will be hard to do, but if it is the right co%' then 'Medium Likelihood'
            when WorkLikelihood3Years like '%No way, 3 years with one employer is crazy%' then 'Low Likelihood'
            when WorkLikelihood3Years like '%No way%' then 'Low Likelihood'
            end AS Work_Likelihood_Category
    from
        manager_aspirations
    inner join
        personalized_info ON manager_aspirations.responseID = personalized_info.responseID)
select
    currentcountry,
    count(*) AS total_count,
    sum(case
        when Work_Likelihood_Category = 'High Likelihood' then 1
        else 0
    end) AS High_Likelihood,
    sum(case
        when Work_Likelihood_Category = 'Medium Likelihood' then 1
        else 0
    end) AS Medium_Likelihood,
    sum(case
        when Work_Likelihood_Category = 'Low Likelihood' then 1
        else 0
    end) AS Low_Likelihood,
    round((count(*) * 100.0) / sum(count(*)) OVER (),2) AS Percentage
from CategorizedData
group by currentcountry;
  
  -------------------------------------
    
-- 14.  average starting salary expectations at 3 year mark for each gender
 
 -- i divided the expectedsalary column into two parts to interpret the answers for starting and higherbar for both 3 years and 5 years
 
select
    p.gender AS Gender,
    -- to convert the categorical values to numeric values we assumed the midpoint of the range
   coalesce(round(avg(case
        when m.ExpectedSalary3Years = '5K to 10K' then 7500 
        when m.ExpectedSalary3Years = '11k to 15k' then 13000 
        when m.ExpectedSalary3Years = '16k to 20k' then 18000  
        when m.ExpectedSalary3Years = '21k to 25k' then 23000  
        else null
    end),0),0) AS starting_AverageSalaryExpectations_3
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null       
group by p.gender;

-------------------------------------

-- 15. average starting salary expectations at 5 year mark for each gender

select
    gender AS Gender,
      coalesce(round(avg(case
		when m.ExpectedSalary5Years like '30k%' then 40000
        when m.ExpectedSalary5Years like '50k%' then 60000 
        when m.ExpectedSalary5Years like '71k%' then 80000 
        when m.ExpectedSalary5Years like '91k%' then 100000  
        else null
    end),0),0) AS starting_AverageSalaryExpectations_5
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null
group by gender;

-------------------------------------

-- 16. average higher bar salary expectations at 3 year mark for each gender

select
    gender AS Gender,
    -- to convert the categorical values to numeric values we assumed the midpoint of the range
   coalesce(round(avg(case
		when m.ExpectedSalary3Years = '26k to 30k' then 28000
        when m.ExpectedSalary3Years = '31k to 40k' then 35500
        when m.ExpectedSalary3Years = '41k to 50k' then 45500
        when m.ExpectedSalary3Years = '>50k' then 55000 
        else null
    end),0),0) AS higherbar_AverageSalaryExpectations_3
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null       
group by gender;

-------------------------------------

-- 17. average higher bar salary expectations at 5 year mark for each gender

select
    gender AS Gender,
      coalesce(round(avg(case
		      when m.ExpectedSalary5Years like '111k%' then 120000  
              when m.ExpectedSalary5Years like '131k%' then 140000  
			  when m.ExpectedSalary5Years like '>151k%' then 155000 
              else null
              end),0),0) AS higherbar_AverageSalaryExpectations_5
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null
group by gender;

-------------------------------------

-- 18. average starting salary expectations at 3 year mark for each gender and each country
 
select
    gender AS Gender,
    currentcountry AS country,
    -- to convert the categorical values to numeric values we assumed the midpoint of the range
   coalesce(round(avg(case
        when m.ExpectedSalary3Years = '5K to 10K' then 7500 
        when m.ExpectedSalary3Years = '11k to 15k' then 13000 
        when m.ExpectedSalary3Years = '16k to 20k' then 18000  
        when m.ExpectedSalary3Years = '21k to 25k' then 23000  
        else null
    end),0),0) AS starting_AverageSalaryExpectations_3
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null 
      and currentcountry is not null      
group by gender, currentcountry;

-------------------------------------

-- 19. average starting salary expectations at 5 year mark for each gender and each country

select
    gender AS Gender,
    currentcountry AS country,
      coalesce(round(avg(case
		when m.ExpectedSalary5Years like '30k%' then 40000
        when m.ExpectedSalary5Years like '50k%' then 60000 
        when m.ExpectedSalary5Years like '71k%' then 80000 
        when m.ExpectedSalary5Years like '91k%' then 100000  
        else null
    end),0),0) AS starting_AverageSalaryExpectations_5
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null
      and currentcountry is not null
group by gender, currentcountry;

-------------------------------------

-- 20. average higher bar salary expectations at 3 year mark for each gender and each country

select
    gender AS Gender,
    currentcountry AS country,
    -- to convert the categorical values to numeric values we assumed the midpoint of the range
   coalesce(round(avg(case
		when m.ExpectedSalary3Years = '26k to 30k' then 28000
        when m.ExpectedSalary3Years = '31k to 40k' then 35500
        when m.ExpectedSalary3Years = '41k to 50k' then 45500
        when m.ExpectedSalary3Years = '>50k' then 55000 
        else null
    end),0),0) AS higherbar_AverageSalaryExpectations_3
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null 
      and currentcountry is not null      
group by gender, currentcountry;

-------------------------------------

-- 21. average higher bar salary expectations at 5 year mark for each gender and each country

select
    gender AS Gender,
    currentcountry AS country,
      coalesce(round(avg(case
		      when m.ExpectedSalary5Years like '111k%' then 120000  
              when m.ExpectedSalary5Years like '131k%' then 140000  
			  when m.ExpectedSalary5Years like '>151k%' then 155000 
              else null
              end),0),0) AS higherbar_AverageSalaryExpectations_5
from
    mission_aspirations m
inner join
    personalized_info p ON m.responseid = p.responseid
where gender is not null
      and currentcountry is not null
group by gender, currentcountry;

-------------------------------------

-- 22. detailed breakdown of the possibility of gen-z working for an org if the mission is misaligned for each country

select
    currentcountry AS Country,
    count(case when ma.MisalignedMissionLikelihood = 'Will work for them' then 1 else null end) AS Count_of_willwork,
    count(case when ma.MisalignedMissionLikelihood = 'Will NOT work for them' then 1 else null end) AS Count_of_willnotwork,
    count(*) AS TotalCount,
    round((count(case when ma.MisalignedMissionLikelihood = 'Will work for them' then 1 else null end) * 1.0) / count(*),2) AS Probability
from 
     mission_aspirations ma
join
    personalized_info pi ON ma.responseID = pi.responseID
where
	currentcountry is not null
group by
    currentcountry;

-------------------------------------

-- 7. correlation b/w gender about their preferred worksetup?

-- Hypothesis:

-- nullhypothesis: there is no association or relation between the gender and their preferred worksetup
-- alternativehypothesis: there is an association or relation between the gender and their preferred worksetup

WITH ContingencyTable AS (
    SELECT
        pi.gender AS Gender,
        la.PreferredWorkSetup AS WorkSetup,
        COUNT(*) AS Count
    FROM
        manager_aspirations la
    INNER JOIN
        personalized_info pi ON la.ResponseID = pi.ResponseID
    GROUP BY
        pi.gender, la.PreferredWorkSetup
),
TotalCounts AS (
    SELECT
        Gender,
        SUM(Count) AS TotalCount
    FROM
        ContingencyTable
    GROUP BY
        Gender
),
ChiSquaredContributions AS (
    SELECT
        CT.Gender AS Gender,
        CT.WorkSetup AS WorkSetup,
        CT.Count AS Count,
        (CT.Count * 100.0) / TC.TotalCount AS Percentage,
        (CT.Count - (TC.TotalCount * (CT.Count * 1.0) / (SELECT SUM(Count) FROM ContingencyTable)))^2 / 
        (TC.TotalCount * (CT.Count * 1.0) / (SELECT SUM(Count) FROM ContingencyTable)) AS ChiSquaredContribution
    FROM
        ContingencyTable CT
    JOIN
        TotalCounts TC ON CT.Gender = TC.Gender
),
ChiSquaredStatistic AS (
    SELECT SUM(ChiSquaredContribution) AS ChiSquaredStatistic
    FROM ChiSquaredContributions
)
SELECT
    CS.ChiSquaredStatistic AS ChiSquaredStatistic,
    (SELECT COUNT(DISTINCT Gender) FROM ContingencyTable) AS DegreesOfFreedom,
    0.05 AS Alpha, -- Set your significance level (alpha)
    3.841 AS CriticalValue, -- Manual critical value for alpha = 0.05 and degrees of freedom = 1 (adjust as needed)
    CASE
        WHEN CS.ChiSquaredStatistic > 3.841 THEN 'Significant'
        ELSE 'Not Significant'
    END AS Interpretation
FROM
    ChiSquaredStatistic CS;
    
-- Result: 
       
-- ChiSquaredStatistic > CriticalValue
 --  we reject the null hypothesis
 
  -- so, there is an association or relation between the gender and their preferred worksetup

                                             --------------- * -------------
