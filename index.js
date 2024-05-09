var functions = require("firebase-functions");
var apn = require('apn');

// admin.initializeApp({
//   credential: admin.credential.cert({
//   "type": "service_account",
//   "project_id": "my-mink",
//   "private_key_id": "cdbcd0b24e90281017ddc291ed980748b6579fcb",
//   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDQgHLn6uVa5LGB\nFAx2BMnARRGpRlvuX8a2bJs33LmV8sIqH8tRQj0KgqC6RntsT8cNEBm6keiA2Sgs\n2xqo/Wg/n5dm7QgXwDQHUZJQW/wj2tctsarrWoZu7yhZ56RwdaN289eHfL2QwEJa\nkzoSF7XFZWal6kS/6lWVTIFaFwhVuDYtU1w8a7cRkjYFu2eRwpUWBuBY0fHa5Osj\nXS0c7s4pV3OG1nHrAa4yv2UNtEabQ2DbL9GnGCJaj1J6NeiWYYW5USavPJP+8Z9u\nuuPLYCq8Xi5ty71+mGzyo1bcRoxeYHxZzzsOdpf24bdFnn21bJx0qbugTMlALOt/\njdyzyp7BAgMBAAECggEAJMpFfD6qcbtgxtHu0PRPVSnaz++mUQ19VrsbOGQuKxNG\nx4AMtC3n727VRYkiRh5dlSR+JbmROQsYV7HhpmfweSmD4Zl5kBdOFuyB0MQqXXlD\n9sAe1KCIkBKLIDILhfx794VXRoTwPhZunuTTnlWosUgPML+BmguTRmDVgjwGMHmb\nH+aGw6fC2R42dADPFFjpJ+343K8cgwz92pBaEWMCfr97MXPfyK7RpxLZFo8hrCQA\nrIwIMjd9uJoZIpf3opl+99OftyKpJUc5s6LLe0i2sqpxHsDnI9AmqJMHAawOT6x3\n+wnR2wWvDtITzqAPiIsnaKJUCsHDbrNCj05wItrisQKBgQDvcbkCxV1uruXtH8hq\ndod/48VhCDTMbWg82rLh1DWsFhX6cH6d1+kNFKN59WldtYCCU6g3suh+KsbwgYAt\nfc94obb1l6WSVs5m5vjs2HB9q2FVX0cLqPIqaVoCxvMjDqxiMcFlhZk3JbI72rIp\nA3iuy9kYmFMxDzLkZz44TFRxbwKBgQDe6weP4BwKjr9r06KxjAtoxQDtJcGDmQVL\nYfEe4bcCsHpePFoadcXIZGg+1SqVaQt2eF80sM5TVnu/dzlx5XOkwA6Ot7m2TTAV\nT/WyoWByGvf7eflcz2DIDfyQdZnl6Hr+oMwcF0OyXHNXoK0le/dLWcoRsgp1jsfh\nUMjKt8x6zwKBgQDuK0w/+VkqU0XZS5fqbePxzfnyvlrmTJ02isML5i1M8tsBtQv8\nrVre6/x/vyADWhptiBD29jpT5PDlIasBlPbdot1+BE1o9ndv26cWz2N1XRb/+DmO\n24mlrg0eXg5SfLHzKlKYTP9N320eJDa6nP1ZwOI8mKeHUPrqPdeh4CrOeQKBgEHm\n+/pWCBQ69W58R9nzjB/yNf7mLZqpL36EuxMlKcS6xcJ8VysBbHJ89LC2tnsrbf8d\nQRBDwQu0QqttJOd+LT0kpmkc+eNiWHfEht/Dg87YGD4ZZlZA3Nzn/aX7jn8AxvPm\nN9GKMzJU0Ki0UNwHFSoKpomquBrfFkqPZn0/70zTAoGAZZ7ZrP/CcPHD1VEaPRaS\njPuZcgaQZHz09HWx4wyTKX0UsvLvtGAuVvU4DwFZj8nroiYzuD6B/87BTNyzvwWm\neqlTEssRhRJJjGVXlOaFsHqtDm7uXCvN6MJ2bn8m5i3d8XpfPnnuNs2GB85/fGTD\npODgnrMh91WiHW4nKUVCjK4=\n-----END PRIVATE KEY-----\n",
//   "client_email": "firebase-adminsdk-2gw0a@my-mink.iam.gserviceaccount.com",
//   "client_id": "114778509096057276776",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-2gw0a%40my-mink.iam.gserviceaccount.com",
//   "universe_domain": "googleapis.com"
// })
// });


exports.hourlyRunner = functions.runWith({ memory: '2GB'}).pubsub.schedule('* * * * *').onRun(async (context) => {


    var config = {
  
          cert: 'certificates.pem',
          key: 'key.pem', 
          production: false
    };
    var apnProvider = new apn.Provider(config);

    var notification = new apn.Notification();
    var recepients = [];
    recepients[0] = apn.token('d66bdcb641195cc57fbdee5b91bfc4831ee25cbd1d645077cb71a2f948ca7197');

    notification.topic = 'in.softment.myMink.voip'; // you have to add the .voip here!!
    notification.payload = {
       {'messageFrom': 'John Appleseed'};
    };

     apnProvider.send(notification, recepients).then((reponse) => {
        console.log(reponse);
        return response.send("finished!");
    });


});
