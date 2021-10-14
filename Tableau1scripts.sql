SELECT  SUM(cast(new_cases as float)) as total_cases, 
		SUM(cast(new_deaths as float)) as total_deaths, 
		SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths1
	where NULLIF(continent, '') is null
	and location not in ('World', 'European Union', 'International')
--Group by date
	order by 1,2



Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths1
--Where location like '%states%'
Where NULLIF(continent, '') is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

SELECT location, population,  MAX(total_cases) as HighestInfectionCount, MAX(ISNULL(cast([total_cases] as float)/NULLIF(cast([population] as float), 0),0)) *100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths1
--WHERE location like '%France%'
group by location, population
order by PercentOfPopulationInfected DESC

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



https://public.tableau.com/app/profile/ana.moisa/viz/CovidNumbersDashboard_16341165282020/CovidNumbersDashboard?publish=yes
