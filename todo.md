# TODO - Projet Savonnerie

- [x] **Compiler le projet** (`ant -f build.xml deploy`)
- [x] **Démarrer WildFly** sur le port 8088 (`.\standalone.bat`)
- [x] **Tester l'accès dans le navigateur** : `http://localhost:8088/socobis`
- [x] **Vérifier la communication avec la base Oracle**
  - [x] Renseigner l'adresse dans `socobis-ejb/src/java/apj.properties` (`localhost:1521:xe`, user `SAVONNERIE0126`)
  - [x] Valider la connexion réussie (`TestOracle` : Succès !)
  - [x] Redéployer l'application dans WildFly avec la nouvelle configuration
- [ ] **Tester l'authentification et l'application sur le navigateur**
