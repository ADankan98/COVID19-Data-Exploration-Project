select * 
from [Portfolio Project]..CovidDeaths$
order by 3,4

--select * 
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

--SELECTING THE DATA WE SHALL BE WORKING WITH

select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project]..CovidDeaths$
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Shows the likelihood of dying if you contract covid in United States

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where location like '%states%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--Shows what percentage of population got covid in Kenya

select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where location = 'Kenya'
order by 1,2

--LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location, max(cast(total_deaths as int)) as HighestDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by HighestDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
--Shows continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
order by HighestDeathCount desc

--GLOBAL COVID NUMBERS

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

-- TOTAL POPULATION VS VACCINATIONS
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..['CovidVaccinations$'] vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..['CovidVaccinations$'] vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..['CovidVaccinations$'] vac
     on dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View 
PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..['CovidVaccinations$'] vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null 