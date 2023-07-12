select * from covid..cd;
select * from covid..cv;

select location,new_cases,total_cases, date, population from covid..cd order by date desc;

--total death percentage in india
select location,total_cases,total_deaths, population,(total_deaths/total_cases)*100 as death_percentage 
from covid..cd where location='india'

-- country with highest infection rate compared to population
select location, max(total_cases) as infected, population, max((total_cases/population)*100) as infection_rate  from covid..cd
Group by location, population order by infection_rate desc ;

--country with highest death count

select location, max(total_deaths) as death, max(population) as popu ,  max(total_deaths)/max(population)*100 as deathpercentage from covid..cd 
group by location order by deathpercentage desc 


--continent with highest death count
select continent, max(total_deaths) as death from covid.. cd where continent is not null
group by continent order by death desc

-- global cases date wise and total death percentage

select date,max(total_cases) as total_cases , max(cast(total_deaths as int)) as total_deaths , max(cast(total_deaths as int))/max(total_cases)*100 as death_percentage
from covid..cd 
where continent is not null
group by date
order by date 


--  total cases and total death percentages  in the world
select max(total_cases)as total_cases, max(cast(total_deaths as int)) as dea, round(max(cast(total_deaths as int))/max(total_cases),5)*100 as percentage
from covid..cd


 -- joining both the tables

 select * from covid.. cd as a left join covid..cv as b on a.location=b.location and a.date=b.date

 -- looking at total population vs total vaccination country wise 

 select dea.location, max(dea.population) popu, max(vac.total_vaccinations) tot_vac , (max(vac.total_vaccinations)/max(dea.population))*100 vac_percentage
 from covid..cd dea JOIN covid..CV vac on dea.location=vac.location and dea.date= vac.date
 where dea.population is not null
 group by dea.location, dea.population;


-- looking at total population vs total vaccination in percentage
-- Using CTE to perform Calculation on Partition By in previous query

 
with population_vs_vaccination (continent, location, date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..cd dea
Join covid..cv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select * from population_vs_vaccination


-- Creating View to store data for later visualizations

create view a_Percentage_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..cd dea
Join covid..cv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from a_Percentage_Population_Vaccinated

create view covid_world_data as

select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from covid..cd 









