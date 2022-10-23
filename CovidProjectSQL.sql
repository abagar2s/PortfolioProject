--Select Data that we are going to be using

SELECT Location,Date, total_cases, new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
order by 1,2

--looking at Total cases vs total deaths in my country

SELECT Location, date, total_cases,total_deaths,
(CAST(total_deaths as float)/CAST(total_cases as float))*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Morocco'
order by 1,2

--looking at Total cases vs population in my country

SELECT Location, date, total_cases,population,
(CAST(total_cases as float)/CAST(population as float))*100 as infectionrate
FROM PortfolioProject..CovidDeaths
WHERE location like 'Morocco'
order by 1,2

--looking at countries with highest infection rate compared to population  

SELECT Location, population,MAX(CAST(total_cases as float)) as HighestInfectionCount,
MAX((CAST(total_cases as float)/CAST(population as float)))*100 as infectionrate
FROM PortfolioProject..CovidDeaths
GROUP BY Location ,population
order by infectionrate desc

--Highest deathcount by Population

SELECT Location,MAX(CAST(total_deaths as float)) as HighestDeathCount,
MAX((CAST(total_deaths as float)/CAST(population as float)))*100 as Deathrate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location 
order by HighestDeathCount desc


-- by Continent 

SELECT continent,MAX(CAST(total_deaths as float)) as HighestDeathCount,
MAX((CAST(total_deaths as float)/CAST(population as float)))*100 as Deathrate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
order by HighestDeathCount desc

-- Total population and vaccicnation
Select dea.continent, dea.location, dea.date , dea.population, vacc.new_vaccinations,
SUM(CAST(new_vaccinations as float)) OVER (PARTITION BY dea.location order by dea.location , dea.date)
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vacc
on dea.location = vacc.location and dea.date = vacc.date
WHERE dea.continent is not null
order by 2,3


--using CtEs
--population vs vaccination
WITH PopvsVac (continent, location, date , population, new_vaccinations, RollingPeopleVaccinated) as(
Select dea.continent, dea.location, dea.date , dea.population, vacc.new_vaccinations,
SUM(CAST(new_vaccinations as float)) OVER (PARTITION BY dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vacc
on dea.location = vacc.location and dea.date = vacc.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) as RollingPeopleVaccinatedRate FROM PopvsVac