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
1. Просмотр всех имеющихся дисков виртуальной машины:
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
2. Подготовка пулов из двух дисков в режиме RAID 1:
```shell
[root@zfs ~]# zpool create tank1 /dev/sdb /dev/sdc
[root@zfs ~]# zpool create tank2 /dev/sdd /dev/sde
[root@zfs ~]# zpool create tank3 /dev/sdf /dev/sdg
[root@zfs ~]# zpool create tank4 /dev/sdh /dev/sdi
```
3. Просмотр списка созданных пулов:
```shell
[root@zfs ~]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
tank1   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
tank2   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
tank3   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
tank4   960M   122K   960M        -         -     0%     0%  1.00x    ONLINE  -
```
4. Включение разных алгоритмов сжатия в каждую из фаловых систем:
```shell
[root@zfs ~]# zfs set compression=lzjb tank1
[root@zfs ~]# zfs set compression=lz4 tank2
[root@zfs ~]# zfs set compression=gzip-9 tank3
[root@zfs ~]# zfs set compression=zle tank4
```
5. 
