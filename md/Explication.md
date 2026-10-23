# Explication du projet Savonnerie / SOCOBIS

## 1. Vue d’ensemble

Ce dépôt contient le code d’une application web de gestion pour une savonnerie, identifiée dans les scripts et modules sous le nom **SOCOBIS**. Elle couvre une partie importante du cycle d’exploitation : achats et fournisseurs, stocks et magasins, production, ventes, caisse, comptabilité, ressources humaines et rapports.

Le cœur applicatif est une application Java EE historique composée d’un module métier EJB et d’un module web. Oracle est la base de données visée. Le dépôt comprend aussi les pages JSP, des scripts SQL, des outils de construction Ant, un générateur de codes-barres Java et un petit prototype Python Google ADK. Le README racine est encore le modèle standard GitLab ; cette description est donc tirée de l’organisation et du contenu du code.

### Chiffres de l’inventaire du dépôt

Les comptages ci-dessous correspondent aux fichiers trouvés au moment de cette analyse, pas à des mesures de lignes de code ni à une preuve que chaque élément est utilisé en production.

| Élément | Quantité observée |
|---|---:|
| Sources Java dans `socobis-ejb` | 768 |
| Sources Java dans `socobis-war` | 35 |
| Pages JSP dans `socobis-war/web` | 1 242 |
| Scripts SQL dans `bdd` et `bdd-async` | 945 |

## 2. Architecture et parcours d’une requête

```text
Navigateur
   │ pages et formulaires
   ▼
socobis-war/web (JSP, JavaScript, CSS, images)
   │ requêtes HTTP
   ▼
socobis-war/src/java (Servlets, exports, utilitaires web)
   │ appels aux objets métier et bibliothèques partagées
   ▼
socobis-ejb/src/java (modèle métier, calculs et accès aux données)
   │ JDBC / couche utilitaire APJ
   ▼
Oracle
```

Le serveur applicatif Java EE héberge les composants serveur. Les pages JSP affichent les écrans et les Servlets traitent notamment les imports, exports et actions HTTP. Le module EJB contient la majorité du code métier et s’appuie sur des classes utilitaires et des bibliothèques locales, dont `apj-ejb.jar`. Les scripts SQL définissent et font évoluer les objets Oracle utilisés par l’application.

Cette séparation est une lecture de l’arborescence et des scripts de compilation. Les anciennes conventions de code ne forment pas toujours une architecture en couches stricte : certaines fonctionnalités peuvent répartir leur traitement entre pages, Servlets, objets métier et SQL.

## 3. Modules principaux

### `socobis-ejb/` — métier et données

`src/java/` contient plusieurs centaines de classes Java réparties par domaine. Les principaux packages donnent une carte fonctionnelle du système :

| Packages | Responsabilité visible par le nom et les classes |
|---|---|
| `vente`, `venteLubrifiant`, `client`, `proforma`, `facture`, `avoir`, `ristourne` | Ventes, clients, factures, proformas, avoirs et remises commerciales |
| `faturefournisseur`, `achat`, `ordonn(er)paiement`, `paiement`, `cheque`, `encaissement` | Achats, factures fournisseurs et règlements |
| `stock`, `magasin`, `inventaire`, `lot`, `produits`, `equivalenceproduit` | Articles, stocks, inventaires, lots et mouvements entre magasins |
| `production`, `fabrication`, `besoin`, `calculBesoin` | Fabrication, besoins et calculs de production |
| `caisse`, `depense`, `charge`, `budget`, `prevision`, `compta`, `paramCompta` | Trésorerie, dépenses, budgets, prévisions et comptabilité |
| `personnel`, `paie`, `rh`, `declaration` | Personnel, paie et déclarations sociales |
| `machine`, `maintenance`, `entretien`, `carburant`, `transport`, `pompe`, `jauge` | Équipements, maintenance et activités liées au transport/carburant |
| `dashboard`, `tableaudebord`, `rapport`, `analyse`, `stat` | Indicateurs, analyses et états |
| `configuration`, `utilisateurstation`, `user`, `societe`, `siege` | Paramétrage, utilisateurs et organisation |
| `utilitaire`, `utils`, `filemanager`, `fichier`, `uploadbean` | Fonctions techniques partagées, fichiers et téléversements |

Les dossiers `src/ressources/prompts/` contiennent des instructions textuelles classées par usage (requêtes, comptabilité, analyse et génération de pages). Leur présence montre une fonctionnalité d’assistance conversationnelle côté serveur, mais ne suffit pas à établir quels modèles ou services distants sont effectivement configurés.

### `socobis-war/` — application web

- `src/java/servlet/` héberge les contrôleurs HTTP. Les noms incluent des traitements de reporting, de comptabilité, de balances, d’imports CSV/Excel, de fichiers et de chatbot.
- `src/java/station/` contient notamment des fonctions d’export PDF et Excel.
- `src/java/filemanager/` et `src/java/uploadbean/` gèrent des opérations liées aux fichiers.
- `web/` est la racine du contenu web : elle contient les pages JSP, les ressources statiques et la configuration sous `WEB-INF`.
- `web/pages/` regroupe les écrans par sujet (par exemple `vente`, `stock`, `production`, `compta`, `paie`, `personnel`, `achat`, `fournisseur`, `rapport`, `Chatbot`).
- `web/apjplugins/` contient des scripts d’interaction réutilisables : ajout de lignes, champs date, calcul et autocomplétion, notifications et chat.
- `web/assets/`, `web/bootstrap/`, `web/dist/`, `web/chartPlugins/` fournissent les bibliothèques, styles, composants graphiques, images et scripts JavaScript/CSS. On y trouve notamment Bootstrap, jQuery, FullCalendar, Chart.js et AdminLTE.
- `web/report/` contient des ressources d’états ou de rapports ; JasperReports figure parmi les bibliothèques du projet.

Le fichier `web/WEB-INF/web.xml` fixe le descripteur web et l’ordre d’un fragment nommé `apjconfig`. Les mappings et composants web peuvent aussi être déclarés dans les fragments présents sous `WEB-INF/META-INF`.

### `bdd/` et `bdd-async/` — base Oracle

Les deux répertoires contiennent 945 scripts SQL au total.

- `bdd/` contient des scripts fonctionnels et des dossiers datés, notamment autour de la vente et des évolutions de 2026.
- `bdd-async/` organise une partie de l’historique par année, mois et jour. Les noms horodatés et les suffixes décrivent des corrections, ajouts ou lots de travail.
- Les scripts semblent inclure des créations et modifications d’objets, des vues, des données et des opérations de migration. Les noms et dates montrent un historique continu, mais ne constituent pas un registre fiable de version du schéma.

Il faut donc traiter ces fichiers comme des migrations ou correctifs à faire valider individuellement. Le dépôt ne permet pas, à lui seul, de déterminer quels scripts ont été appliqués sur une base donnée ni l’ordre exact requis pour reconstruire un environnement.

### Outils et fichiers à la racine

| Chemin | Rôle |
|---|---|
| `build.xml`, `build-jenkins.xml`, `build-savonnerie.xml`, `build-tomcat.xml` | Scripts Ant de compilation, empaquetage et/ou déploiement avec des paramètres différents |
| `build-file/` | Emplacement attendu par les scripts pour les sorties de construction et les bibliothèques JAR locales |
| `Dockerfile` | Ébauche de conteneur WildFly ; son chemin d’entrée doit correspondre à un artefact réellement produit |
| `codebar-generator/` | Petit programme Java qui lit les ingrédients d’Oracle, produit des codes-barres Code 128 PNG et renseigne le chemin du fichier sur l’objet ingrédient |
| `google-adk/` | Exemple Python Google ADK et agent expérimental décrit comme agent OCR de reçus ; il est indépendant du déploiement Java principal |
| `TestOracle.java`, `test-oracle.bat` | Petit outil de vérification de connexion JDBC à Oracle |
| `VAKIO.md`, `todo.md` | Notes de présentation et d’exploitation ; `todo.md` consigne notamment des étapes déjà marquées terminées et un contrôle navigateur encore à faire |

Le générateur de codes-barres attend deux arguments : le chemin racine de sortie puis le nom/sous-chemin de dossier. Il ouvre une connexion Oracle, récupère les ingrédients de `AS_INGREDIENTS`, génère une image par identifiant, met à jour le chemin dans la base puis valide la transaction. En cas d’erreur, il tente un rollback.

Le code de `google-adk/main.py` est un exemple d’affichage sans lien visible avec le serveur Java. `google-adk/asyncAgent/agent.py` définit un agent OCR de reçu dont la sortie demandée est un JSON avec date, origine, magasin, type de document et lignes. Le README de ce dossier donne Python 3.9+ et `pip install google-adk` comme prérequis.

## 4. Technologies et construction

Les fichiers de projet déclarent Java 8 (`source`/`target` 1.8) et Java EE 7. Le code est compilé avec Ant et s’appuie sur des JAR locaux. Les références visibles couvrent notamment Oracle JDBC, JasperReports, Apache POI (Excel), iText (PDF), Barcode4J/Zxing selon l’outil, Jackson/Gson, Netty Socket.IO et des bibliothèques utilitaires.

`build.xml` utilise `build-file` comme répertoire de base, copie le contenu web et les bibliothèques, compile d’abord le code EJB puis les sources web, ajoute le JAR EJB au WAR et prépare un déploiement éclaté. Les autres fichiers Ant ont des chemins, sorties et cibles qui diffèrent ; il faut lire le script précis avant de l’utiliser. Les propriétés observées incluent des chemins locaux de serveurs et, pour le script Tomcat, des paramètres propres à un poste.

Le projet vise historiquement WildFly/JBoss. Le module principal utilise des API EJB ; Tomcat seul ne fournit pas le conteneur EJB nécessaire sans adaptations ou services supplémentaires.

## 5. Configuration et démarrage

La configuration d’accès aux données et d’autres paramètres se trouvent notamment dans `socobis-ejb/src/java/apj.properties` et `project.properties`. La configuration actuelle est spécifique à un environnement ; elle contient des paramètres de connexion et des adresses/chemins d’infrastructure. Ne copiez pas ces valeurs dans une nouvelle documentation ou un dépôt public. Utilisez une configuration propre à l’environnement et des secrets gérés séparément.

Pour préparer un démarrage, il faut disposer d’un JDK compatible, d’Ant, des dépendances attendues par le script sélectionné, d’un serveur Java EE configuré et d’une base Oracle avec un schéma compatible. Le fichier `todo.md` indique qu’une compilation, un démarrage local de WildFly et un test de connexion Oracle ont été réalisés dans le poste associé au dépôt ; cela ne confirme pas qu’ils fonctionneront dans un autre environnement ni que l’authentification et tous les parcours web ont été validés.

Un lanceur PowerShell est fourni à la racine :

```powershell
.\lancer-savonnerie.ps1
```

Il compile et déploie vers WildFly, puis démarre le serveur au premier plan. L’adresse locale est `http://localhost:8088/socobis` (port défini dans `standalone.xml`) ; `Ctrl+C` dans la console arrête WildFly. Le script supprime les anciens marqueurs de statut du déploiement `socobis.war` avant de compiler afin qu’un marqueur `.failed` ancien ne bloque pas une nouvelle tentative. Le script sélectionne le JDK 8 connu sur ce poste avant `JAVA_HOME`, car WildFly 10 ne démarre pas correctement avec Java 17. Un chemin Java différent peut être fourni avec `-JavaHome`, mais il doit pointer vers un JDK 8. Pour WildFly, il utilise `WILDFLY_HOME` s’il est défini, sinon le chemin historique `C:\wildfly-10.1.0.Final` ; Ant est pris depuis le `PATH` ou le chemin local connu. Pour indiquer explicitement les chemins :

```powershell
.\lancer-savonnerie.ps1 -WildFlyHome 'C:\wildfly-10.1.0.Final' `
    -JavaHome 'C:\Program Files\Java\jdk8' `
    -AntCommand 'C:\apache-ant\bin\ant.bat' `
    -HttpPort 8088
```

Le Dockerfile copie `deployments/socobis.war`, alors que le script Ant principal décrit ci-dessus construit surtout une arborescence web éclatée et que le dossier/fichier attendu n’apparaît pas dans l’inventaire versionné. Il faut aligner le résultat de construction et le chemin `COPY`, ainsi que configurer le serveur et Oracle, avant de considérer l’image exécutable.

## 6. Points d’attention pour maintenir le projet

1. **Ordre des SQL** — l’historique est volumineux et ne fournit pas un registre central des migrations. Identifier les scripts requis pour l’environnement cible et les faire valider avant application.
2. **Configuration par environnement** — externaliser les paramètres de connexion, secrets, chemins et URL d’infrastructure au lieu de dépendre de valeurs de poste.
3. **Construction reproductible** — les scripts Ant ont des chemins et comportements différents ; documenter une commande de référence et ses prérequis propres au dépôt.
4. **Dépendances** — les scripts référencent des JAR locaux sous `build-file/lib`. Vérifier leur disponibilité et leur provenance sur un clone propre.
5. **Pile technique ancienne** — Java 8, Java EE 7, serveur et nombreuses bibliothèques anciennes impliquent des contraintes de compatibilité. Toute mise à niveau mérite une migration progressive avec validation des modules.
6. **Répartition de la logique** — avant de modifier une fonctionnalité, suivre le parcours complet entre JSP, Servlet, classes métier et SQL associé.
7. **Documentation d’exploitation** — le README générique ne décrit ni la configuration Oracle, ni les rôles, ni les flux de déploiement ; les notes locales ne remplacent pas une procédure maintenue et validée.

## 7. Comment explorer une fonctionnalité

Pour suivre un domaine métier, une démarche pratique est :

1. chercher son nom dans `socobis-war/web/pages/` pour repérer l’écran JSP ;
2. examiner les scripts JavaScript associés, en particulier les appels AJAX et paramètres de formulaire ;
3. retrouver le traitement dans `socobis-war/src/java/servlet/` ou dans un composant web déclaré dans `WEB-INF` ;
4. suivre les classes correspondantes dans le package métier de `socobis-ejb/src/java/` ;
5. identifier les tables et vues Oracle citées par ces classes, puis rechercher les scripts SQL qui les définissent ;
6. vérifier les propriétés et ressources chargées à l’exécution ainsi que le rapport ou export éventuel.

Les noms de packages et dossiers de pages sont utiles pour se repérer, mais ne garantissent pas qu’un domaine soit isolé dans un seul dossier.

## 8. Limites de cette explication

Cette explication est un état des lieux statique fondé sur les fichiers du dépôt. Elle ne certifie pas une compilation complète, un déploiement, les droits et paramètres de la base Oracle, l’ordre d’application des 945 scripts, ni le comportement de toutes les pages. Les noms de domaines sont interprétés à partir des dossiers et composants présents ; les détails fonctionnels doivent être confirmés en suivant les traitements concernés.
