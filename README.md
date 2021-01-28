# Развертывание инфраструктыры для веб проекта на нескольких виртуальных машинах

Развертывание сервера обмена файлами *Seafile* и его инфраструктуры на виртуальных машинах

## Подготовка и запуск

Запускаем *Vagrantfile* с виртуальными машинами. Потом запускаем *inatll.yml*, который установит необходимые пакеты и проведет первичную настройку серверов.

## WEB

Основной веб сервер с бахой данных, где находится веб приложение *seafile*.

Для первого запуска необходимо запустить */opt/seafile/seafile-server-7.1.5/setup-seafile-mysql.sh* для первичной настройки приложения и баз данных, где мы указываем наши параметры. Базы данных и их пользователь для *seafile* уже были созданы *playbook.yml*, поэтому нужно только их указать в вариантах ответа.

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

После остановим наше прриложение для последующей настройки.

	[root@web seafile-server-7.1.5]# ./seahub.sh stop 

	Stopping seahub ...
	Done.

	[root@web seafile-server-7.1.5]# ./seafile.sh stop 

	Stopping seafile server ...
	Done.

Запустим *seafile_start.yml* для применения наших конфигов в *seafile*.

	$ ansible-playbook ansible/seafile-config.yml 

	PLAY [web] ***************************************************************************

	TASK [Gathering Facts] ***************************************************************
	ok: [web]

	TASK [seafile-config : copy ccnet.conf] **********************************************
	changed: [web]

	TASK [seafile-config : copy ccnet.conf] **********************************************
	changed: [web]

	TASK [seafile-config : stop seafile.service] *****************************************
	ok: [web]

	TASK [seafile-config : stop seahub.service] ******************************************
	ok: [web]

	TASK [seafile-config : start seafile.service] ****************************************
	changed: [web]

	TASK [seafile-config : start seahub.service] *****************************************
	changed: [web]

	PLAY RECAP ***************************************************************************
	web                        : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
