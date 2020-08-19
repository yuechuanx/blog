---
title: Django 导出和导入数据
toc: true
comments: true
tags:
  - django
slug: django-export-and-import-data
categories:
  - Web
date: 2020-04-13 18:57:03
---

`dumpdata` 命令：

它可以用来备份（导出）模型实例或整个数据库

```sh
./manage.py dumpdata --help
usage: manage.py dumpdata [-h] [--format FORMAT] [--indent INDENT] [--database DATABASE] [-e EXCLUDE] [--natural-foreign] [--natural-primary] [-a] [--pks PRIMARY_KEYS]
                          [-o OUTPUT] [--version] [-v {0,1,2,3}] [--settings SETTINGS] [--pythonpath PYTHONPATH] [--traceback] [--no-color] [--force-color]
                          [app_label[.ModelName] [app_label[.ModelName] ...]]

Output the contents of the database as a fixture of the given format (using each model's default manager unless --all is specified).

positional arguments:
  app_label[.ModelName]
                        Restricts dumped data to the specified app_label or app_label.ModelName.

optional arguments:
  -h, --help            show this help message and exit
  --format FORMAT       Specifies the output serialization format for fixtures.
  --indent INDENT       Specifies the indent level to use when pretty-printing output.
  --database DATABASE   Nominates a specific database to dump fixtures from. Defaults to the "default" database.
  -e EXCLUDE, --exclude EXCLUDE
                        An app_label or app_label.ModelName to exclude (use multiple --exclude to exclude multiple apps/models).
  --natural-foreign     Use natural foreign keys if they are available.
  --natural-primary     Use natural primary keys if they are available.
  -a, --all             Use Django's base manager to dump all models stored in the database, including those that would otherwise be filtered or modified by a custom manager.
  --pks PRIMARY_KEYS    Only dump objects with given primary keys. Accepts a comma-separated list of keys. This option only works when you specify one model.
  -o OUTPUT, --output OUTPUT
                        Specifies file to which the output is written.
  --version             show program's version number and exit
  -v {0,1,2,3}, --verbosity {0,1,2,3}
                        Verbosity level; 0=minimal output, 1=normal output, 2=verbose output, 3=very verbose output
  --settings SETTINGS   The Python path to a settings module, e.g. "myproject.settings.main". If this isn't provided, the DJANGO_SETTINGS_MODULE environment variable will be
                        used.
  --pythonpath PYTHONPATH
                        A directory to add to the Python path, e.g. "/home/djangoprojects/myproject".
  --traceback           Raise on CommandError exceptions
  --no-color            Don't colorize the command output.
  --force-color         Force colorization of the command output.

```



- 基础数据库导出

  ```sh
  ./manage.py dumpdata > db.json
  ```

  这会导出整个数据库到 *db.json*

- 备份指定的 *app*

  ```sh
  ./manage.py dumpdata admin > admin.json
  ```

  这会导出 *admin* 应用的内容到 *admin.json* 

- 备份指定的数据表

  ```sh
  ./manage.py dumpdata admin.logentry > logentry.json
  ```

  这会导出 *admin.logentry* 数据表的所有数据

  ```sh
  ./manage.py dumpdata auth.user > user.json
  ```

  这会导出 *auth.user* 数据表的所有数据

- `dumpdata —exclude`

  `—exclude` 选项用来指定无需被导出的 *apps/tables*

  ```sh
  ./manage.py dumpdata --exclude auth.permission > db.json
  ```

   这会导出整个数据库，但不包括 *auth.permisson*

- `dumpdata —intent`

  默认情况，`dumpdata` 的输出会挤在同一行，可读性很差。使用 —indent 可以设定缩进美化输出

  ```sh
  ./manage.py dumpdata auth.user --indent 2 > user.json
  ```

  ```json
  [
  {
    "model": "auth.user",
    "pk": 1,
    "fields": {
      "password": "pbkdf2_sha256$150000$i8oET981EnSJ$d2RCpfY76gFHbwUs1HekSK+pOLYMJFcJ1wFcuyf6R28=",
      "last_login": "2020-04-13T09:21:34.639Z",
      "is_superuser": true,
      "username": "xiao",
      "first_name": "",
      "last_name": "",
      "email": "yuechuan.xiao@artosyn.cn",
      "is_staff": true,
      "is_active": true,
      "date_joined": "2020-04-13T08:59:01.310Z",
      "groups": [],
      "user_permissions": []
    }
  },
  {
    "model": "auth.user",
    "pk": 2,
    "fields": {
      "password": "pbkdf2_sha256$150000$PgBKh5sMAE1y$xdFkYi+gprF1v2rlOyw2OOsRn87zSeTVLJ9dGfoXzIw=",
      "last_login": null,
      "is_superuser": true,
      "username": "qa",
      "first_name": "",
      "last_name": "",
      "email": "qa@artosyn.cn",
      "is_staff": true,
      "is_active": true,
      "date_joined": "2020-04-13T08:59:16.279Z",
      "groups": [],
      "user_permissions": []
    }
  }
  ]
  
  ```

- `dumpdata —format`

  默认输出格式为 *JSON*。使用 `—format` 可以指定输出格式

  - json
  - xml
  - yaml

  ```sh
  ./manage.py dumpdata auth.user --indent 2 --format xml > user.xml
  ```

  这会输出 *xml* 文件

  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <django-objects version="1.0">
    <object model="auth.user" pk="1">
      <field name="password" type="CharField">pbkdf2_sha256$150000$i8oET981EnSJ$d2RCpfY76gFHbwUs1HekSK+pOLYMJFcJ1wFcuyf6R28=</field>
      <field name="last_login" type="DateTimeField">2020-04-13T09:21:34.639297+00:00</field>
      <field name="is_superuser" type="BooleanField">True</field>
      <field name="username" type="CharField">xiao</field>
      <field name="first_name" type="CharField"></field>
      <field name="last_name" type="CharField"></field>
      <field name="email" type="CharField">yuechuan.xiao@artosyn.cn</field>
      <field name="is_staff" type="BooleanField">True</field>
      <field name="is_active" type="BooleanField">True</field>
      <field name="date_joined" type="DateTimeField">2020-04-13T08:59:01.310568+00:00</field>
      <field name="groups" rel="ManyToManyRel" to="auth.group"></field>
      <field name="user_permissions" rel="ManyToManyRel" to="auth.permission"></field>
    </object>
    <object model="auth.user" pk="2">
      <field name="password" type="CharField">pbkdf2_sha256$150000$PgBKh5sMAE1y$xdFkYi+gprF1v2rlOyw2OOsRn87zSeTVLJ9dGfoXzIw=</field>
      <field name="last_login" type="DateTimeField"><None></None></field>
      <field name="is_superuser" type="BooleanField">True</field>
      <field name="username" type="CharField">qa</field>
      <field name="first_name" type="CharField"></field>
      <field name="last_name" type="CharField"></field>
      <field name="email" type="CharField">qa@artosyn.cn</field>
      <field name="is_staff" type="BooleanField">True</field>
      <field name="is_active" type="BooleanField">True</field>
      <field name="date_joined" type="DateTimeField">2020-04-13T08:59:16.279788+00:00</field>
      <field name="groups" rel="ManyToManyRel" to="auth.group"></field>
      <field name="user_permissions" rel="ManyToManyRel" to="auth.permission"></field>
    </object>
  </django-objects>
  ```

  

- `loaddata` 命令

  用来导入 fixtures（dumpdata 导出的数据）到数据库

  ```sh
  ./manage.py loaddata user.json
  ```

  这会导入 user.json 里的内容到数据库

- 恢复 fresh database

  当你通过 dumpdata 命令备份整个数据库时，它将备份所有数据表。若使用 dump 文件导入到另外的 Django 项目，会导致 `IntegrityError`。

  可以通过备份时加入选项 `—exclude` *contenttypes* 和 *auth.permissions* 数据表修复此问题

  ```sh
  ./manage.py dumpdata --exclude auth.permission --exclude contenttypes > db.json
  ```

   现在再用 loaddata 命令导入 fresh dababase

  ```sh
  ./manage.py loaddata db.json
  ```

  