SELECT 
    * 
FROM 
    covid_vaccination
ORDER BY
 3, 4;
 
SELECT 
    * 
FROM 
    covid_deaths
WHERE 
    continent IS NOT NULL
ORDER BY
 3, 4;

SELECT 
    LOCATION, date, total_cases, new_cases, total_deaths, population 
FROM 
    covid_deaths
ORDER BY
 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of contracting/dying if you get caught by covid in Pakistan

SELECT 
    LOCATION, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS "death_percentage"
FROM 
    covid_deaths
WHERE 
    LOCATION LIKE 'Pakistan'
ORDER BY
 1, 2;
 
 -- Total cases vs Population in %

SELECT 
    LOCATION, date, population, total_cases, (total_cases / population) * 100 AS "Percentage_cases"
FROM 
    covid_deaths
WHERE 
    LOCATION LIKE 'Pakistan'
ORDER BY
 1, 2;
 
 
-- Lookingat countires with highest infection rate compare to population

SELECT 
    LOCATION, population, max(total_cases) AS "TotalDeathCount"
FROM 
    covid_deaths
-- where 
--     location like 'Pakistan'
GROUP BY
    LOCATION, population
ORDER BY 
    "PercentPopulationInfected" DESC;

    
--Showing Countries with Higest Death Count per Population
SELECT 
    LOCATION, max(total_deaths) AS "TotalDeathCount"
FROM 
    covid_deaths
-- where 
--     location like 'Pakistan'
WHERE 
    continent IS NOT NULL
GROUP BY
    LOCATION
ORDER BY 
    "TotalDeathCount" DESC;
  
-- By Continent 
SELECT 
    LOCATION, max(total_deaths) AS "TotalDeathCount"
FROM 
    covid_deaths
-- where 
--     location like 'Pakistan'
WHERE 
    continent IS NULL
GROUP BY
    LOCATION
ORDER BY 
    "TotalDeathCount" DESC;

----
SELECT 
    continent, max(total_deaths) AS "TotalDeathCount"
FROM 
    covid_deaths
-- where 
--     location like 'Pakistan'
WHERE 
    continent IS NOT NULL
GROUP BY
    continent
ORDER BY 
    "TotalDeathCount" DESC;
 

-- Global Numbers

SELECT 
    date, sum(new_cases) AS "TotalNewCases" , sum(new_deaths) AS "TotalNewCases", (sum(new_deaths) / sum(new_cases) * 100) AS "DeathPercentage" --, total_deaths, (total_deaths / total_cases) * 100 as "death_percentage"
FROM 
    covid_deaths
WHERE 
--     location like 'Pakistan' and
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
 1, 2;

SELECT 
    sum(new_cases) AS "TotalNewCasesWorldWide" , sum(new_deaths) AS "TotalNewDeathsWorldWide", (sum(new_deaths) / sum(new_cases) * 100) AS "DeathPercentage" --, total_deaths, (total_deaths / total_cases) * 100 as "death_percentage"
FROM 
    covid_deaths
WHERE 
--     location like 'Pakistan' and
    continent IS NOT NULL
ORDER BY
 1, 2; 

-- Looking at Total Population vs Vaccinations
SELECT 
    dea.continent, "dea"."location", dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations AS INTEGER)) OVER (PARTITION BY "dea"."location" ORDER BY "dea"."location", dea.date) AS "RollingPeopleVaccinated"
FROM covid_deaths dea
JOIN
    covid_vaccination vac 
ON 
    "dea"."location" = "vac"."location" AND 
    dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2, 3;

-- USE CTE
WITH PopvsVac AS 
(    
SELECT 
    dea.continent, "dea"."location", dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations AS INTEGER)) OVER (PARTITION BY "dea"."location" ORDER BY "dea"."location", dea.date) AS "RollingPeopleVaccinated"
FROM covid_deaths dea
JOIN
    covid_vaccination vac 
ON 
    "dea"."location" = "vac"."location" AND 
    dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
-- order BY
--     2, 3
) 
SELECT *, CAST(("RollingPeopleVaccinated" / population ) AS FLOAT) * 100
FROM PopvsVac
  

-- Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
"Continent" VARCHAR(255),
"Location" VARCHAR(255),
"Date" date,
"Population" NUMERIC,
"New_Vaccinations" NUMERIC,
"RollingPeopleVaccinated" NUMERIC
);

INSERT INTO PercentPopulationVaccinated(
SELECT 
    dea.continent, "dea"."location", dea.date, dea.population, CAST(vac.new_vaccinations AS NUMERIC), sum(CAST(vac.new_vaccinations AS INTEGER)) OVER (PARTITION BY "dea"."location" ORDER BY "dea"."location", dea.date) AS "RollingPeopleVaccinated"
FROM covid_deaths dea
JOIN
    covid_vaccination vac 
ON 
    "dea"."location" = "vac"."location" AND 
    dea.date = vac.date
-- WHERE
--     dea.continent is not null
-- order BY
--     2, 3
);
SELECT *, CAST(("RollingPeopleVaccinated" / Pop ) AS FLOAT) * 100
FROM PercentPopulationVaccinated

-- Creating view to store data for later visualization

CREATE VIEW Percent_Population_Vaccinated AS 
   SELECT 
    dea.continent, "dea"."location", dea.date, dea.population, CAST(vac.new_vaccinations AS NUMERIC), sum(CAST(vac.new_vaccinations AS INTEGER)) OVER (PARTITION BY "dea"."location" ORDER BY "dea"."location", dea.date) AS "RollingPeopleVaccinated"
FROM covid_deaths dea
JOIN
    covid_vaccination vac 
ON 
    "dea"."location" = "vac"."location" AND 
    dea.date = vac.date
-- WHERE
--     dea.continent is not null
-- order BY
--     2, 3

SELECT
    *
FROM Percent_Population_Vaccinated
