

/*
Covid 19 Data Exploration with data up to April 2023
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [dbo].[CovidDeaths]
Where continent is not null 
order by 3,4

-- Select Data to start with 

Select Location, date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeaths]
Where continent is not null 
order by 1,2


 Total Cases vs Total Deaths : Likelihood of death if covid is contracted


Select [location],[date],[total_cases],[total_deaths],([total_deaths]/[total_cases])*100 as DeathPercentage 
From [dbo].[CovidDeaths]
where continent is not null
Where [location]  like '%United Kingdom%'
and date between '2020-03-18' and '2023-04-26'
order by 1,2 

--Total  infected cases vs population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentInfectedPop
From [dbo].[CovidDeaths]
where continent is not null
Where Location = 'United Kingdom'
and date between '2020-03-18' and '2023-04-26'
Order by 1,2 desc


--Countries with Highest Infection rates

Select Location,  Max(total_cases) as HighestInfectionCount , population, Max((total_cases/population))*100 as PercentInfectedPop
From [dbo].[CovidDeaths]
where continent is not null
Group by Location, Population
Order by PercentInfectedPop desc

--Countries with Highest Death Count per Population 

Select Location,  Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
where continent is not null
Group by Location
Order by TotalDeathCount desc

--Death Counts by Continent

Select continent,  Max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
where continent is not null
Group by continent 
Order by TotalDeathCount desc

--Looking at Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast
(new_deaths as int)) as total_deaths, (SUM(new_deaths ) /Sum(new_cases))*100 as DeathPercentage 
From [dbo].[CovidDeaths]
where continent is not null
Order by 1,2

--Total Population vs Vaccinations

select  cd.location, cd.date, cd.population, cv.new_vaccinations,
(SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date)) as RollingVacCount
from CovidVaccinations cv
join CovidDeaths cd
on cv.location = cd.location
and cv.date = cd. date
where cd.continent is not null
 order by 2,3 asc


 --USING CTE to perform Calculation on Partition By in previous query 

 WITH PopvsVac( continent,location,date, population,new_vaccinations,RollingVacCount)

 AS(
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
(SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date)) as RollingVacCount
from CovidVaccinations cv
join CovidDeaths cd
on cv.location = cd.location
and cv.date = cd. date
where cd.continent is not null
 --order by 2,3 asc)
)
Select * , ((RollingVacCount/Population)*100) as PercentPopulationVaccinated
From PopvsVac

--Using Temp Table to perform Caculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar (50),
Location varchar(50),
Date date,
Population numeric,
New_vaccinations numeric,
RollingVacCount numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
(SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date)) as RollingVacCount
from CovidVaccinations cv
join CovidDeaths cd
on cv.location = cd.location
and cv.date = cd. date
where cd.continent is not null
 --order by 2,3 asc


 Select * , ((RollingVacCount/Population)*100) as PercentPopulationVaccinated
From #PercentPopulationVaccinated


 -- Create View to store Data for Visualizations 

 Create View PercentPopulationVaccinated as 

 Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
(SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date)) as RollingVacCount
from CovidVaccinations cv
join CovidDeaths cd
on cv.location = cd.location
and cv.date = cd. date
where cd.continent is not null
