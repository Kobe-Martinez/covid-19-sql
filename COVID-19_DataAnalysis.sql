--Select *
--From Portfolio..CovidDeaths
--Where continent is not null
--order by 3,4

--Select *
--From Portfolio..CovidVaccinations
--Where continent is not null
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you get covid in X country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking @ Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


-- Looking at countries with highes infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing the Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S BREAK IT DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2


-- Gives Total cases, deaths, and percentage
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2



-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated


-- Creating View to Store data for later visualization

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3



Select *
From PercentagePopulationVaccinated
