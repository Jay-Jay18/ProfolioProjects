Select *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4


--Select *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4


-- select data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- look at total cases VS total deaths
-- shows likelihood of dying of you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at total cases VS population 
-- shows what Percentage of population got Covid

SELECT location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- looking at country with highest infection rate compared to population


SELECT location, Population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, Population
ORDER BY PercentagePopulationInfected desc



-- showing country with highest death count per population

SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location 
ORDER BY TotalDeathCount desc

-- datatype is wrong, have to convert/cast as INT

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location 
ORDER BY TotalDeathCount desc

-- issue with location and continent have same names revise with not null



-- LETS BREAKE THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths

--WHERE location like '%states%'

where continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

-- showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
--group by date
ORDER BY 1,2


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac






-- TEMP TABLE

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3



select * 
from PercentPopulationVaccinated
