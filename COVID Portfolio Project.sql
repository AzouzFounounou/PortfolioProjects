SELECT * 
	FROM PortflioProject..Covid_Deaths
ORDER BY 3,4


SELECT * 
FROM PortflioProject..Covid_Vaccination
where continent is not null
ORDER BY 3,4

--SELECT Data that we are going to be using 

select Location, date, total_cases, new_cases, total_deaths, population
FROM PortflioProject..Covid_Deaths
ORDER BY 1,2

	--Looking at total Cases Vs Total Deaths 
	--*100 as DeathPercentage
	--, (total_deaths/ total_cases)


FROM PortflioProject..Covid_Deaths
EXEC sp_help 'PortflioProject..Covid_Deaths'
--ORDER BY 1,2


--Looking at total Cases Vs Total Deaths
ALTER TABLE PortflioProject..Covid_Deaths ALTER COLUMN total_cases Float
ALTER TABLE PortflioProject..Covid_Deaths ALTER COLUMN total_deaths Float

select Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage 
from  PortflioProject..Covid_Deaths
--where location like '%states%'
where continent is not null
ORDER BY 1,2



--Looking at Total Cases Vs Population
--shows what percentage  of population got Covid

select Location, date,population, total_cases, (total_cases/ population)*100 as PercentagePopulationInfected 
from  PortflioProject..Covid_Deaths
where location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population  

select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentagePopulationInfected 
from  PortflioProject..Covid_Deaths
--where location like '%states%'
Group by location, population
ORDER BY PercentagePopulationInfected desc



--Showing countries with Highest Death Count per Population

select Location, MAX(total_deaths) as TotalDeathCount
from  PortflioProject..Covid_Deaths
--where location like '%states%'
where continent is not null
Group by location
ORDER BY TotalDeathCount desc


--Let's break things down by continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from  PortflioProject..Covid_Deaths
--where location like '%states%'
where continent is null and Location not like '%income%'
Group by location
ORDER BY TotalDeathCount desc

--Global Numbers

select SUM(cast(new_cases as float)) as TC, SUM(cast (new_deaths as int)) as TD, (SUM( cast (new_deaths as int) )/SUM(cast(new_cases as float)))*100 as DeathPercentage 
from  PortflioProject..Covid_Deaths
--where location like '%states%'
where continent is not null --and new_cases  != 0  and new_deaths != 0 
--Group by date
Order by 1,2



-- Looking Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (float ,vac.new_vaccinations)) OVER  (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortflioProject..Covid_Deaths dea
join PortflioProject..Covid_Vaccination vac
 on dea.location = vac.location
  and dea.date = vac. date
  where dea.continent is not null
  order by 2,3



--Use CTE



with PopVsVac ( Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccination)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (float ,vac.new_vaccinations)) OVER  (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccination
From PortflioProject..Covid_Deaths dea
join PortflioProject..Covid_Vaccination vac
 on dea.location = vac.location
  and dea.date = vac. date
where dea.continent is not null
--order by 2,3
  )

Select * , (RollingPeopleVaccination/population)*100
From PopVsVac
--where location like '%states%' 
order by 2,3




--Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (float ,vac.new_vaccinations)) OVER  (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortflioProject..Covid_Deaths dea
join PortflioProject..Covid_Vaccination vac
 on dea.location = vac.location
  and dea.date = vac. date
where dea.continent is not null


Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
order by 2,3


--Create View to Store data for later Visulizations 
Drop view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (float ,vac.new_vaccinations)) OVER  (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortflioProject..Covid_Deaths dea
join PortflioProject..Covid_Vaccination vac
 on dea.location = vac.location
  and dea.date = vac. date
where dea.continent is not null

select * 
from PercentPopulationVaccinated
order by 2,3