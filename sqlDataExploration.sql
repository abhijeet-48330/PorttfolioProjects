--select * from CovidDeaths
--order by 3,4

--select * from CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases , total_deaths, population
from CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--likelihood of dying of covid in specific countries
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from CovidDeaths
where location='India'
order by 1,2


--looking at total cases vs population
--percentage of population that got covid
select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
from CovidDeaths
where location = 'India'


--countries highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 
as CovidPercentage
from CovidDeaths
--where location='India'
where continent is not null
group by location,population
order by CovidPercentage desc


-- countries with highest death count per population

select continent,MAX(cast(total_deaths as int)) as totalDeaths
from CovidDeaths
where continent is not null 
group by continent
order by totalDeaths desc


--Global numbers

select SUM(new_cases) as newCases, SUM(cast(total_deaths as int)) as totalDeaths
from CovidDeaths
where continent is not null
group by date
order by 1,2

--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on   dea.location=vac.location
and  dea.date=vac.date
where dea.continent is not null
order by 2,3


--use CTE

with POPvsVAC(continent,location,date,population,new_vaccinations,rollingPeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on   dea.location=vac.location
and  dea.date=vac.date
where dea.continent is not null

)
select *,(rollingPeoplevaccinated/population)*100
from POPvsVAC

--creating view to store data for future vis

Create view PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on   dea.location=vac.location
and  dea.date=vac.date
where dea.continent is not null

