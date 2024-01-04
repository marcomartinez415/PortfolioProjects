SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
ORDER By 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER By 3,4

-- Script to identify the properties of the columns 

--EXEC sp_help 'dbo.coviddeaths'--

-- Script to alter the data type in the column - It was an issue when uploading table 
-- which caused an error when using mathamatical function 

--ALTER TABLE dbo.CovidDeaths--
--ALTER COLUMN total_cases float--

-- Select Data that we are going to be using (CAN Remove comment)

SELECT LOCATION, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shoes likelihood of dying if you contract covid in your county 

SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Total CCases vs Population 
-- Shows what percentatge of pouplation got Covid

SELECT location, date, Population, total_cases, (total_cases/Population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compaired to population 

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/Population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected desc

-- Showing Counries with HIghest Death Count per Population 

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's break things down by CONTINENT
--NEW WAY--Skipped
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break things down by CONTINENT
--OLD WAY-- Will use for the project
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count per population 

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF((SUM(new_cases)),0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.Location, DEA.date, DEA.Population, VAC.new_vaccinations
,SUM(CONVERT(float,VAC.new_vaccinations)) OVER (Partition by  DEA.Location ORDER by DEA.Location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.Location = VAC.location
	AND DEA.date = vac.date
WHERE DEA.continent is not null 
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100 AS PercentageofPopulationVaccinated
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.Location, DEA.date, DEA.Population, VAC.new_vaccinations
,SUM(CONVERT(float,VAC.new_vaccinations)) OVER (Partition by  DEA.Location ORDER by DEA.Location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.Location = VAC.location
	AND DEA.date = vac.date
WHERE DEA.continent is not null 
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100 AS PercentageofPopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.Location, DEA.date, DEA.Population, VAC.new_vaccinations
,SUM(CONVERT(float,VAC.new_vaccinations)) OVER (Partition by  DEA.Location ORDER by DEA.Location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON DEA.Location = VAC.location
	AND DEA.date = vac.date
WHERE DEA.continent is not null 
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
