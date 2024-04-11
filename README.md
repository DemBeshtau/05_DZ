# Технологии файловой системы ZFS #
1. Определить алгоритм с наилучшим сжатием:<br/>
&ensp;&ensp;- определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);<br/>
&ensp;&ensp;- создать 4 файловые системы, на каждой применить совй алгоритм сжатия;<br/>
&ensp;&ensp;- для сжатия использовать либо текстовый файл, либо группу файлов.<br/>
2. Определить настройки пула.<br/>
&ensp;&ensp;- С помощью команды zfs import собрать pool ZFS.<br/>
&ensp;&ensp;- Командами zfs определить настройки:<br/>
&ensp;&ensp;&ensp;&ensp;- размер хранилища;<br/>
&ensp;&ensp;&ensp;&ensp;- тип pool;<br/>
&ensp;&ensp;&ensp;&ensp;- значение recordsize;<br/>
&ensp;&ensp;&ensp;&ensp;- какое сжатие используется;<br/>
&ensp;&ensp;&ensp;&ensp;- какая контрольная сумма используется.<br/>
3. Работа со снапшотами:<br/>
&ensp;&ensp;- скопировать файл из удалённой директории;<br/>
&ensp;&ensp;- восстановить файл локально zfs receive;<br/>
&ensp;&ensp;- найти зашифрованное сообщение в файле secret_message.<br/> 
### Исходные данные ###
&ensp;&ensp;ПК на Linux c 8 ГБ ОЗУ или виртуальна машина с включенной Nested Virtualization.<br/>
&ensp;&ensp;Предварительно установленное и настроенное ПО:<br/>
&ensp;&ensp;&ensp;Hasicorp Vagrant (https://www.vagrantup.com/downloads);<br/>
&ensp;&ensp;&ensp;Oracle VirtualBox (https://www.virtualbox.org/wiki/Linux_Downloads);<br/>
&ensp;&ensp;Все действия проводились с использованием Vagrant 2.4.0, VirtualBox 7.0.14 из<br/>
и образа CentOS 7 2004.01.
### Ход решения ###
### 1. Определение алгоритма с наилучшим сжатием ###
1.1. Просмотр всех имеющихся дисков виртуальной машины:
```shell
[root@zfs ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 
```
1.2. Подготовка пулов из двух дисков в режиме RAID 1:
```shell
[root@zfs ~]# zpool create tank1 /dev/sdb /dev/sdc
[root@zfs ~]# zpool create tank2 /dev/sdd /dev/sde
[root@zfs ~]# zpool create tank3 /dev/sdf /dev/sdg
[root@zfs ~]# zpool create tank4 /dev/sdh /dev/sdi
```
1.3. Просмотр списка созданных пулов:
```shell
[root@zfs ~]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
tank1   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
tank2   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
tank3   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
tank4   960M   122K   960M        -         -     0%     0%  1.00x    ONLINE  -
```
1.4. Включение разных алгоритмов сжатия в каждую из фаловых систем:
```shell
[root@zfs ~]# zfs set compression=lzjb tank1
[root@zfs ~]# zfs set compression=lz4 tank2
[root@zfs ~]# zfs set compression=gzip-9 tank3
[root@zfs ~]# zfs set compression=zle tank4
```
1.5. Проверка наличия алгоритмов сжатия на фаловых системах:
```shell
[root@zfs ~]# zfs get all | grep compression
tank1  compression           lzjb                   local
tank2  compression           lz4                    local
tank3  compression           gzip-9                 local
tank4  compression           zle                    local
```
1.6. Заполнение пулов однообразной информацией:
```shell
[root@zfs ~]# for i in {1..4}; do wget -P /tank$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
...
```
1.7. Проверка заполнения пулов информацией:
```shell
[root@zfs ~]# ll /tank/
/tank1:
total 22076
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log

/tank2:
total 17999
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log

/tank3:
total 10961
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log

/tank4:
total 40102
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log
```
1.8. Вывод информации о пулах с целью определения эффективности сжатия:
```shell
[root@zfs ~]# zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
tank1  23.5M   808M     23.3M  /tank1
tank2  17.8M   814M     17.6M  /tank2
tank3  10.9M   821M     10.7M  /tank3
tank4  39.3M   793M     39.2M  /tank4.
```
1.9. Вывод информации о степени сжатия файлов на пулах:
```shell
[root@zfs ~]# zfs get all | grep compressratio | grep -v ref
tank1  compressratio         1.90x                  -
tank2  compressratio         2.22x                  -
tank3  compressratio         3.65x                  -
tank4  compressratio         1.00x                  -
```
&ensp;&ensp;По итогам работы видно, что самым эффективным алгоритмом по степени сжатия является gzip-9.<br/>
### 2. Определение настроек пула ###
2.1. Получение и разархивирование архива для работы:
```shell
[root@zfs ~]# wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
[root@zfs ~]# ll
total 7124
-rw-------. 1 root root    5570 Apr 30  2020 anaconda-ks.cfg
-rw-r--r--. 1 root root 7275140 Dec  6 15:49 archive.tar.gz
-rw-------. 1 root root    5300 Apr 30  2020 original-ks.cfg
[root@zfs ~]# tar -xzvf archive.tar.gz 
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```
2.2. Проверка возможности импортирования содержимого архива в пул:
```shell
[root@zfs ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
```
2.3. Осуществление импорта скачанного пула и просмотр его состояния:
```shell
[root@zfs ~]# zpool status otus
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```
