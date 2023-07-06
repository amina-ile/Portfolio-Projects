--SELECT *
--FROM 
--PortfolioProjectCovid..CovidDeaths


SELECT *
FROM
PortfolioProjectCovid..CovidVaccinations
ORDER BY 3,4

-- Select the data we will be focusing on

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM 
PortfolioProjectCovid..CovidDeaths
ORDER BY 1,2

-- Looking at the Death Rate in the Unites States 
-- showing the likelihood of dying from COVID 

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of the US populatioin that has contracted COVID

SELECT location, date, population, total_cases, (cast(total_cases as float)/population)*100 AS InfectionRate
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at the Countries with the Highest Infection Rates

SELECT location,population, MAX(total_cases) AS HigestInfectionCount,
MAX((cast(total_cases as float)/population))*100 AS PercentPopulationInfected
FROM 
PortfolioProjectCovid..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with the highest death count per population

SELECT location,MAX(cast(total_deaths as float)) as TotalDeathCount
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- VIEWS BY CONTINENT

--Showing the Continents with the highest death counts per population
SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

--Global Death Percentage per day

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
and new_cases <> 0
and new_deaths <> 0
GROUP BY date
ORDER BY 1,2

--Global Death Percentage
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
and new_cases <> 0
and new_deaths <> 0
ORDER BY 1,2

SELECT *
FROM
PortfolioProjectCovid..CovidVaccinations
ORDER BY 3,4

--Join CovidDeaths and CovidVaccinations Tables

SELECT *
FROM PortfolioProjectCovid..CovidDeaths dea
	JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Looking at the Rolling count number of the world population that have been vaccinated per location

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCovid..CovidDeaths dea
	JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

-- Sum the number of new vaccinations per location 
--USE CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCovid..CovidDeaths dea
	JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Sum the number of new vaccinations per location
--USE TEMP TABLE

DROP TABLE IF EXISTS
CREATE TABLE #PercentPeopleVaccinated
(
	Continent nvarchar(255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

Insert into #PercentPeopleVaccinated
	SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCovid..CovidDeaths dea
	JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *
FROM 
#PercentPeopleVaccinated


--Creating Views 

CREATE VIEW DeathCount AS
SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM 
PortfolioProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC


CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjectCovid..CovidDeaths dea
	JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *
FROM
PercentPopulationVaccinated