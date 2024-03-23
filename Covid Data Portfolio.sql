
SELECT*
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is not null
ORDER by 3,4 

--Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM [PortfolioProject ]..CovidDeaths
ORDER by 1,2 

-- Looking at Total Cases vs Total Deaths 
-- If you contract covid in your country, shows liklihood of dying 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM [PortfolioProject ]..CovidDeaths
WHERE [location] like '%states%'
ORDER by 1,2 

--Looking at Total Cases vs Population 
-- Shows percentage of population got covid 

SELECT Location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage 
FROM [PortfolioProject ]..CovidDeaths
--WHERE [location] like '%states%'
ORDER by 1,2 

--What countries have the highest infections rates compared to the population? 

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths/population)*100 as PercentOfPopulationInfected
FROM [PortfolioProject ]..CovidDeaths
--WHERE [location] like '%states%'
Group by [location], population
ORDER by PercentOfPopulationInfected DESC

--Shows countires with the highest deathcount per population 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [PortfolioProject ]..CovidDeaths
WHERE [continent] is not null
Group by [location]
ORDER by TotalDeathCount DESC

--CONTINENT BREAKDOWN--
--Contients with the highest deathcount

SELECT [continent],MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [PortfolioProject ]..CovidDeaths
WHERE [continent] is NOT null
Group by [continent]
ORDER by TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE [continent] is not null
GROUP by date

--Shows around the world a death told of a little over 2%

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE [continent] is not null
--GROUP by date
ORDER by 1,2 

--Moving along to Covid Vaccinations 
--Looking at total popualtions vs Vaccinations 
SELECT*
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date

    --Total Population Vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3

-- USE CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT*
From PopvsVac

--More Research with CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE 

DROP Table if exists #PercentOfPopulationVaccinated 
Create Table #PercentOfPopulationVaccinated 
(
Continent NVARCHAR (255),
LOCATION NVARCHAR (255), 
date datetime,
population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentOfPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
From #PercentOfPopulationVaccinated 

--Creating View to Restore Data for Visualizations 

Create View #PercentOfPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations$ vac
    On dea.location = vac.LOCATION
    and dea.date = vac.date
WHERE dea.continent is not null 
