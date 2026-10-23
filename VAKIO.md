# VAKIO — Présentation et guide du projet SOCOBIS

> Document établi à partir des fichiers présents dans le dépôt. Il décrit ce qui est visible dans le code ; l'accès à l'instance Oracle et un démarrage complet n'ont pas été vérifiés.

## 1. Qu'est-ce que le projet ?

SOCOBIS est une application web de gestion destinée à une savonnerie. Elle rassemble dans un même outil plusieurs fonctions métier :

- ventes, facturation, clients et proformas ;
- achats et fournisseurs ;
- stocks, magasins, inventaires et transferts ;
- fabrication, production, recettes et ordres de fabrication ;
- caisse, encaissements, dépenses, paiements et comptabilité ;
- ressources humaines, personnel et paie ;
- rapports, tableaux de bord et éditions PDF.

Le dépôt contient aussi des scripts SQL, un générateur de codes-barres et un dossier expérimental `google-adk`. Le README racine est encore le modèle GitLab par défaut ; les fonctionnalités ci-dessus sont donc déduites des modules et pages trouvés dans le code.

## 2. Technologies

| Élément | Technologie observée | Rôle |
|---|---|---|
| Serveur | Java 8, Java EE 7, EJB et Servlets | Logique métier et traitements serveur |
| Interface | JSP, JavaScript, jQuery, Bootstrap/AdminLTE et CSS/LESS | Pages web et interactions |
| Base de données | Oracle SQL, pilote JDBC Oracle | Données de gestion et vues métier |
| Rapports | JasperReports | Éditions et documents PDF |
| Construction | Apache Ant, bibliothèques JAR locales | Compilation et préparation du déploiement |
| Serveur applicatif visé | WildFly/JBoss 10.x | Hébergement de l'application Java EE |
| Autres outils | Docker, module Python/Google ADK, générateur Java de codes-barres | Déploiement conteneurisé et composants auxiliaires |

Le module `google-adk` est un exemple Python minimal (fonction d'affichage) et son README indique Python 3.9+ et `google-adk`. Rien dans le code examiné ne montre qu'il soit requis pour lancer l'application SOCOBIS principale.

## 3. Prérequis à installer

Pour construire et exécuter l'application principale, prévoir :

1. **Un JDK 8** : le projet déclare `javac.source=1.8` et `javac.target=1.8`. Il faut le compilateur (`javac`), pas uniquement un JRE.
2. **Apache Ant** : les scripts `build.xml`, `build-jenkins.xml`, `build-savonnerie.xml` et `build-tomcat.xml` construisent/préparent l'application.
3. **WildFly/JBoss 10.x**, version cohérente avec les API Java EE 7 et la configuration historique. Une autre version ou Tomcat nécessite une vérification/adaptation ; EJB n'est pas fourni par Tomcat seul.
4. **Oracle Database accessible sur le réseau**, avec un schéma compatible et un compte autorisé. Les scripts SQL fournis ne constituent pas à eux seuls une base Oracle installée.
5. Les bibliothèques locales attendues dans `build-file/lib`. Le dossier présent dans cet espace contient des JAR, dont le pilote Oracle, mais il est indiqué dans `.gitignore` ; il faut vérifier qu'il est bien livré dans un clone propre.

Pour le chemin Docker : Docker est nécessaire, mais le Dockerfile doit d'abord être ajusté (voir les problèmes ci-dessous). Pour le module Python séparé : Python 3.9+ et `pip install google-adk` selon son README.

Le navigateur web est le seul prérequis côté utilisateur final. Node.js n'est pas indiqué comme requis pour compiler l'application telle qu'elle est structurée ici.

## 4. Démarrer le projet

### 4.1 Préparer la configuration

- Installer/configurer Oracle et faire confirmer par l'équipe la bonne instance, le schéma et la liste ordonnée des migrations à appliquer.
- Vérifier les paramètres de connexion dans `socobis-ejb/src/java/apj.properties`. Le fichier contient actuellement une adresse, un utilisateur et un mot de passe en clair : ne pas publier ces valeurs ; les remplacer par des paramètres secrets propres à votre environnement et renouveler le secret exposé.
- Vérifier les chemins de fichiers/CDN dans `socobis-ejb/src/java/project.properties` et les éventuelles autres propriétés. Plusieurs adresses et chemins locaux/réseau y sont inscrits.
- Installer WildFly 10.x et relever son répertoire `standalone/deployments`.
- Vérifier la présence de `build-file/lib` et que les JAR nécessaires sont lisibles.

### 4.2 Construire et déployer avec le script CI

Le script le plus portable parmi ceux présents est `build-jenkins.xml`, mais il prépare un **WAR éclaté** dans un dossier de déploiement ; il ne fabrique pas un fichier `socobis.war` autonome. Son chemin par défaut est `../deployments`, relatif à `build-file` (donc `deployments` à la racine du dépôt).

1. Modifier la propriété `deploy.dir` dans `build-jenkins.xml` pour viser le répertoire `standalone/deployments` de votre instance WildFly.
2. Depuis la racine du dépôt, lancer :

   ```powershell
   ant -f build-jenkins.xml
   ```

   Le défaut du script est la cible `deploy`, qui dépend des étapes d'initialisation et de compilation.
3. Démarrer WildFly (par exemple `standalone.bat` sous Windows ou `standalone.sh` sous Linux/macOS), puis consulter les journaux du serveur pour vérifier le déploiement.
4. Ouvrir l'URL de l'application selon le contexte déployé et le port configuré sur WildFly. Le contexte attendu est généralement `/socobis`, à confirmer dans le serveur.

Ce déroulé est une procédure indicative tirée du script : elle n'a pas été exécutée ici. Le build peut nécessiter d'autres corrections propres à votre poste et à votre serveur.

### 4.3 Docker

Le Dockerfile ne peut pas être utilisé tel quel dans le dépôt consulté : il copie `deployments/socobis.war`, mais ce fichier et ce dossier ne sont pas présents. Il faut d'abord produire un WAR puis corriger le chemin de copie, ou adapter le conteneur à la sortie éclatée du script Ant. Il faut également configurer le datasource Oracle et les secrets dans l'environnement du conteneur. Le Dockerfile actuel ne configure pas cette connexion.

## 5. État des scripts de base de données

Le dépôt contient environ **946 fichiers SQL** (776 dans `bdd/` et 170 dans `bdd-async/` lors de l'inventaire). `bdd-async` est organisé par dates, avec des changements visibles jusqu'au 12 octobre 2026. Les scripts créent ou modifient des tables, vues et objets métier ; ils témoignent donc d'un schéma en évolution.

Cela ne permet pas de conclure que la base opérationnelle est à jour ou cohérente. Aucun accès à Oracle n'a été effectué. Il manque une procédure unique et vérifiable indiquant l'ordre d'application, les prérequis, les scripts déjà appliqués et la version courante du schéma. **Ne pas lancer tous les fichiers SQL en vrac sur une base de production.** Faire d'abord valider le plan de migration et disposer d'une sauvegarde restaurable.

## 6. Problèmes et éléments manquants visibles

- **Docker incomplet** : le Dockerfile attend `deployments/socobis.war`, absent du dépôt consulté.
- **Chemins de déploiement spécifiques aux postes** : `build.xml` vise un répertoire Windows local, `build-savonnerie.xml` et `build-tomcat.xml` ont aussi des chemins locaux ; `build-jenkins.xml` vise un dossier `deployments` relatif au dépôt plutôt que directement WildFly.
- **Configuration sensible et environnementale** : identifiants Oracle présents en clair dans `apj.properties` ; autres paramètres contiennent des chemins et adresses internes. Ils doivent être sortis du code versionné et fournis par environnement. Considérer le secret actuel comme exposé et le renouveler.
- **Dépendances locales possiblement non livrées** : `.gitignore` ignore `build-file/`, qui contient les bibliothèques attendues par Ant dans cet espace. Si ce dossier n'est pas suivi dans le dépôt distant, il faudra récupérer les JAR autorisés par une source interne fiable ou reconstituer une gestion des dépendances.
- **Pas de procédure de base fiable** : nombreux scripts SQL historiques, noms/dates/variantes différents, sans registre central d'application ni description complète de restauration.
- **Documentation insuffisante** : README racine générique, pas de guide d'installation officiel, pas de procédure de configuration de datasource documentée.
- **Pile ancienne** : Java 8, WildFly 10, pilote Oracle et nombreuses bibliothèques JAR anciennes. Cela augmente les risques de compatibilité et de sécurité ; toute mise à niveau devra être traitée comme un chantier de migration.
- **Composant ADK non intégré** : `google-adk/main.py` est un exemple indépendant, pas une fonction OCR achevée de l'application principale.

## 7. Complexité du projet

**Complexité globale : élevée à très élevée.** Ce n'est pas une petite application CRUD isolée : elle couvre des processus liés entre eux (achats, stocks, production, ventes, caisse et comptabilité), avec rapports, traitements métier et nombreux écrans.

L'échelle observée confirme cette estimation : environ 832 fichiers Java côté EJB, 768 côté web Java, 1 241 pages JSP, 123 JAR locaux et près de 946 scripts SQL. Ces nombres sont des comptages de fichiers, pas des mesures de qualité ou de lignes de code.

Les principaux facteurs de complexité sont :

- dépendance forte au modèle et aux vues Oracle ;
- migrations SQL nombreuses et historique difficile à reconstituer ;
- logique métier répartie entre EJB, Servlets, JSP et scripts SQL ;
- configuration et déploiement non reproductibles d'un poste à l'autre ;
- bibliothèques et serveur anciens, qui rendent les évolutions plus risquées.

Pour une prise en main, commencer par obtenir un schéma Oracle de développement connu, documenter les paramètres et le déploiement reproductibles, puis choisir un périmètre métier limité avant toute mise à niveau technique.

## 8. Limites de cet état des lieux

Cette documentation est une analyse statique du dépôt. Elle ne confirme ni la compilation, ni le démarrage effectif, ni la disponibilité de la base, ni l'exhaustivité des migrations. Les identifiants, adresses réseau et mots de passe ne sont volontairement pas recopiés dans ce document.


## 8. Compilation
$env:Path = "C:\apache-ant-1.10.18\bin;$env:JAVA_HOME\bin;$env:Path"
ant -f build.xml deploy

## 9. Déploiement
cd C:\wildfly-10.1.0.Final\bin
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-8.0.504.1-hotspot"
.\standalone.bat
