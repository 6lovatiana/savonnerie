
1. Configuration et Initialisation

Ces commandes s'utilisent pour configurer votre environnement et démarrer ou copier un projet. [1] (https://git.goffinet.org/13-annexe-c-commandes-git), [2] (https://www.youtube.com/watch?v=I-GaHVI3IwE&t=148)
• git config --global user.name "Votre Nom" : Définit le nom d'utilisateur pour vos commits.
• git config --global user.email "votre@email.com" : Définit l'adresse email associée à vos commits.
• git init : Initialise un nouveau dépôt Git local dans le dossier courant.
• git clone <url_du_depot> : Copie un dépôt distant existant sur votre machine. [1] (https://www.datacamp.com/fr/blog/git-commands), [2] (https://www.hostinger.com/fr/tutoriels/commandes-git/)

2. Le Cycle de Commit (Sauvegarde locale)

Pour suivre l'état de vos fichiers, préparer vos modifications et les enregistrer dans l'historique. [1] (https://www.atlassian.com/fr/git/glossary), [2] (https://www.youtube.com/watch?v=I-GaHVI3IwE&t=148)
• git status : Affiche l'état des fichiers (modifiés, non suivis, indexés).
• git add <nom_du_fichier> : Ajoute un fichier spécifique à la zone de transit (staging area).
• git add . : Ajoute tous les fichiers modifiés et nouveaux à la zone de transit.
• git commit -m "Message de commit" : Enregistre définitivement les modifications indexées dans l'historique local.
• git commit --amend : Modifie le tout dernier commit (pratique pour corriger un message ou un oubli).
• git diff : Montre les modifications non indexées par rapport au dernier commit. [1] (https://digitalunicorn.fr/glossaire/git-commit/), [2] (https://www.atlassian.com/fr/git/glossary), [3] (https://www.hostinger.com/fr/tutoriels/commandes-git/), [4] (https://www.datacamp.com/fr/blog/git-commands)

3. Gestion des Branches

Les branches permettent de travailler sur différentes fonctionnalités en parallèle sans altérer le code principal. [1] (https://gist.github.com/c283dd394f91ebe07227), [2] (https://www.hostinger.com/fr/tutoriels/commandes-git/)
• git branch : Liste toutes les branches locales de votre projet.
• git branch <nom_de_branche> : Crée une nouvelle branche.
• git checkout <nom_de_branche> : Bascule sur la branche spécifiée.
• git checkout -b <nom_de_branche> : Crée une nouvelle branche et bascule dessus immédiatement.
• git merge <nom_de_branche> : Fusionne la branche spécifiée dans la branche actuelle.
• git branch -d <nom_de_branche> : Supprime une branche locale (une fois fusionnée). [1] (https://gist.github.com/9d55a4ff37b5765fdc39651147109cf5), [2] (https://www.youtube.com/watch?v=YPeadnyI450), [3] (https://www.youtube.com/shorts/38W5_ip9Xx4), [4] (https://gist.github.com/c283dd394f91ebe07227), [5] (https://www.hostinger.com/fr/tutoriels/commandes-git/), [6] (https://www.datacamp.com/fr/blog/git-commands)

4. Synchronisation avec un Dépôt Distant (GitHub, GitLab, etc.)

Ces commandes permettent de partager votre code avec votre équipe et de récupérer le leur. [1] (https://www.youtube.com/watch?v=I-GaHVI3IwE&t=148), [2] (https://git.goffinet.org/13-annexe-c-commandes-git)
• git remote add origin <url_du_depot> : Lie votre dépôt local à un dépôt distant.
• git push origin <nom_de_branche> : Envoie vos commits locaux vers le dépôt distant.
• git pull : Récupère et fusionne automatiquement les dernières modifications distantes dans votre branche actuelle (git fetch + git merge).
• git fetch : Télécharge les données du dépôt distant sans les fusionner avec votre code local (permet d'inspecter avant d'intégrer). [1] (https://git-scm.com/book/fr/v2/Commandes-Git-Partage-et-mise-%C3%A0-jour-de-projets), [2] (https://gist.github.com/ea6cc981c31fb8b25f8f), [3] (https://www.youtube.com/watch?v=I-GaHVI3IwE&t=148), [4] (https://www.datacamp.com/fr/blog/git-commands), [5] (https://www.hostinger.com/fr/tutoriels/commandes-git/)

5. Historique et Inspection

Pour naviguer dans le passé du projet et comprendre les modifications. [1] (https://git.goffinet.org/13-annexe-c-commandes-git)
• git log : Affiche l'historique chronologique de tous les commits.
• git log --oneline : Affiche l'historique de manière très condensée (un commit par ligne).
• git blame <fichier> : Affiche ligne par ligne qui a modifié le fichier en dernier et dans quel commit.
• git show <commit_id> : Visualise les détails et les changements précis apportés par un commit spécifique. [1] (https://comprendre-git.com/fr/commandes/), [2] (https://www.hostinger.com/fr/tutoriels/commandes-git/), [3] (https://git.goffinet.org/13-annexe-c-commandes-git)

6. Annulations et Nettoyage
Attention : certaines de ces commandes peuvent écraser votre travail en cours si elles sont mal utilisées.
• git stash : Met temporairement de côté vos modifications non commitées pour nettoyer votre espace sans perdre votre travail.
• git stash pop : Récupère et applique les modifications précédemment mises de côté avec git stash.
• git checkout -- <fichier> : Annule les modifications locales non commitées d'un fichier pour le restaurer à son état du dernier commit.
• git reset HEAD <fichier> : Désindexe un fichier (retire de la zone de transit) sans effacer les modifications.
• git reset --hard HEAD : DANGER - Efface l'intégralité des modifications non commitées depuis le dernier commit.
• git revert <commit_id> : Crée un nouveau commit qui fait exactement l'inverse du commit spécifié (méthode sûre pour annuler un changement partagé). [1] (https://gist.github.com/9d55a4ff37b5765fdc39651147109cf5), [2] (https://www.datacamp.com/fr/blog/git-commands), [3] (https://comprendre-git.com/fr/commandes/), [4] (https://www.hostinger.com/fr/tutoriels/commandes-git/), [5] (https://git.goffinet.org/13-annexe-c-commandes-git)
