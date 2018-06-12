<h2 align="center">Téléphone pour FiveM</h2>

**Fonctionalitées**
  - List des conctacts
  - Envoie de sms
  - Appel vocal
  - Appel anonyme
  - Application Banque
  - Application Tchat anonyme
  - Application Bourse
  - Coque / Fond ecran customisable

## Info
#Changer le nom du réseau
```
* Modifier la clef 'reseau' dans le fichier /html/static/config/config.json
```

Pour ajouter / modifier les coques & fond d'écrans
```
* Coque => Modifier les images dans le dossier /html/static/img/coque
* Fond d'écran => Modifier les images dans le dossier /html/static/img/background
* Mettre à jour le fichier /html/static/config/config.json
```

Customiser les appels services
``` javascript
// fichier /html/static/config/config.json
// ...
"serviceCall": [
  // Service
  {
    "display": "Police", // Nom du service
    "backgroundColor": "#FF0000", // Couleur
    "subMenu": [  // List des options proposé par le service
      {
        "title": "Envoyer un message", // Nom de l'option
        "color": "#303F9F" // Couleur de l'option
        "eventName": "callService", // Nom de l'event générer
        "type": "journaliste", // Parametre supplement dans l'event
      },
      {
        // Option 2
      }
    ] // List des options
  }
  },
  {
    // Service 2
    "display": "Samu",
    "subMenu": [{
      // ...
    }]
  }
]
// ...
```


## License

[GNU v3](https://opensource.org/licenses/gpl-3.0.html)

Jonathan (Gannon) D
