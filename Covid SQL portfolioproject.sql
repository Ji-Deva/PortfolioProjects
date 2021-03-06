select *
from SQLportfolioproject..covid_deaths
order by 3,4

--select * 
--from SQLportfolioproject..covid_vaccinations
--order by 3,4



select location, date, total_cases,new_cases,total_deaths,population
from SQLportfolioproject..covid_deaths
order by 1,2

--Looking at the total cases vs total deaths
-- Shows death percentage if you get covid
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from SQLportfolioproject..covid_deaths
where location like 'india'
order by 1,2

-- total cases vs population
--shows percentage of population that got covid
select location, date, total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from SQLportfolioproject..covid_deaths
where location like 'india'
order by 1,2

-- countries with highest infection rates compared to population
select location, population,date, max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as PercentPopulationInfected
from SQLportfolioproject..covid_deaths
--where location like 'india'
group by location, population,date
order by PercentPopulationInfected desc

-- countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from SQLportfolioproject..covid_deaths
--where location like 'india'
where continent is not null
group by location
order by TotalDeathCount desc

-- death count by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from SQLportfolioproject..covid_deaths
--where location like 'india'
where continent is null and location not like '%income%' and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

-- Global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from SQLportfolioproject..covid_deaths
where continent is not null
--group by date
order by 1,2

--Vaccinations
--total population vs vaccinations
-- rolling count of vaccinations
--use CTE

with PopvsVacc (continent,locatuion,date, population, new_vaccinations, rolling_vacc_count)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
dea.date) as rolling_vacc_count
--, (rolling_vacc_count/population)*100
from SQLportfolioproject..covid_deaths as dea
join SQLportfolioproject..covid_vaccinations as vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)

select *, (rolling_vacc_count/population)*100 as rolling_vacc_percentage
from PopvsVacc


--use TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vacc_count numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
dea.date) as rolling_vacc_count
--, (rolling_vacc_count/population)*100
from SQLportfolioproject..covid_deaths as dea
join SQLportfolioproject..covid_vaccinations as vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3

select *, (rolling_vacc_count/population)*100 as rolling_vacc_percentage
from #PercentPopulationVaccinated


-- creating view to store data

create view RollingPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
dea.date) as rolling_vacc_count
--, (rolling_vacc_count/population)*100
from SQLportfolioproject..covid_deaths as dea
join SQLportfolioproject..covid_vaccinations as vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select *
from RollingPopulationVaccinated








