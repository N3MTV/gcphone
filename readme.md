## Téléphone pour FiveM

### Appel event
```LUA
--==================================================================
-- Police
--==================================================================
-- Police [Signaler un vol]
TriggerEvent('police:callPolice', {type: 'Vole'})
-- Police [Signaler une agression]
TriggerEvent('police:callPolice', {type: 'Aggression'})
-- Police [Autre]
TriggerEvent('police:callPoliceCustom')
-- Police [Annuler l'appel en cour]
TriggerEvent('police:cancelCall')


--==================================================================
-- Ambulance
--==================================================================
-- Ambulance [Appel Coma]
TriggerEvent('ambulancier:callAmbulancier', {type: 'Vole'})
-- Ambulance [Appel ambulance]
TriggerEvent('ambulancier:callAmbulancier', {type: 'Aggression'})
-- Ambulance [Respawn]
TriggerEvent('ambulancier:selfRespawn')
-- Ambulance [Annuler l'appel en cour]
TriggerEvent('ambulancier:cancelCall')


--==================================================================
-- Taxi
--==================================================================
-- Taxi [1 personne]
TriggerEvent('taxi:callService', {type: '1 personne'})
-- Taxi [2 personnes]
TriggerEvent('taxi:callService', {type: '2 personnes'})
-- Taxi [3 personnes]
TriggerEvent('taxi:callService', {type: '3 personnes'})
-- Taxi [Annuler l'appel en cour]
TriggerEvent('taxi:cancelCall')


--==================================================================
-- Mecano
--==================================================================
-- Mecano [Moto]
TriggerEvent('mecano:callMecano', {type: 'Moto'})
-- Mecano [Voiture]
TriggerEvent('mecano:callMecano', {type: 'Voiture'})
-- Mecano [Camionnette]
TriggerEvent('mecano:callMecano', {type: 'Camionnette'})
-- Mecano [Camion]
TriggerEvent('mecano:callMecano', {type: 'Camion'})
-- Mecano [Annuler l'appel en cour]
TriggerEvent('mecano:cancelCall')

--==================================================================
-- Urgence
--==================================================================
-- Ambulance
TriggerEvent('ambulancier:callAmbulancier', {type: 'Coma'})
-- Police REMOVE
-- TriggerEvent('police:callPolice', {type: 'Homme à terre'})
-- Hopital
TriggerEvent('ambulancier:selfRespawn')

```