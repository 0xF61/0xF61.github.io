---
title: "Localhost.run"
etiketler: "diğer"
seriler: "Yazılar"

---

[Localhost.run](https://localhost.run/) size NAT (Network Address Translation),
CGNAT (Carrier Grade NAT) veya firewall arkasında olan cihazlarınıza uzaktan SSH
tünelleme kullanarak erişilebilir hale getiren cloud tabanlı bir hizmettir. Bu
hizmeti kullanabilmek için ekstra herhangi bir indirme yapmanız gerekmemektedir.
Tek satır ssh komutu kullanarak cihazınızda istediğiniz portu
`http://*.localhost.run/` subdomainine yönlendirebilirsiniz. ( *https
destekliyor* )

`ssh -R 80:localhost:<Lokal-Port> ssh.localhost.run`

8080 portunda çalışan bir servis için bu komut şu şekilde görünecektir.

`ssh -R 80:localhost:8080 ssh.localhost.run`

``` shell
$ ssh -R 80:localhost:8080 ssh.localhost.run
The authenticity of host 'ssh.localhost.run (35.193.161.204)' can't be established.
RSA key fingerprint is SHA256:FV8IMJ4IYjYUTnd6on7PqbRjaZf4c1EhhEBgeUdE94I.
Are you sure you want to continue connecting (yes/no)? yes
Connect to http://xf61.localhost.run or https://xf61.localhost.run
```

Daha sonra herhangi bir cihazdan `https://xf61.localhost.run` adresine giderek
uzaktan yukarıdaki ssh komutu çalıştırılan porttaki servise erişilebilir.
