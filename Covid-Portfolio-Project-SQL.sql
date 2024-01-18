Select location, date, total_cases, new_cases, total_deaths
From public."CovidDeaths"
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of death if a person contracts covid in Africa
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From public."CovidDeaths"
Where location = 'Africa' and continent is null
Order By 1,2

-- Comparing numbers of Population to Total Cases
-- Shows the percentage of people who contracted covid

Select location, date, population, total_cases, (total_cases/population)*100 as infectionpercentage
From public."CovidDeaths"
Where continent is not null
Order By 1,2

-- Showing the countries with the highest infection rates compared to population

Select location, population,date,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as InfectionPercentage
From public."CovidDeaths"
Group By location, population,date
Order By InfectionPercentage desc

-- Showing countries with the highest total deaths

Select location, max(total_deaths) as total_deaths 
From public."CovidDeaths"
Where continent is not null
Group By location 
Order By total_deaths desc


-- Global Numbers - Death Percentage 

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From public."CovidDeaths"
Where continent is not null 
--group by date 
Order By DeathPercentage desc

-- Global Numbers - TotalDeathCount

Select location, max(total_deaths) as TotalDeathCount
From public."CovidDeaths"
Where continent is null
and location not in ('World','European Union', 'International') -- taken out because they are not included in queries above
Group By location
Order By TotalDeathCount desc

-- Looking at total population vs vaccinations using a cte

with PopVsVac (continent, location, population, date, new_vaccinations, rollingsum_vac)
as(
	Select dea.continent, dea.location, population, dea.date, vac.new_vaccinations, 
		sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rollingsum_vac
	From public."CovidDeaths" dea
	Join public."CovidVaccinations " vac
		on dea.date = vac.date
		and dea.location = vac.location
	Where dea.continent is not null
	--order by 2, 3
		)


	Select *,(rollingsum_vac/population) * 100 as VaccinationPercentage
	From PopvsVac

-- Looking at total population vs vaccinations using a temp table

DROP Table if exists PopulationPercentageVaccinated
Create Table PopulationPercentageVaccinated
(
continent text,
location text,
population text,
date date,
new_vaccinations numeric,
rollingsum_vac numeric )

Insert into PopulationPercentageVaccinated 

select dea.continent, dea.location, population, dea.date, vac.new_vaccinations, 
		sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rollingsum_vac
	From public."CovidDeaths" dea
	Join public."CovidVaccinations " vac
		on dea.date = vac.date
		and dea.location = vac.location 
	Where dea.continent is not null
	--order by 2, 3
	
	Select *,(rollingsum_vac/population) * 100 as VaccinationPercentage
	From PopulationPercentageVaccinated


-- Creating views to visualize in tablue
-- View #1
create view PopVsVac as
	with PopVsVac (continent, location, population, date, new_vaccinations, rollingsum_vac)
	as(
	select dea.continent, dea.location, population, dea.date, vac.new_vaccinations, 
		sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as rollingsum_vac
	from public."CovidDeaths" dea
	join public."CovidVaccinations " vac
		on dea.date = vac.date
		and dea.location = vac.location
	where dea.continent is not null
	--order by 2, 3
		)


	select *,(rollingsum_vac/population) * 100 as VaccinationPercentage
	from PopvsVac

-- View #2

create view Africa_Deaths as
	select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	from public."CovidDeaths"
	where location = 'Africa' and continent is null
	order by 1,2
	
-- view #3 
create view Continent_Deaths as
	select continent, max(total_deaths) as total_deaths 
	from public."CovidDeaths"
	where continent is not null 
	group by continent 
	order by total_deaths desc
	
-- View #4

create view Country_Deaths as
	select location, max(total_deaths) as total_deaths 
	from public."CovidDeaths"
	where continent is not null
	group by location 
	order by total_deaths desc

