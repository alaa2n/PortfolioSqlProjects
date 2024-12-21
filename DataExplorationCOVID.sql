select * from dbo.CovidDeathsEdited
select * from dbo.CovidVaccinations

select location , date , population , total_cases , new_cases , total_deaths
from dbo.CovidDeathsEdited
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
select location , date , total_cases , total_deaths , 
(total_deaths/total_cases)*100 as DeathsPercentage 
from dbo.CovidDeathsEdited
where location like 'B%' and continent is not null
order by 1,2

-- Total Cases vs Population
select location , date , total_cases , population , 
(total_cases/population)*100 as PeopleInfectedPercentage
from dbo.CovidDeathsEdited
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select location , population, max(total_cases) as HighestInfectionCount , 
max((total_cases/population))*100 as HighestPercentagePopulationInfected
from dbo.CovidDeathsEdited
group by location,population
order by HighestPercentagePopulationInfected desc

-- Countries with Highest Death Count per Population
select location ,population, max(total_deaths) as HighestDeathCount 
from dbo.CovidDeathsEdited
where continent is not null
group by location,population
order by HighestDeathCount desc

-- Showing contintents with the highest death count per population
select continent , max(total_deaths) as HighestDeathCount
from CovidDeathsEdited
where continent is not null
group by continent
order by HighestDeathCount desc

-- GLOBAL NUMBERS(Summery)
select sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeaths,
sum(new_deaths)/sum(new_cases) * 100 as NewDeathPercentage
from CovidDeathsEdited 
where continent is not null 
order by 1,2

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dth.continent, dth.location , dth.date, dth.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as  RollingPeopleVaccinated
from CovidDeathsEdited dth
Join CovidVaccinations vac
on dth.location = vac.location 
and dth.date = vac.date
where dth.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with PeopleVsVaccination(Continent, Location, Date,Population , New_Vaccinations,RollingPeopleVaccinated)
as
(
select dth.continent, dth.location , dth.date, dth.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as  RollingPeopleVaccinated
from CovidDeathsEdited dth
Join CovidVaccinations vac
on dth.location = vac.location 
and dth.date = vac.date
where dth.continent is not null 
)
select * , (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PeopleVsVaccination

-- Using Temp Table to perform Calculation on Partition By in previous query
Drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated
select dth.continent, dth.location , dth.date, dth.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as  RollingPeopleVaccinated
from CovidDeathsEdited dth
Join CovidVaccinations vac
on dth.location = vac.location 
and dth.date = vac.date
where dth.continent is not null 
order by 2,3
select * , (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from #PercentPeopleVaccinated

-- Creating View to store data
CREATE VIEW PercentedPopulationVaccinated as
select dth.continent, dth.location , dth.date, dth.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dth.location order by dth.location,dth.date) as  RollingPeopleVaccinated
from CovidDeathsEdited dth
Join CovidVaccinations vac
on dth.location = vac.location 
and dth.date = vac.date
where dth.continent is not null 
select * from PercentedPopulationVaccinated
