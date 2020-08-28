---
title: Django 项目后端模板
toc: true
comments: true
tags:
  - web
  - django
slug: django-project-backend-template
categories:
  - Web
date: 2020-02-16 14:55:49
---

![django-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/django-logo.png)

> Django 项目本身可以通过 `django-admin` 或者直接运行 `python manage.py ARGS` 来进行脚手架生成。但是生成的项目框架层次不算太好。

首先生成一个 Django 项目：

```bash
django-admin startproject backend
```

生成的项目框架如下：

```bash
backend
├── backend
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
└── manage.py

```

其中的两个 `backend` 分别表示项目，以及 app 全局配置

建立文件夹 `apps` 用来放置应用，把内层 `backend` 改为 `conf`

```sh
backend
├── apps
├── conf
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
└── manage.py
```

注意这里需要配置以下几个文件：

```python
# manage.py 
...
# os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'conf.settings')
...
```

```python
# settings.py
...
# ROOT_URLCONF = 'backend.urls'
ROOT_URLCONF = 'conf.urls'
...
# WSGI_APPLICATION = 'backend.wsgi.application'
WSGI_APPLICATION = 'conf.wsgi.application'
...
```

现在可以测试 `python manage.py runserver` 是否可以起来。

接下来新建 Apps

```shell
mkdir apps/login
python manage.py startapp login apps/login
```

注册 app 

```python
# settings.py

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': ['apps'], # 添加 apps 文件夹
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]


INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'apps.login',
]
```

导入 URL

```python
...
from apps.login import urls as login_urls

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', include(login_urls)),
]
```

现在一个基本的项目结构就建立好了。

```sh
backend
├── apps
│   └── login
│       ├── __init__.py
│       ├── admin.py
│       ├── apps.py
│       ├── migrations
│       │   └── __init__.py
│       ├── models.py
│       ├── tests.py
│       └── views.py
├── conf
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── db.sqlite3
└── manage.py
```

相比起来层次更清晰，而且也更适合用作前后端分离的命名

