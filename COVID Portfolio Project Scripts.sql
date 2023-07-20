SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select the data that we are going to be using.

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country.

SELECT Location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases) )*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Kenya'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Kenya'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%kenya%'
GROUP BY location, population
ORDER BY PercentPopulationInfected Desc

--Showing Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%kenya%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount Desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%kenya%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc

--Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Kenya'
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2


SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Kenya'
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2


--Looking at total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(DECIMAL(18,2), vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(DECIMAL(18,2), vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE
Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(DECIMAL(18,2), vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later Visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(DECIMAL(18,2), vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated
