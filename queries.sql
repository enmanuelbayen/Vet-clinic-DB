/*Queries that provide answers to the questions from all projects.*/

SELECT * FROM animals WHERE name LIKE '%mon';
SELECT name FROM animals WHERE EXTRACT(year FROM date_of_birth) BETWEEN 2016 AND 2019;
SELECT * FROM animals WHERE neutered = true AND escape_attempts < 3;
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;
SELECT * FROM animals WHERE neutered = true;
SELECT * FROM animals WHERE name != 'Gabumon';
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

-- transaction
BEGIN;
UPDATE animals
SET species='unspecified'
WHERE species IS NULL;
SELECT * FROM animals;
ROLLBACK;
SELECT * FROM animals;

BEGIN;
UPDATE animals
SET species = 'digimon'
WHERE name LIKE '%mon';
UPDATE animals
SET species = 'pokemon'
WHERE species IS NULL;
COMMIT;
SELECT * FROM animals;

-- delete

BEGIN;
DELETE FROM animals;
ROLLBACK;
SELECT * FROM animals;

BEGIN;
SAVEPOINT SP1;
DELETE FROM animals WHERE date_of_birth > '2022/01/01';
SAVEPOINT SP2;
UPDATE animals SET weight_kg= weight_kg*-1;
SAVEPOINT SP3;
ROLLBACK TO SP2;
UPDATE animals SET weight_kg= weight_kg*-1 WHERE weight_kg < 0;
COMMIT;
SELECT * FROM animals;

-- group by queries

SELECT COUNT(*) AS animals_count FROM animals;
SELECT COUNT(*) AS escape_attempts_count FROM animals 
WHERE escape_attempts = 0; 
SELECT AVG(weight_kg) AS avg_weight FROM animals;
SELECT neutered, AVG(escape_attempts) FROM animals
GROUP BY neutered ORDER BY neutered DESC;
SELECT species, MIN(weight_kg) AS min_weight, MAX(weight_kg) AS max_weight
FROM animals
GROUP BY species;
SELECT species, AVG(escape_attempts) AS avg_escape_attempts
FROM animals
WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'
GROUP BY species;

--  --JOIN QUERY
-- What animals belong to Melody Pond?
SELECT a.name
FROM animals a
JOIN owners o ON a.owner_id = o.id
WHERE o.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT a.name
FROM animals a
JOIN species s ON a.species_id = s.id
WHERE s.name = 'Pokemon';

-- List all owners and their animals, including those who don't own any animal.
SELECT o.full_name, a.name
FROM owners o
LEFT JOIN animals a ON o.id = a.owner_id;

-- How many animals are there per species?
SELECT s.name, COUNT(a.id) AS animal_count
FROM species s
LEFT JOIN animals a ON s.id = a.species_id
GROUP BY s.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT a.name
FROM animals a
JOIN species s ON a.species_id = s.id
JOIN owners o ON a.owner_id = o.id
WHERE s.name = 'Digimon' AND o.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT a.name
FROM animals a
JOIN owners o ON a.owner_id = o.id
WHERE o.full_name = 'Dean Winchester' AND a.escape_attempts = 0;

-- Who owns the most animals?
SELECT o.full_name, COUNT(a.id) AS animal_count
FROM owners o
JOIN animals a ON o.id = a.owner_id
GROUP BY o.full_name
ORDER BY animal_count DESC;

-- Part 3 queries 

--Who was the last animal seen by William Tatcher?
SELECT a.name
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON vt.id = v.vet_id
WHERE vt.name = 'William Tatcher'
ORDER BY v.visit_date DESC
FETCH FIRST 1 ROW ONLY;

-- How many different animals did Stephanie Mendez see?
SELECT COUNT(DISTINCT v.animal_id)
FROM visits v
JOIN vets vt ON vt.id = v.vet_id
WHERE vt.name = 'Stephanie Mendez';

-- List all vets and their specialties, including vets with no specialties.
SELECT vt.name, COALESCE(string_agg(s.name, ', '), 'No Specialties') AS specialties
FROM vets vt
LEFT JOIN specializations sp ON sp.vet_id = vt.id
LEFT JOIN species s ON s.id = sp.specie_id
GROUP BY vt.name;

-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT a.name
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON vt.id = v.vet_id
WHERE vt.name = 'Stephanie Mendez'
  AND v.visit_date >= '2020-04-01'
  AND v.visit_date <= '2020-08-30';

-- What animal has the most visits to vets?
SELECT a.name, COUNT(v.animal_id) AS visit_count
FROM animals a
JOIN visits v ON a.id = v.animal_id
GROUP BY a.name
ORDER BY visit_count DESC
FETCH FIRST 1 ROW ONLY;

-- Who was Maisy Smith's first visit?
SELECT a.name
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON vt.id = v.vet_id
WHERE vt.name = 'Maisy Smith'
ORDER BY v.visit_date ASC
FETCH FIRST 1 ROW ONLY;

-- Details for the most recent visit: animal information, vet information, and date of visit.
SELECT a.name AS animal_name, vt.name AS vet_name, v.visit_date
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON vt.id = v.vet_id
ORDER BY v.visit_date DESC
FETCH FIRST 1 ROW ONLY;

--How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*)
FROM visits v
JOIN animals a ON a.id = v.animal_id
JOIN vets vt ON vt.id = v.vet_id
LEFT JOIN specializations sp ON sp.vet_id = vt.id AND sp.specie_id = a.species_id
WHERE sp.specie_id IS NULL;

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT species.name
FROM visits
JOIN vets ON visits.vet_id = vets.id
JOIN animals ON animals.id = visits.animal_id
JOIN species ON animals.species_id = species.id
WHERE vets.name = 'Maisy Smith'
GROUP BY species.name
ORDER BY COUNT(species.name) DESC
FETCH FIRST 1 ROW ONLY;