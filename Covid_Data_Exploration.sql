/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--Select the data that we're goign to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_Portfolio_Project..coviddeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM SQL_Portfolio_Project..coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
 
 SELECT location, date, population, total_cases, (total_cases/population) AS CasesPercentage
 FROM SQL_Portfolio_Project..coviddeaths
 --WHERE location LIKe '%states%'
 ORDER BY 1,2


 -- LET's BREAK THINGS DOWN BY CONTINENT
 SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
 FROM SQL_Portfolio_Project..coviddeaths
 -- WHERE location like '%states'
 WHERE continent is not null
 GROUP BY continent
 ORDER BY TotalDeathCount desc


 --Showing continents with the hghest death count per population
 SELECT continent, MAX(cast(Total_deaths as int)) AS HighestDeathCount
 FROM SQL_Portfolio_Project..coviddeaths
 -- WHERE location like '%states'
 WHERE continent is not null
 GROUP BY continent
 ORDER BY HighestDeathCount desc


 --GLOBAL NUMBERS
 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM SQL_Portfolio_Project..coviddeaths
 -- WHERE location like '%states'
 WHERE continent is not null
 ORDER BY 1,2


 --New death percentage per new cases

  SELECT  date, SUM(new_cases) AS total_cases , SUM(cast(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) * 100 AS DeathPercentage
 FROM SQL_Portfolio_Project..coviddeaths
 -- WHERE location like '%states'
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2



 -- USE CTE

With Popvsvac (Continent,Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
-- LOOKING at Total Population vs Vaccination
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinate
 FROM SQL_Portfolio_Project..coviddeaths dea
 JOIN SQL_Portfolio_Project..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 1,2,3
	)
SELECT *, (RollingPeopleVaccinated/ Population) * 100
FROM Popvsvac



-- TEMP TABLE
DROP Table if exists  #PercenPopulationVaccinated
Create Table #PercenPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric) 

INSERT INTO #PercenPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinate
 FROM SQL_Portfolio_Project..coviddeaths dea
 JOIN SQL_Portfolio_Project..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/ Population) * 100
FROM #PercenPopulationVaccinated



-- Creating View to store data for later visualizations
USE [SQL_Portfolio_Project]
GO
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinate
 FROM SQL_Portfolio_Project..coviddeaths dea
 JOIN SQL_Portfolio_Project..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3








