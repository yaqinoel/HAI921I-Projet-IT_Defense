extends RefCounted
## Données du QCM : quelle défense est efficace contre quel danger ?
##
## Les clés des dictionnaires sont les `type` de vos .tres
## (ex : &"DangerPhishing" dans danger_phishing.tres).
##
## POUR AJOUTER UN DANGER : ajoutez une entrée dans DANGERS.
## POUR AJOUTER UNE DÉFENSE : ajoutez une entrée dans DEFENSES.

## Défenses proposées comme réponses (label affiché + ressource pour l'icône).
const DEFENSES: Dictionary = {
	"DefenseAntivirus": {
		"label": "Antivirus",
		"data": preload("res://data/defenses/defense_antivirus.tres"),
	},
	"DefenseDatashield": {
		"label": "DataShield",
		"data": preload("res://data/defenses/defense_datashield.tres"),
	},
	"DefenseMailfilter": {
		"label": "Filtre mail",
		"data": preload("res://data/defenses/defense_mailfilter.tres"),
	},
	"DefenseAntiddos": {
		"label": "Anti-DDoS",
		"data": preload("res://data/defenses/defense_antiddos.tres"),
	},
	"DefenseSystemMaintenance": {
		"label": "Maintenance système",
		"data": preload("res://data/defenses/defense_systemMaintenance.tres"),
	},
	"DefenseSave": {
		"label": "Sauvegarde",
		"data": preload("res://data/defenses/defense_save.tres"),
	},
	"DefenseDNS": {
		"label": "DNS sécurisé",
		"data": preload("res://data/defenses/defense_DNS.tres"),
	},
	"DefenseFirewall": {
		"label": "Pare-feu",
		"data": preload("res://data/defenses/defense_firewall.tres"),
	},
}

## Dangers : texte de la question, défenses efficaces, explication.
##
## "defenses" = TOUTES les défenses considérées comme efficaces.
## À chaque question, UNE d'entre elles est tirée au hasard comme bonne réponse,
## et les mauvaises réponses sont tirées parmi les défenses qui ne sont PAS dans
## cette liste (aucune ambiguïté possible).
##
## "label" est inséré dans : "Quelle défense est efficace contre <label> ?"
const DANGERS: Dictionary = {
	"DangerPhishing": {
		"label": "le phishing (hameçonnage)",
		"defenses": ["DefenseMailfilter", "DefenseDNS"],
		"explanation": "Le phishing consiste à envoyer de faux messages ou de faux sites pour voler des identifiants. Le filtre mail bloque ces messages et le DNS sécurisé empêche d'accéder aux faux sites.",
	},
	"DangerDDOS": {
		"label": "les attaques DDoS",
		"defenses": ["DefenseAntiddos", "DefenseFirewall"],
		"explanation": "Une attaque DDoS inonde un service de requêtes pour le rendre inaccessible. L'Anti-DDoS absorbe et filtre ce trafic, et le pare-feu limite les connexions suspectes.",
	},
	"DangerVirus": {
		"label": "les virus",
		"defenses": ["DefenseAntivirus", "DefenseFirewall"],
		"explanation": "Un virus est un programme malveillant qui s'installe et se propage. L'antivirus le détecte et l'élimine, et le pare-feu bloque ses communications.",
	},
	"DangerRansomware": {
		"label": "les ransomwares (rançongiciels)",
		"defenses": ["DefenseSave", "DefenseAntivirus"],
		"explanation": "Un ransomware chiffre vos fichiers et exige une rançon. L'antivirus peut le bloquer à l'entrée, et une sauvegarde permet de tout restaurer sans payer.",
	},
	"DangerCorruption": {
		"label": "la corruption de données",
		"defenses": ["DefenseDatashield", "DefenseSave"],
		"explanation": "La corruption altère ou détruit des fichiers parfois sans qu'on s'en aperçoive. DataShield protège l'intégrité des données et une sauvegarde permet de retrouver une version saine.",
	},
	"DangerCrashPC": {
		"label": "les plantages d'ordinateur",
		"defenses": ["DefenseSystemMaintenance"],
		"explanation": "Un plantage vient souvent d'un système obsolète ou mal entretenu. La maintenance (mises à jour, nettoyage) prévient ces pannes.",
	},
	"DangerHumanError": {
		"label": "les erreurs humaines",
		"defenses": ["DefenseSave", "DefenseDatashield"],
		"explanation": "Une suppression par erreur ou une mauvaise manipulation est l'une des premières causes d'incident. La sauvegarde permet de revenir en arrière et DataShield limite les accès et protège les données.",
	},
}
