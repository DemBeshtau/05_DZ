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
&ensp;&ensp;Предварительно установленное и настроенное ПО:
&ensp;&ensp;&ensp;Hasicorp Vagrant (https://www.vagrantup.com/downloads);<br/>
&ensp;&ensp;&ensp;Oracle VirtualBox (https://www.virtualbox.org/wiki/Linux_Downloads);<br/>
&ensp;&ensp;Все действия проводились с использованием Vagrant 2.4.0, VirtualBox 7.0.14 из<br/>
и образа CentOS 7 2004.01.


# Файловые системы и LVM #
  - На образе centos/7 - v. 1804.2:<br/>
1. Уменьшить том под корневую директорию / до 8 GB;<br/>
2. Выделить том под /home;<br/>
3. Выделить том под /var - реализовать в mirror;<br/>
4. В /home - подготовить том для снапшотов;<br/>
5. Реализовать автомонтирование разделов /home и /var в fstab;<br/>
6. Продемонстрировать работу со снапшотами:<br/>
&ensp;&ensp; a. создать файлы в /home/;<br/>
&ensp;&ensp; b. снять снэпшот;<br/>
&ensp;&ensp; c. удалить файлы в /home/;<br/>
&ensp;&ensp; d. восстановить содержимое /home/ со снапшота;<br/>
### Исходные данные ###
&ensp;&ensp;На диске /dev/sda в разделе /dev/sda3 посредством LVM реализована группа разделов VolGroup00,<br/> 
на которой,в свою очередь, находятся логические разделы LogVol00 (37.5 GB) для размещения корня<br/> 
исходной операционной системы и LogVol01 (1 GB) для размещения SWAP-раздела. Раздел /dev/sda2   
является разделом для размещения /boot. Диски sdb (10 GB), sdc (2 GB), sdd (1 GB), sde (1 GB) чистые. 
### Ход решения ###
1. Подготовка временного тома для корневого раздела / исходной системы:
```shell
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
```
