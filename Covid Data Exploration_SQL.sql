SELECT *
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 3,4

-- Select *
-- From PortfolioProject..CovidVaccinations
-- order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2

-- Looking at Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2

SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
Where LOCATION like '%states%'
and continent is not NULL
ORDER BY
    Location,
    date;

    -- Looking at Total Cases Vs Population
    -- Show what percentage of population got infected with covid-19

    SELECT
    Location,
    date,
    total_cases,
    Population,
    (CAST(total_cases AS float) / CAST(Population AS float))*100 AS Infectionpercentage
FROM PortfolioProject..CovidDeaths
Where LOCATION like '%states%'
AND continent is not NULL
ORDER BY Location, date;


--Looking at Countries with highest infection rates compared to Population


SELECT
    Location, Population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- Where LOCATION like '%states%'
Where continent is not NULL
GROUP BY LOCATION, Population
ORDER BY PercentPopulationInfected DESC

  
-- Showing Countries with Highest Death Count per Population

SELECT
    Location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where LOCATION like '%states%'
Where continent is not NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC


SELECT
    Location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where LOCATION like '%states%'
Where continent is NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


--Lets break things down by continent

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where LOCATION like '%states%'
Where continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Breaking it to Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%states%'
WHERE continent is not NULL
--Group by DATE
ORDER BY 1,2 


-- Looking at Total Population Vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) as Rollingpeoplevaccinated
--    , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) as Rollingpeoplevaccinated
--    , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (Rollingpeoplevaccinated/Population)*100
From PopvsVac



--TEMP TABLE

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated', 'U') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    Location NVARCHAR(255),
    DATE DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    Rollingpeoplevaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date) as Rollingpeoplevaccinated
       --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2, 3;

SELECT *,
       (Rollingpeoplevaccinated / Population) * 100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;



-- Creating View to store data for visualisations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date) as Rollingpeoplevaccinated
       --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3;

SELECT * 
From PercentPopulationVaccinated
