--Select Data that we are going to be using

SELECT Location,Date, total_cases, new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
order by 1,2

--looking at Total cases vs total deaths in my country

SELECT Location, date, total_cases,total_deaths,(try_convert(numeric(10,0), total_deaths)/try_convert(numeric(10,0), total_cases))*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Morocco'
order by 1,2

--looking at Total cases vs population in my country

SELECT Location, date, total_cases,population,(try_convert(numeric(10,0), total_cases)/try_convert(numeric(10,0), population))*100 as infectionrate
FROM PortfolioProject..CovidDeaths
WHERE location like 'Morocco'
order by 1,2

--looking at countries with highest infection rate compared to population  

SELECT Location, population,MAX(try_convert(numeric(15,0), total_cases)) as HighestInfectionCount,
MAX((try_convert(numeric(15,0), total_cases)/try_convert(numeric(15,0), population)))*100 as infectionrate
FROM PortfolioProject..CovidDeaths
GROUP BY Location ,population
order by infectionrate desc

--Highest deathcount by Population

SELECT Location,MAX(try_convert(numeric(15,0), total_deaths)) as HighestDeathCount,
MAX((try_convert(numeric(15,0), total_deaths)/try_convert(numeric(15,0), population)))*100 as Deathrate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location 
order by HighestDeathCount desc


-- by Continent 

SELECT continent,MAX(try_convert(numeric(15,0), total_deaths)) as HighestDeathCount,
MAX((try_convert(numeric(15,0), total_deaths)/try_convert(numeric(15,0), population)))*100 as Deathrate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
order by HighestDeathCount desc

-- Total population and vaccicnation
Select dea.continent, dea.location, dea.date , dea.population, vacc.new_vaccinations,
SUM(try_convert(numeric(15,0), vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location , dea.date)
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vacc
on dea.location = vacc.location and dea.date = vacc.date
WHERE dea.continent is not null
order by 2,3


--using CtEs
--population vs vaccination
WITH PopvsVac (continent, location, date , population, new_vaccinations, RollingPeopleVaccinated) as(
Select dea.continent, dea.location, dea.date , dea.population, vacc.new_vaccinations,
SUM(try_convert(numeric(15,0), vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vacc
on dea.location = vacc.location and dea.date = vacc.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 FROM PopvsVac