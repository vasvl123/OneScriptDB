// MIT License
// Copyright (c) 2020 vasvl123
// https://github.com/vasvl123/useyourmind
//
// контроллер статичных html страниц

Перем procid Экспорт;
Перем Шаблон;
Перем Параметры;
Перем Задачи;
Перем ВсеДанные Экспорт;
Перем ИмяДанных;
Перем ОстановитьСервер;
Перем ПараметрХост;
Перем Команда;
Перем МоментЗапуска;


Функция ПолучитьИД()
	МоментЗапуска = МоментЗапуска - 1;
	Возврат Цел(ТекущаяУниверсальнаяДатаВМиллисекундах() - МоментЗапуска);
КонецФункции // ПолучитьИД()


Функция УзелСвойство(Узел, Свойство) Экспорт
	УзелСвойство = Неопределено;
	Если НЕ Узел = Неопределено Тогда
		Узел.Свойство(Свойство, УзелСвойство);
	КонецЕсли;
	Возврат УзелСвойство;
КонецФункции // УзелСвойство(Узел)


Функция СтруктуруВДвоичныеДанные(знСтруктура)
	Результат = Новый Массив;
	Если НЕ знСтруктура = Неопределено Тогда
		Для каждого Элемент Из знСтруктура Цикл
			Ключ = Элемент.Ключ;
			Значение = Элемент.Значение;
			Если ТипЗнч(Значение) = Тип("Структура") Тогда
				Ключ = "*" + Ключ;
				дЗначение = СтруктуруВДвоичныеДанные(Значение);
			ИначеЕсли ТипЗнч(Значение) = Тип("ДвоичныеДанные") Тогда
				Ключ = "#" + Ключ;
				дЗначение = Значение;
			Иначе
				дЗначение = ПолучитьДвоичныеДанныеИзСтроки(Значение);
			КонецЕсли;
			дКлюч = ПолучитьДвоичныеДанныеИзСтроки(Ключ);
			рдКлюч = дКлюч.Размер();
			рдЗначение = дЗначение.Размер();
			бРезультат = Новый БуферДвоичныхДанных(6);
			бРезультат.ЗаписатьЦелое16(0, рдКлюч);
			бРезультат.ЗаписатьЦелое32(2, рдЗначение);
			Результат.Добавить(ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(бРезультат));
			Результат.Добавить(дКлюч);
			Результат.Добавить(дЗначение);
		КонецЦикла;
	КонецЕсли;
	Возврат СоединитьДвоичныеДанные(Результат);
КонецФункции


Функция ДвоичныеДанныеВСтруктуру(Данные, Рекурсия = Истина)
	Если ТипЗнч(Данные) = Тип("ДвоичныеДанные") Тогда
		рдДанные = Данные.Размер();
		Если рдДанные = 0 Тогда
			Возврат Неопределено;
		КонецЕсли;
		бдДанные = ПолучитьБуферДвоичныхДанныхИзДвоичныхДанных(Данные);
	ИначеЕсли ТипЗнч(Данные) = Тип("БуферДвоичныхДанных") Тогда
		рдДанные = Данные.Размер;
		бдДанные = Данные;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	Позиция = 0;
	знСтруктура = Новый Структура;
	Пока Позиция < рдДанные - 1 Цикл
		рдКлюч = бдДанные.ПрочитатьЦелое16(Позиция);
		рдЗначение = бдДанные.ПрочитатьЦелое32(Позиция + 2);
		Если рдКлюч + рдЗначение > рдДанные Тогда // Это не структура
			Возврат Неопределено;
		КонецЕсли;
		Ключ = ПолучитьСтрокуИзДвоичныхДанных(ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(бдДанные.Прочитать(Позиция + 6, рдКлюч)));
		бЗначение = бдДанные.Прочитать(Позиция + 6 + рдКлюч, рдЗначение);
		Позиция = Позиция + 6 + рдКлюч + рдЗначение;
		Л = Лев(Ключ, 1);
		Если Л = "*" Тогда
			Если НЕ Рекурсия Тогда
				Продолжить;
			КонецЕсли;
			Ключ = Сред(Ключ, 2);
			Значение = ДвоичныеДанныеВСтруктуру(бЗначение);
		ИначеЕсли Л = "#" Тогда
			Ключ = Сред(Ключ, 2);
			Значение = ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(бЗначение);
		Иначе
			Значение = ПолучитьСтрокуИзДвоичныхДанных(ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(бЗначение));
		КонецЕсли;
		знСтруктура.Вставить(Ключ, Значение);
	КонецЦикла;
	Возврат знСтруктура;
КонецФункции


Функция ПоказатьСтраницу(ТекстСтраницы, Заголовок)
	Текст = СтрЗаменить(Шаблон, ".ПараметрХост", ПараметрХост);
	Текст = СтрЗаменить(Текст, ".ПараметрЗаголовокСтраницы", Заголовок);
	Текст = СтрЗаменить(Текст, ".ПараметрТекстСтраницы", ТекстСтраницы);
	Возврат Текст;
КонецФункции


Функция ПолучитьДанные(структЗадача)
	БазаДанных = "" + УзелСвойство(структЗадача.Запрос, "sdb");
	ИмяДанных = "" + УзелСвойство(структЗадача.Запрос, "data");
	ПозицияДанных = "" + УзелСвойство(структЗадача.Запрос, "datapos");
	Если ИмяДанных = "" Тогда
		ИмяДанных = "start";
	КонецЕсли;
	ПутьДанные = ИмяДанных;
	Данные = ВсеДанные.Получить(ПутьДанные);
	Если Данные = "НетДанных" Тогда
		Возврат Неопределено;
	ИначеЕсли Данные = Неопределено Тогда
		Если НЕ ПозицияДанных = "" ИЛИ НЕ ИмяДанных = "" ИЛИ БазаДанных = "" Тогда // запросить данные с сервера
			ЗадачаПараметры = Новый Структура("БазаДанных, ИмяДанных, ПозицияДанных, cmd", БазаДанных, ИмяДанных, ПозицияДанных, "ПолучитьДанные");
			НоваяЗадача(ЗадачаПараметры, "Служебный", структЗадача);
			ВсеДанные.Вставить(ПутьДанные, "НетДанных");
		КонецЕсли;
	КонецЕсли;
	Возврат Данные;
КонецФункции


Функция ПередатьДанные(Хост, Порт, стрДанные) Экспорт
	КоличествоПопыток = 0;
	стрДанные.Вставить("ИдПроцесса", procid);
	Пока КоличествоПопыток < 10 Цикл
		Попытка
			Приостановить(КоличествоПопыток);
			Соединение = Новый TCPСоединение(Хост, Порт);
			Соединение.ТаймаутОтправки = 50;
			Соединение.ОтправитьДвоичныеДанные(СтруктуруВДвоичныеДанные(стрДанные));
			Соединение.Закрыть();
			Возврат Истина;
		Исключение
			КоличествоПопыток = КоличествоПопыток + 1;
			Если НЕ Соединение = Неопределено Тогда
				Соединение.Закрыть();
			КонецЕсли;
			Если КоличествоПопыток = 10 Тогда
				Сообщить("Ошибка отправки: " + Хост + ":" + Порт);
			КонецЕсли;
		КонецПопытки;
	КонецЦикла;
	Возврат Ложь;
КонецФункции // ПередатьДанные()


Функция НоваяЗадача(Запрос, Тип = "Запрос", ЗадачаВладелец = Неопределено) Экспорт
	Перем ИдЗадачи;
	Если Запрос.Свойство("ИдЗадачи", ИдЗадачи) Тогда
		Задача = Задачи.Получить(ИдЗадачи);
		Если НЕ Задача = Неопределено Тогда
			Если Запрос.Свойство("РезультатДанные") Тогда
				//Сообщить("РезультатДанные задача=" + Задача.ИдЗадачи + " " + УзелСвойство(Задача.Запрос, "cmd") + " время=" + (ТекущаяУниверсальнаяДатаВМиллисекундах() - Задача.ВремяНачало));
				Задача.Этап = "ВыполнитьЗадачу";
				Задача.Запрос.Вставить("РезультатДанные", Запрос.РезультатДанные);
			КонецЕсли;
		Иначе
			Сообщить("Задача не найдена ИдЗадачи=" + ИдЗадачи);
		КонецЕсли;
	Иначе
		Если НЕ Запрос.Свойство("taskid", ИдЗадачи) Тогда
			ИдЗадачи = "" + ПолучитьИД();
		КонецЕсли;
		структЗадача = Новый Структура("ИдЗадачи, Тип, Этап, Запрос, Действие, Результат, ВремяНачало, ЗадачаВладелец", ИдЗадачи, Тип, "ВыполнитьЗадачу", Запрос, Неопределено, "", ТекущаяУниверсальнаяДатаВМиллисекундах(), ЗадачаВладелец);
		Сообщить("Новая задача " + Тип + "=" + структЗадача.ИдЗадачи + " " + УзелСвойство(структЗадача.Запрос, "cmd"));
		Задачи.Вставить(структЗадача.ИдЗадачи, структЗадача);
	КонецЕсли;
КонецФункции


Функция ЗапросВыполнитьЗадачу(структЗадача)

	//Сообщить(структЗадача.Этап + "=" + структЗадача.ИдЗадачи + " " + УзелСвойство(структЗадача.Запрос, "cmd") + " время=" + (ТекущаяУниверсальнаяДатаВМиллисекундах() - структЗадача.ВремяНачало));

	Если структЗадача.Этап = "ВыполнитьЗадачу" Тогда

		Действие = УзелСвойство(структЗадача.Запрос, "cmd");

		Если Действие = "ПолучитьДанные" Тогда // загрузить данные с дата-сервера

			Запрос = структЗадача.Запрос;
			Если НЕ Запрос.Свойство("РезультатДанные") Тогда
				Если НЕ СтрРазделить(Запрос.ИмяДанных, "/.").Количество() = 1 Тогда // не файл
					Сообщить(структЗадача.Запрос.ИмяДанных);
					Запрос.Вставить("РезультатДанные", Новый Структура("Ответ", "НетФайла"));
				Иначе
					стрЗапрос = Новый Структура("БазаДанных, ИмяДанных, ПозицияДанных, Команда", "", Запрос.ИмяДанных, "", "ПолучитьДанные");
					стрЗапрос.Вставить("ОбратныйЗапрос", Новый Структура("ИдЗадачи", структЗадача.ИдЗадачи));
					Если ПередатьДанные(Параметры.Хост, Параметры.ПортД, стрЗапрос) Тогда
						Запрос.Вставить("РезультатДанные", Неопределено); // теперь ждем ответа
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;

			Если НЕ Запрос.РезультатДанные = Неопределено Тогда // получен ответ дата-сервера
				//Сообщить(Запрос.РезультатДанные.Ответ);
				Если Запрос.РезультатДанные.Ответ = "НетФайла" Тогда
					// искать в public
					стрЗапрос = Новый Структура("БазаДанных, ИмяДанных, ПозицияДанных, Команда", "public", Запрос.ИмяДанных, "", "ПолучитьДанные");
					стрЗапрос.Вставить("ОбратныйЗапрос", Новый Структура("ИдЗадачи", структЗадача.ИдЗадачи));
					Если ПередатьДанные(Параметры.Хост, Параметры.ПортД, стрЗапрос) Тогда
						Запрос.Вставить("РезультатДанные", Неопределено); // теперь ждем ответа
					КонецЕсли;
				Иначе
					Если Запрос.РезультатДанные.Ответ = "Успешно" Тогда
						Текст = ПолучитьСтрокуИзДвоичныхДанных(Запрос.РезультатДанные.Результат.Данные);
						Данные = Новый pagedata(ЭтотОбъект, Текст, Запрос.БазаДанных, Запрос.ИмяДанных, Запрос.ПозицияДанных);
						ПутьДанные = Запрос.ИмяДанных;
						ВсеДанные.Вставить(ПутьДанные, Данные);
					Иначе // страница не найдена
						ПутьДанные = Запрос.ИмяДанных;
						ВсеДанные.Удалить(ПутьДанные);
						структЗадача.ЗадачаВладелец.Результат = "404";
						структЗадача.ЗадачаВладелец.Этап = "ЕстьРезультат";
					КонецЕсли;
					структЗадача.Этап = "УдалитьЗадачу";
				КонецЕсли;
			КонецЕсли;

		ИначеЕсли Действие = Команда["УстановитьПараметры"] Тогда
			УстановитьПараметры(структЗадача.Запрос);
			структЗадача.Этап = "УдалитьЗадачу";

		ИначеЕсли Действие = Команда["ЗавершитьПроцесс"] Тогда
			Сообщить("Получена команда на завершение.");
			ОстановитьСервер = Истина;

		Иначе

			Данные = ПолучитьДанные(структЗадача);
			Если НЕ Данные = Неопределено Тогда
				Результат = Данные.ОбновитьПредставление(Данные.Корень);
				Заголовок = "Разумное проектирование";
				Если НЕ Данные.ИмяДанных = "start" Тогда
					Заголовок = Данные.ИмяДанных + " - " + Заголовок;
				КонецЕсли;
				Если Данные.Корень.Свойство("Свойства") Тогда
					Если Данные.Корень.Свойства.д.Свойство("Заголовок") Тогда
						Заголовок = Данные.Корень.Свойства.д.Заголовок.Значение;
					КонецЕсли;
				КонецЕсли;
				структЗадача.Результат = ПоказатьСтраницу(Результат, Заголовок);
				структЗадача.Этап = "ЕстьРезультат";
			КонецЕсли;
		КонецЕсли;

	КонецЕсли;

	Если структЗадача.Этап = "ЕстьРезультат" Тогда
		Если ПередатьДанные(Параметры.Хост, Параметры.ПортВ, Новый Структура("procid, taskid, Результат", procid, структЗадача.Запрос.taskid, структЗадача.Результат)) Тогда
			структЗадача.Этап = "УдалитьЗадачу";
		КонецЕсли;
	КонецЕсли;

КонецФункции // ЗапросВыполнитьЗадачу()


Функция УстановитьПараметры(знПараметры)
	Параметры = знПараметры;
	procid = Параметры.procid;
	ПараметрХост = Параметры.ПараметрХост;
	ПередатьДанные(Параметры.Хост, Параметры.ПортВ, Параметры); // регистрация на веб-сервере
	ПередатьДанные(Параметры.Хост, Параметры.ПортД, Параметры); // регистрация на дата-сервере
	Сообщить("webdata procid = " + procid);
КонецФункции // УстановитьПараметры()


Процедура ОбработатьСоединения()

	Порт = АргументыКоманднойСтроки[0];

	ИмяФайла = ОбъединитьПути(ТекущийКаталог(), "resource", "webdata.html");
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	Шаблон = Чтение.Прочитать();
	Чтение.Закрыть();

	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "pagedata.os"), "pagedata");

	ВсеДанные = Новый Соответствие;

	TCPСервер = Новый TCPСервер(Порт);
	TCPСервер.Запустить();
	Сообщить("Контроллер webdata запущен на порту: " + Порт);

	Задачи = Новый Соответствие;

	ОстановитьСервер = Ложь;

	ВремяНачало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	НачалоЦикла = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Пока Истина Цикл

		ВремяЦикла = ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоЦикла;
		Если ВремяЦикла > 100 Тогда
			Сообщить("! ВремяЦикла=" + ВремяЦикла);
		КонецЕсли;
		НачалоЦикла = ТекущаяУниверсальнаяДатаВМиллисекундах();

		Если Задачи.Количество() Тогда
			ПереченьЗадач = Новый Массив;
			Для каждого элЗадача Из Задачи Цикл
				ПереченьЗадач.Добавить(ЭлЗадача.Значение);
			КонецЦикла;
			Для каждого структЗадача Из ПереченьЗадач Цикл
				Если структЗадача.Этап = "УдалитьЗадачу" Тогда
					Сообщить("Завершил задачу=" + структЗадача.ИдЗадачи + " " + УзелСвойство(структЗадача.Запрос, "cmd") + " время=" + (ТекущаяУниверсальнаяДатаВМиллисекундах() - структЗадача.ВремяНачало));
					Задачи.Удалить(структЗадача.ИдЗадачи);
					Продолжить;
				КонецЕсли;
				Попытка
					ЗапросВыполнитьЗадачу(структЗадача);
				Исключение
					Сообщить(ОписаниеОшибки());
					структЗадача.Этап = "УдалитьЗадачу";
				КонецПопытки;
			КонецЦикла;
		КонецЕсли;

		Если ОстановитьСервер Тогда
			Прервать;
		КонецЕсли;

		Соединение = Неопределено;
		ПустойЦикл = 0;
		Таймаут = 10;

		// Если НЕ Задачи.Количество() Тогда
		// 	Таймаут = 0;
		// КонецЕсли;

		Соединение = TCPСервер.ОжидатьСоединения(Таймаут);

		Если НЕ Соединение = Неопределено Тогда

			Соединение.ТаймаутОтправки = 50;
			Соединение.ТаймаутЧтения = 50;

			Попытка
				Запрос = Неопределено;
				Запрос = ДвоичныеДанныеВСтруктуру(Соединение.ПрочитатьДвоичныеДанные());
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;

			Если НЕ Соединение = Неопределено Тогда
				Соединение.Закрыть();
			КонецЕсли;

			Если НЕ Запрос = Неопределено Тогда
				ВремяНачало = ТекущаяУниверсальнаяДатаВМиллисекундах();
				НоваяЗадача(Запрос);
			КонецЕсли;

		Иначе
			ПустойЦикл = ПустойЦикл + 1;
		КонецЕсли;

	КонецЦикла;

	TCPСервер.Остановить();
	// оповещение о завершении
	ПередатьДанные(Параметры.Хост, Параметры.ПортВ, Новый Структура("procid, cmd", procid, "termproc"));
	ПередатьДанные(Параметры.Хост, Параметры.ПортД, Новый Структура("procid, cmd", procid, "termproc"));
	ПередатьДанные(Параметры.Хост, Параметры.ПортС, Новый Структура("procid, cmd", procid, "termproc"));
	Сообщить("Процесс webdata procid=" + procid + " завершен.");

КонецПроцедуры

МоментЗапуска = ТекущаяУниверсальнаяДатаВМиллисекундах();

Команда = Новый Соответствие;

Команда.Вставить("УстановитьПараметры", "init");
Команда.Вставить("ЗавершитьПроцесс", "termproc");

Если АргументыКоманднойСтроки.Количество() Тогда
	ОбработатьСоединения();
КонецЕсли;
