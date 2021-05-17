## **useyourmind** - single page application framework
### Фреймворк для разработки одностраничных веб-приложений

### Структура приложения

##### **/**
Модули приложения:

- **starter.exe** запуск приложения и управления процессами.

- **webserver.exe** веб-сервер.

- **showdata.exe** контроллер сеанса, интерфейс приложения.

- **dataserver.exe** сервер данных (обработка запросов к данным).

- **onesharp.dll** библиотека функций языка 1С.

##### **/doc**
Документация в формате markdown

##### **/data**
Файлы данных пользователей

##### **/os**
Исходный код под OneScript (больше не поддерживается)

##### **/resource**
Файлы веб-интерфейса

##### **/src**
Исходный код проекта в С#

### Для запуска локально на своем компьютере необходимо:

Скачать последнюю версию useyourmind: <https://github.com/vasvl123/useyourmind/releases>

##### Под Windows:

Установить библиотеку .Net версии не ниже 4.5

Перейти в папку useyourmind и выполнить команду: starter.exe

Открыть в браузере ссылку: <http://localhost:8888>

##### Под Linux:

Установить пакет mono-complete не ниже 5.2.

Перейти в папку useyourmind и выполнить команду: mono starter.exe

Открыть в браузере ссылку: <http://localhost:8888>

Запустить в режиме сайта на порту 8080: mono starter.exe site 8080

##### Демонстрация работы фреймворка: <https://onesharp.net/>

### Описание:

Модуль starter.exe запускает процессы webserver.exe, dataserver.exe. Отдельные процессы showdata.exe запускается для каждого пользовательского соединения. Каждый процесс использует отдельный TCP порт для обмена данными.

Веб-сервер (модуль webserver.exe) может запускается в локальном режиме, или в режиме веб-сайта. По умолчанию принимает подключения на порту 8888.

Файл контейнера данных (.sdb) содержит заголовки и файлы данных. Доступ к файлам данных осуществляется через отдельный процесс - сервер данных (dataserver.exe). Сервер обрабатывает запросы ассинхронно, отдавая результаты по мере выполнения запросов.

Файл данных *.sd - это текстовый файл, каждая строка которого хранит один узел DOM. Свойства узлов хранятся в виде пары ключ - значение, разделенные символом табуляции. Код узла соответствует номеру строки в файле. Узел загружается в память в виде структуры, содержащей стандартные свойства: Код, Имя, Значение, и ссылки на другие узлы: Соседний, Дочерний, Атрибут, Старший, Родитель.

Модуль процесса пользователя (showdata.exe) хранит текущее состояние сеанса, производит обработку запросов пользователя, содержит редактор структуры данных. Редактор запускается в отдельном окне из главного меню программы. Для изменения структуры данных нужно выбрать нужный узел и выполнить с ним действия. Узлы можно создавать, удалять, копировать, вырезать и вставлять, изменять имя и значение. Имя узла - его тип - определяет, как он будет обрабатываться внутренним интерпретатором (класс pagedata).

Модуль интерпретатора формирует представление данных для отображения в браузере.
Имя узла опреляет каким образом он будет обработан интерпретатором.
- О (Объект) - имеет структуру свойств и включает в себя другие объекты.
- Ф (Функция) - вызывает функцию из подключаемой библиотеки. Результат выполнения функции отображается как содержимое узла и может быть интерпретирован.
- А (Аргумент) - аргумент функции.  
- О (Оператор) - выполняет действие над вложенными узлами.
- С (Ссылка) - устанавливает связь со свойством объекта.
- З (Значение) - интерпретирует значение свойства объекта.
- Свойство - получает значение свойства ссылки (структуры)
- Атрибут - получает значение атрибута узла.
- Первый, Соседний - передает ссылку на текущий или соседний узел.
- Истина, Ложь, Неопределенно, Пустой, Число, Строка - передает соответствующее значение.
Теги HTML передаются в виде HTML разметки.

Результат (в виде обычного HTML) передается браузеру и загружается в определяемый идентификатором узел DOM страницы. Для работы с DOM используется библиотека JQuery. В качестве шаблона используется CoreUI и BootStrap 4.

Используется библиотека onesharp.net <https://github.com/vasvl123/onesharp.net>
