SELECT *
FROM PortfolioProject..CovidDeaths1
Where continent is not null
order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations1
Where continent is not null
order by 3,4

-- Select the data that we are going to be using



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths1
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float)) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths1
WHERE location like '%France%'
order by date DESC

-- Looking at Total Cases vs Population
-- shows what percentage of the population got COVID

SELECT location, date, population, total_cases, (cast(total_cases as float)/cast(population as float)) *100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths1
WHERE location like '%France%'
order by 1,2

--Looking at what countries have the highest infection rate compared to their population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(ISNULL(cast([total_cases] as float)/NULLIF(cast([population] as float), 0),0)) *100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths1
--WHERE location like '%France%'
group by location, population
order by PercentOfPopulationInfected DESC

--Looking at the Countries with the highest death count per population

SELECT location, MAX(cast (total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths1
WHERE location like '%France%'
group by location
order by TotalDeathCount DESC



-- Let's break things down by continent

SELECT continent, MAX(cast (total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths1
where continent is not null
Group by continent
order by TotalDeathCount desc 

SELECT location, MAX(cast (total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths1
where continent is not null
Group by location
order by TotalDeathCount desc 


--Global Numbers


SELECT  SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths1
where continent is not null
--Group by date
order by 1,2 

--Looking at total vaccination vs total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast (vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
JOIN PortfolioProject..CovidVaccinations1 vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE

WITH PopvsVac ( continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
	JOIN PortfolioProject..CovidVaccinations1 vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (ISNULL (cast(RollingPeopleVaccinated as float)/NULLIF(cast(population as float),0),0)) *100
from PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population nvarchar(255),
new_vaccinations nvarchar(255),
RollingPeopleVaccinated nvarchar(255),
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
	JOIN PortfolioProject..CovidVaccinations1 vac
	ON dea.location= vac.location
	and dea.date= vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (ISNULL (cast(RollingPeopleVaccinated as float)/NULLIF(cast(population as float),0),0)) *100
from #PercentPopulationVaccinated

--Creating VIEW to store data for later visualisations

GO -- use GO after the CTE and before CREATE VIEW to avoid the 'incorrect statement CREATE VIEW should be the only statement in the batch' error
CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
	SUM(CONVERT (float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
	JOIN PortfolioProject..CovidVaccinations1 vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
;
SELECT * 
From PercentPopulationVaccinated 

