REAL DOC => https://github.com/coturn/coturn

BASIC INSTALL COTURN

### Install coturn

```
sudo apt-get install coturn
```

### edit /etc/turnserver.conf
```
  vi /etc/turnserver.conf
```

### Add static user
```conf
user=myusername:mypassword
```

run turnserver
```
  turnserver -L yourip -o -a -f -r yourservername
  Exemple: turnserver -L 51.10.10.124 -o -a -f -r mycitygta.com
```

Edit config.json
```json
{
  "useWebRTCVocal": true,
  "RTCConfig": {
    "iceServers": [{
      "urls": ["turn:mycitygta.com"],
      "username": "myusername",
      "credential": "mypassword"
    }]
  },
}
```
