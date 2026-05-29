# 📱 Script Envoi SMS — Monitoring & Alerting

> Script Shell automatique pour l'envoi de SMS de monitoring contenant des données, des alertes et des KPIs, alimenté par un fichier de données CSV.

---

## 📋 Description

Ce projet permet d'envoyer automatiquement des SMS personnalisés à une liste de destinataires, en lisant le contenu depuis un fichier CSV local. Il est conçu pour les besoins de monitoring et de reporting automatique (alertes, KPIs, données métier).

---

## 🗂️ Structure du projet

```
sms/
│
├── script.sh                  # Script principal d'envoi SMS
├── config.txt                 # Fichier de configuration (destinations, expéditeur, chemin données)
├── data/
│   └── messages.csv           # Fichier de données contenant les messages à envoyer
├── archive/                   # Archivage automatique des fichiers traités (créé automatiquement)
└── log/                       # Logs d'exécution (créé automatiquement)
```

---

## ⚙️ Configuration

Modifier le fichier `config.txt` :

```bash
destinations="+21600000000,+21611111111"   # Numéros destinataires (séparés par virgule)
from_sms="KPI"                             # Nom de l'expéditeur SMS
data_file="/chemin/vers/data/messages.csv" # Chemin absolu vers le fichier de données
```

---

## 📄 Format du fichier de données

Le fichier `messages.csv` doit respecter ce format (séparateur `|`) :

```
message|ordre
Ventes : 1250 lignes activées|1
Objectif mensuel atteint à 78%|2
Top région : Grand Tunis avec 430 ventes|3
```

| Colonne | Description |
|---------|-------------|
| `message` | Texte à inclure dans le SMS |
| `ordre` | Ordre d'affichage des lignes dans le SMS |

> ✅ Il suffit de mettre à jour ce fichier CSV pour changer le contenu des SMS, sans modifier le script.

---

## 🚀 Utilisation

### 1. Cloner le projet

```bash
git clone https://github.com/tayssirmlaiki/script-envoi-sms.git
cd script-envoi-sms
```

### 2. Donner les permissions d'exécution

```bash
chmod +x script.sh
```

### 3. Configurer le fichier config

```bash
nano config.txt
```

### 4. Préparer le fichier de données

```bash
nano data/messages.csv
```

### 5. Exécuter le script

```bash
./script.sh
```

---

## 🔄 Automatisation avec Cron

Pour exécuter le script automatiquement chaque jour à 07h00 :

```bash
crontab -e
```

Ajouter la ligne :

```bash
0 7 * * * /home/reporting_automation/scripts/sms/script.sh
```

---

## 📝 Logs

Les logs d'exécution sont générés automatiquement dans le dossier `log/` :

```
log/execution_sms_YYYY-MM-DD.log
```

Exemple de log :

```
2026-04-23 07:00:01 | Début lecture du fichier de données
2026-04-23 07:00:01 | Lecture OK : 3 ligne(s) récupérée(s)
2026-04-23 07:00:02 | Contenu SMS généré
2026-04-23 07:00:03 | Début envoi SMS
2026-04-23 07:00:04 | SMS envoyés ✔
2026-04-23 07:00:04 | ==== Fin du script ====
```

---

## 🛠️ Prérequis

- **OS** : Linux / Unix
- **Bash** : version 4.0+
- **curl** : pour l'envoi via API SMS
- Accès réseau vers le concentrateur SMS

---

## 👤 Auteur

**Tayssir Mlaiki**
- 📧 tayssir.mlaiki@gmail.com
- 🐙 [github.com/tayssirmlaiki](https://github.com/tayssirmlaiki)

---

## 📄 Licence

Ce projet est à usage professionnel et interne.
