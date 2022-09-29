Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select * 
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in the US.
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%states%'
Where continent is not null
order by 1,2

--Looking at Total Cases vs. Population.
Select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Populations
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population versus Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,  
SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as cumulative_vaccination, 
sum(cast(dea.new_deaths as BIGINT)) OVER (partition by dea.Location Order by dea.location, dea.date) as cumulative_deaths
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE

With PopvsVac (continent, location, date, population, cumulative_vaccination, cumulative_deaths)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,  
SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as cumulative_vaccination, 
sum(cast(dea.new_deaths as BIGINT)) OVER (partition by dea.Location Order by dea.location, dea.date) as cumulative_deaths
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (cumulative_vaccination)/population*100 percentage_vaccinated
From PopvsVac
order by location, date

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccination numeric,
cumulative_vaccination numeric
)

Insert into #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,  
SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as cumulative_vaccination, 
sum(cast(dea.new_deaths as BIGINT)) OVER (partition by dea.Location Order by dea.location, dea.date) as cumulative_deaths
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (cumulative_vaccination)/population*100 percentage_vaccinated
From #percentPopulationVaccinated
order by location, date

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,  
SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as cumulative_vaccination, 
sum(cast(dea.new_deaths as BIGINT)) OVER (partition by dea.Location Order by dea.location, dea.date) as cumulative_deaths
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated
