select * from PortfolioProject..covid_deaths
where continent is not null
order by 3,4;

--select * from PortfolioProject..covid_vaccinations
--order by 3,4;

--select data that we are going to be doing

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
order by 1,2;

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100 AS death_percentage
from PortfolioProject..covid_deaths
where location like '%india%' and continent is not null
order by 1,2;

--Looking at total cases vs population
--Shows what percentage of population got Covid

select location, date, population,total_cases, CONVERT(float, total_cases) /population *100 AS Infected_percentage
from PortfolioProject..covid_deaths
where location like '%india%' and continent is not null
order by 1,2;

--looking at countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) AS Highest_infection_count, MAX(CONVERT(float, total_cases) / population) * 100 AS Infected_percentage
FROM PortfolioProject..covid_deaths
--where location like '%india%'
GROUP BY location,population
ORDER BY Infected_percentage desc;

--Showing highest death count per population


SELECT location, MAX(convert(float, total_cases)) AS total_death_count
FROM PortfolioProject..covid_deaths
--where location like '%india%'
where continent is not null
GROUP BY location
ORDER BY total_death_count desc;


--breaking things down by continents

SELECT continent, MAX(convert(float, total_cases)) AS total_death_count
FROM PortfolioProject..covid_deaths
--where location like '%india%'
where continent is not null
GROUP BY continent
ORDER BY total_death_count desc;


-- Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM (new_cases) *100  as death_percentage
from PortfolioProject..covid_deaths
where continent is not null
--group by date 
order by 1,2;


--looking for Total Population vs Vaccinations

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated,
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

--use CTE

with PopvsVac (continent,location, date, population,new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rolling_people_vaccinated/population)*100
from PopvsVac;



--TEMP TABLE


drop table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #Percent_Population_Vaccinated

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(rolling_people_vaccinated)*100
from #Percent_Population_Vaccinated;



--Creating View to Store Data for Later Visualization

create View Percent_Population_Vaccinated as 
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


