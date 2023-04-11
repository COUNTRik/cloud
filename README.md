# Установка и настройка с помощью Ansible облачной системы хранения файлов Seafile с прокси-сервером NGINX и сервера мониторинга Elasticsearch + Kibana + резервное копирование данных

Развертывание сервера обмена файлами *Seafile* и его инфраструктуры на виртуальных машинах

## Подготовка и запуск

Запускаем *Vagrantfile* с виртуальными машинами. Потом запускаем *install.yml*, который установит необходимые пакеты и проведет первичную настройку серверов. После запускаем *network.yml* для настройки нашей сети и файрвола на входе.

## WEB

Основной веб сервер с бахой данных, где находится веб приложение *seafile*.

Для первого запуска необходимо запустить */opt/seafile/seafile-server-7.1.5/setup-seafile-mysql.sh* для первичной настройки приложения и баз данных, где мы указываем наши параметры. Базы данных и их пользователь для *seafile* уже были созданы *install.yml*, поэтому нужно только их указать в вариантах ответа.

	---------------------------------
	This is your configuration
	---------------------------------

	    server name:            otus
	    server ip/domain:       seafile.otus.com

	    seafile data dir:       /opt/seafile/seafile-data
	    fileserver port:        8082

	    database:               use existing
	    ccnet database:         ccnet_db
	    seafile database:       seafile_db
	    seahub database:        seahub_db
	    database user:          seafile

После необходимо запустить в директории */opt/seafile/seafile-server-7.1.5/* скрипты *seafile.sh start* и *seahub.sh start* в которых мы укажем пароль администратора для *seafile*

	[root@web seafile-server-7.1.5]# ./seafile.sh start

	[01/23/21 15:02:11] ../common/session.c(148): using config file /opt/seafile/conf/ccnet.conf
	Starting seafile server, please wait ...
	** Message: 15:02:11.991: seafile-controller.c(572): No seafevents.

	Seafile server started

	Done.
	[root@web seafile-server-7.1.5]# ./seahub.sh start 

	LC_ALL is not set in ENV, set to en_US.UTF-8
	Starting seahub at port 8000 ...

	----------------------------------------
	It's the first time you start the seafile server. Now let's create the admin account
	----------------------------------------

	What is the email for the admin account?
	[ admin email ] admin@otus.com

	What is the password for the admin account?
	[ admin password ] 

	Enter the password again:
	[ admin password again ] 

	----------------------------------------
	Successfully created seafile admin
	----------------------------------------

	Seahub is started

	Done.

После остановим наше приложение для последующей настройки.

	[root@web seafile-server-7.1.5]# ./seahub.sh stop 

	Stopping seahub ...
	Done.

	[root@web seafile-server-7.1.5]# ./seafile.sh stop 

	Stopping seafile server ...
	Done.

Запустим *seafile_start.yml* для копирования и применения конфигов в *seafile*, а также настройки и запуска сервиса резервного копирования.

	$ ansible-playbook ansible/seafile_start.yml 

	PLAY [web] ***************************************************************************

	TASK [Gathering Facts] ***************************************************************
	ok: [web]

	TASK [seafile_reload : copy ccnet.conf] **********************************************
	changed: [web]

	TASK [seafile_reload : copy ccnet.conf] **********************************************
	changed: [web]

	TASK [seafile_reload : copy backup.sh for seafile] ***********************************
	changed: [web]

	TASK [seafile_reload : create backup-seafile.service] ********************************
	changed: [web]

	TASK [seafile_reload : create backup-seafile.timer] **********************************
	changed: [web]

	TASK [seafile_reload : force systemd to read configs] ********************************
	ok: [web]

	TASK [seafile_reload : stop seafile.service] *****************************************
	ok: [web]

	TASK [seafile_reload : stop seahub.service] ******************************************
	ok: [web]

	TASK [seafile_reload : start seafile.service] ****************************************
	changed: [web]

	TASK [seafile_reload : start seahub.service] *****************************************
	changed: [web]

	TASK [seafile_reload : start backup-seafile.timer] ***********************************
	changed: [web]

	TASK [seafile_reload : manage politic selinux for seafile and nginx] *****************
	changed: [web]

	TASK [seafile_reload : mount backup nfs] *********************************************
	changed: [web]

	PLAY RECAP ***************************************************************************
	web                        : ok=14   changed=10   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

*Seafile* готов к работе

## Восстановление или перенос Seafile на другой сервер

Резервное копирование производится с помощью таймера и сервиса бэкапа, который представляет из себя скрипт *backup.sh*.

Резервные копии сохраняются через nfs в папку */mnt/backup* на nfs-server.

Устанавливаем *Seafile* на другой сервер так же как описано в предыдущем пункте.

Останавливаем сервисы *Seafile*.

Резервное копирование производится с помощью таймера и сервиса бэкапа, который представляет из себя скрипт *backup.sh*.

После копируем файлы из бэкапа */mnt/backup/[Дата]/seafile-data* в */opt/seafile/seafile-data*.

Восстанавливает дампы базы

	mysql -u[username] -p[password] ccnet_db < [Дата].ccnet_db.sql
	mysql -u[username] -p[password] seafile_db < [Дата].seafile_db.sql
	mysql -u[username] -p[password] seahub_db < [Дата].seahub_db.sql

Запустить скрипт проверки и восстановления данных */opt/seafile/seafile-server-latest/seaf-fsck.sh*.

Запускаем сервисы *Seafile*.

Можно переходить по ссылке *http://seafile.otus.com* (можно добавить запись в свой днс сервер или добавить строчку в файл hosts *seafile.otus.com   10.20.30.40*).

## Установка Elasticsearch + Kibana

Так как установка Elasticsearch + Kibana занимает довольно продолжительное время, они вынесены в отдельный плейбук *elastic.yml*. Заппустив его, он установит настроит *filebeat* *metricbeat* на сервере *web* и *elastic* *kibana* на сервере *backup*. После останется только запустить на сервере *web* команды


	# filebeat setup

	# metricbeat setup

Ansible ругается на вывод этих команд, возможно из за того что во время выпонения этих команд довольно долго прогружаются дашборды для kibana. Поэтому их нужно будет запустить вручную один раз.

После заходим в *kibana* по ссылке *10.20.30.40:5601* (пакеты перенапрявляются правилами NAT на ip роутера, который смотрит во внешнюю сеть).

## Выводы

Благодаря Ansible можно разнести все роли (Веб сервер, База данных, NFS сервер, Роутер) по разным серверам или же наоборот собрать на одном мощном сервере, чуть чуть изменив конфигурационные файлы и некоторые таски.

Что можно еще добавить:

- SSL для https
- Перенести конфигурационные файлы в templates, для удобства и исипользования в других проектах.
- Добавить переменные в роли, для удобства и исипользования в других проектах.
- Добавить auditbeat, heartbeat и запустить систему оповещения.
