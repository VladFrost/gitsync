# Подробное описание использования команды <init>

init (синоним i) - инициализация нового хранилища git и наполнение его данными из хранилища 1С

> Подробную справку по параметрам см. gitsync init --help

### Справка по использованию команды:
```
Команда: init, i
 Инициализация структуры нового хранилища git. Подготовка к синхронизации

Строка запуска: gitsync init [OPTIONS] PATH [WORKDIR]

Аргументы:
  PATH          Путь к хранилищу конфигурации 1С. (env $GITSYNC_STORAGE_PATH)
  WORKDIR       Адрес локального репозитория GIT или каталог исходников внутри локальной копии git-репозитария. По умолчанию текущий каталог (env $GITSYNC_WORKDIR)

Параметры:
  -u, --storage-user    пользователь хранилища конфигурации (env $GITSYNC_STORAGE_USER) (по умолчанию Администратор)
  -p, --storage-pwd     пароль пользователя хранилища конфигурации (env $GITSYNC_STORAGE_PASSWORD, $GITSYNC_STORAGE_PWD)
```

### Переменные окружения:

| Имя                        | Описание                                   |
|----------------------------|--------------------------------------------|
| `GITSYNC_WORKDIR`          | рабочий каталог для команды                |
| `GITSYNC_STORAGE_PATH`     | путь к хранилищу конфигурации 1С.          |
| `GITSYNC_STORAGE_USER`     | пользователь хранилища конфигурации        |
| `GITSYNC_STORAGE_PASSWORD` | пароль пользователя хранилища конфигурации |

### Значения по умолчанию:
|                    |                              |
|--------------------|------------------------------|
| WORKDIR            | текущая рабочая директория   |
| -u, --storage-user | пользователь `Администратор` |
 
## Примеры, использования:

* Простое использование

    `gitsync init C:/Хранилище_1С/ C:/GIT/src`

    Данная команда создаст новый репозиторий git в каталоге `C:/GIT/src` из хранилища 1С по пути `C:/Хранилище_1С/`
  
* Инциализация в текущем рабочем каталоге, 

    > переменная окружения **`GITSYNC_WORKDIR`** не должна быть задана

    ```
    cd C:/work_dir/
    gitsync init C:/Хранилище_1С/
    ```
    Данная команда создаст новый репозиторий git в каталоге `C:/work_dir/` из хранилища 1С по пути `C:/Хранилище_1С/`