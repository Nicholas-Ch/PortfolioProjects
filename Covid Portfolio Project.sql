
ALTER PROCEDURE [dbo].[PORTFOLIO] AS 


SELECT 
* FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..Covid_Vaccinations$
--ORDER BY 3,4

-- SELECT DATA that we are goign to be using...

SELECT  location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths$
ORDER BY 1,2


-- Looking at Total cases VS Total deaths
-- Shows likelihood of dying if have covid in your country
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_Deaths$
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total cases VS total Deaths 
--show the percentage of poplucation got covid
SELECT  location, date, total_cases, population, (total_cases/population)*100 AS percentage_population_infected
FROM PortfolioProject..Covid_Deaths$
WHERE location like '%australia%'
ORDER BY 1,2

--Looking at country with highest Covid rate compared to population
SELECT  location,population,  MAX(total_cases) AS Higest_Infection_Count,  MAX((total_cases/population))*100 AS  percentage_population_infected
FROM PortfolioProject..Covid_Deaths$
--WHERE location like '%australia%'
GROUP BY location, population
ORDER BY percentage_population_infected desc



-- SHowing countries with Higest Death Count per population 
SELECT  location, MAX(cast(total_deaths as int))  Total_death_Count
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY location
ORDER BY Total_death_Count desc



-- Breaking down by continent 

SELECT  location, MAX(cast(total_deaths as int))  Total_death_Count
FROM PortfolioProject..Covid_Deaths$
WHERE continent is  null
GROUP BY location
ORDER BY Total_death_Count desc


-- showing the continents with he highest death counts 
SELECT  continent, MAX(cast(total_deaths as int))  Total_death_Count
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_Count desc



-- Global numbers 
SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int ))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_Deaths$
-- WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2




--total population vs vaccination 
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float, vac.new_vaccinations   )) OVER (Partition by dea.Location Order BY dea.location, 
	dea.date) as rolling_people_Vaccinated
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_Vaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent is not null
	--and vac.location like '%australia%'
	order by 2,3 desc




--USE CTE 
With PopvsVac 

(location,Continent,  date, population,new_vaccinations, rolling_people_Vaccinated)
	as (
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order BY dea.location,  dea.Date) as rolling_people_Vaccinated
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_Vaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent is not null
	--and vac.location like '%australia%'
	-- order by 2,3 

	)

	SELECT *, (rolling_people_Vaccinated/ population)*100 
	FROM PopvsVac





 --TEMP table 
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
Date datetime,
population numeric, 
New_vaccinations numeric,
rolling_people_Vaccinated numeric 
) 


Insert Into #PercentPopulationVaccinated
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float, vac.new_vaccinations   )) OVER (Partition by dea.Location Order BY dea.location, 
	dea.date) as rolling_people_Vaccinated
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_Vaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--	WHERE dea.continent is not null
	--and vac.location like '%australia%'
	--order by 2,3 desc


	SELECT *, (rolling_people_Vaccinated/ population)*100 
	FROM #PercentPopulationVaccinated

-- creating view to store data for later visualzations 
	Create View PercentPopulationVaccinated  as 
	SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float, vac.new_vaccinations   )) OVER (Partition by dea.Location Order BY dea.location, 
	dea.date) as rolling_people_Vaccinated
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_Vaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3 desc 


	SELECT * FROM PercentPopulationVaccinated 