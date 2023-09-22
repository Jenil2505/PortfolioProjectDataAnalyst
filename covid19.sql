Select * 
From Portfolio..CovidDeaths
order by 3,4;

Select * 
From Portfolio..CovidVac
order by 3,4;

-- Total cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where location like '%india%' 
order by 1,2;

--Total cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as Percentpopulationinfected
From Portfolio..CovidDeaths
where location like '%india%' 
order by 1,2;


-- Countries with Highest Infection Rate compared to Population
Select location,population, MAX(total_cases) as Highestcases,  MAX((total_cases/population))*100 as Percentpopulationinfected
From Portfolio..CovidDeaths
group by location, population
order by Percentpopulationinfected desc;

-- Countries with Highest Death Count per Population
Select location,population, MAX(cast(total_deaths as int)) as totaldeaths
From Portfolio..CovidDeaths
where continent IS NOT NULL
group by location, population
order by totaldeaths desc;

--contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null AND dea.location like '%india%'
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USING CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as rollingpercent
From PopvsVac


-- Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated;