Перем ВсеДанные, procid, data;
Перем Шаблон;

Функция СкопироватьДанные(Знач Данные)

	Возврат Данные;

КонецФункции


Функция НачальнаяСтраница()
	Перем Ответ;

	Ответ = Шаблон.ПолучитьОбласть("ОбластьШапка", Новый Структура("ПараметрИдПроцесса", procid));
	Ответ = Ответ + Шаблон.ПолучитьОбласть("ОбластьТело", Новый Структура("ПараметрИдПроцесса, ПараметрИдУзла", procid, "316"));

	//Ответ = Ответ + Шаблон.ПолучитьОбласть("ОбластьПриветствие");

	Ответ = Ответ + Шаблон.ПолучитьОбласть("ОбластьПодвал");

	Возврат Ответ;

КонецФункции


Функция СтрокуВСтруктуру(Стр)
	Стр = СтрРазделить(Стр, Символы.Таб);
	Ключ = Неопределено;
	Рез = Неопределено;
	Для Каждого знСтр Из Стр Цикл
		Если Ключ = Неопределено Тогда
			Ключ = знСтр;
		Иначе
			Если Рез = Неопределено Тогда
				Рез = Новый Структура;
			КонецЕсли;
			Рез.Вставить(Ключ, знСтр);
			Ключ = Неопределено;
		КонецЕсли;
	КонецЦикла;
	Возврат Рез;
КонецФункции


Функция СтруктуруВСтроку(Структ)
	Результат = "";
	Для каждого Элемент Из Структ Цикл
		Результат = Результат + ?(Результат = "", "", Символы.Таб) + Элемент.Ключ + Символы.Таб + Элемент.Значение;
	КонецЦикла;
	Возврат Результат;
КонецФункции


Функция ПоказатьУзел(Данные, Запрос, КодУзла = Неопределено, Уровень = "") Экспорт

	ПервыйВызов = (КодУзла = Неопределено);

	Если ПервыйВызов Тогда
		КодУзла = Запрос.nodeid;
	КонецЕсли;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел не найден!";
	КонецЕсли;

	Текст = Символы.ПС + Уровень;

	Если Узел.Имя = "#text" Тогда
		Если Узел.Свойство("Значение") Тогда
			Текст = Текст + Узел.Значение;
		Иначе
			Текст = "";
		КонецЕсли;
	ИначеЕсли Узел.Имя = "#comment" Тогда
		Если Узел.Свойство("Значение") Тогда
			Текст = Текст + "<!-- " + Узел.Значение + " -->";
		КонецЕсли;
	Иначе
		Текст = Текст + "<" + Узел.Имя;

		Атрибут = Неопределено;
		Если Узел.Свойство("Атрибут", Атрибут) Тогда
			Атрибут = Данные.ПолучитьУзел(Атрибут);
			Пока НЕ Атрибут = Неопределено Цикл
				АтрибутИмя = Атрибут.Имя;
				АтрибутИмя = СтрЗаменить(АтрибутИмя, "xml_lang", "xml:lang");
				АтрибутИмя = СтрЗаменить(АтрибутИмя, "_", "-");
				АтрибутЗначение = Атрибут.Значение;
				Текст = Текст + " " + АтрибутИмя + "=""" + АтрибутЗначение + """";
				Если Атрибут.Свойство("Соседний", Атрибут) Тогда
					Атрибут = Данные.ПолучитьУзел(Атрибут)
				КонецЕсли;
		    КонецЦикла;
		КонецЕсли;

		Текст = Текст + ">";
	КонецЕсли;

	Если Узел.Свойство("Дочерний") Тогда
		Текст = Текст + ПоказатьУзел(Данные, Запрос, Узел.Дочерний, Уровень + Символы.Таб);
	КонецЕсли;

	Если НЕ (Узел.Имя = "#text" ИЛИ Узел.Имя = "#comment") Тогда
		Текст = Текст + Символы.ПС + Уровень + "</" + Узел.Имя + ">";
	КонецЕсли;

	Если НЕ ПервыйВызов Тогда
		Если Узел.Свойство("Соседний") Тогда
			Текст = Текст + ПоказатьУзел(Данные, Запрос, Узел.Соседний, Уровень);
		КонецЕсли;
	КонецЕсли;

	Возврат Текст;

КонецФункции // ПоказатьУзел()


Функция ПоказатьСтруктуруУзла(Данные, Запрос, КодУзла = Неопределено) Экспорт

	Если НЕ Запрос.Свойство("cmd") Тогда
		Запрос.Вставить("cmd", "");
	КонецЕсли;

	Представление = "";
	Атрибуты = "";

	ПервыйВызов = (КодУзла = Неопределено);

	Если ПервыйВызов Тогда
		КодУзла = Запрос.nodeid;
	КонецЕсли;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел не найден!";
	КонецЕсли;

	УзелИмя = Узел.Имя;

	Если Узел.Свойство("Атрибут") Тогда
		Атрибуты = ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Атрибут);
	КонецЕсли;

	Если Узел.Свойство("Значение") Тогда
		Если УзелИмя = "#text" ИЛИ УзелИмя = "#comment" Тогда
			УзелИмя = УзелИмя + " = " + Узел.Значение;
		Иначе
			УзелИмя = СтрЗаменить(УзелИмя, "xml_lang", "xml:lang");
			УзелИмя = СтрЗаменить(УзелИмя, "_", "-");
			УзелИмя = УзелИмя + " = " + Узел.Значение;

			Параметры = Новый Структура("ПараметрИдУзла, ПараметрИдПроцесса, ПараметрКоманда, ПараметрНадписьНаКнопке",
				Узел.Код,
				Запрос.procid,
				"propedit",
				УзелИмя);
			Представление = Шаблон.ПолучитьОбласть("ОбластьКнопкаСвойство", Параметры);

			Если Узел.Свойство("Соседний") Тогда
				Представление = Представление + ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Соседний);
			КонецЕсли;

			Возврат Представление;

		КонецЕсли;
	КонецЕсли;

	ДочернийУзел = "";
	Если ПервыйВызов И НЕ Запрос.cmd = "nodeclose" Тогда
		Если Узел.Свойство("Дочерний") Тогда
			ДочернийУзел = ДочернийУзел + ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Дочерний);
		КонецЕсли;
	КонецЕсли;

	ПараметрИмяУзла = Шаблон.ПолучитьОбласть("ОбластьКнопкаУзел",
		Новый Структура("ПараметрИдУзла, ПараметрИдПроцесса, ПараметрКоманда, ПараметрНадписьНаКнопке",
			Узел.Код,
			Запрос.procid,
			?(Запрос.cmd = "nodeopen" И ПервыйВызов, "nodeclose", "nodeopen"),
			?(Запрос.cmd = "nodeopen" И ПервыйВызов, " ⵔ " , " ⵙ "))) +
	Шаблон.ПолучитьОбласть("ОбластьКнопкаИмя",
		Новый Структура("ПараметрИдУзла, ПараметрИдПроцесса, ПараметрКоманда, ПараметрНадписьНаКнопке",
			Узел.Код,
			Запрос.procid,
			"nameedit",
			УзелИмя));

	ПараметрЗаголовокУзла = Шаблон.ПолучитьОбласть("ОбластьЗаголовокУзла",
		Новый Структура("ПараметрИмяУзла, ПараметрСвойстваУзла",
			ПараметрИмяУзла,
			Атрибуты));

	Представление = Шаблон.ПолучитьОбласть("ОбластьУзел",
		Новый Структура("ПараметрИдУзла, ПараметрЗаголовокУзла, ПараметрДочернийУзел",
			Узел.Код,
			ПараметрЗаголовокУзла,
			ДочернийУзел));

	Если НЕ ПервыйВызов И НЕ Запрос.cmd = "nodeclose" Тогда
		Если Узел.Свойство("Соседний") Тогда
				Представление = Представление + ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Соседний);
		КонецЕсли;
	КонецЕсли;

	Возврат Представление;

КонецФункции

Функция ВыполнитьЗадачу(структЗадача)

	Запрос = структЗадача.Запрос;

	Ответ = Неопределено;

	Если Запрос.Свойство("data") Тогда
		data = Запрос.data;
	КонецЕсли;

	Если data = Неопределено Тогда
		Ответ = НачальнаяСтраница();
	Иначе
		Данные = ВсеДанные.Получить(data);
		Если Данные = Неопределено Тогда
			Данные = Новый pagedata("" + data + ".txt", Шаблон);
			ВсеДанные.Вставить("" + data, Данные);
		КонецЕсли;
		Если Запрос.Свойство("mode") Тогда
			Если Запрос.mode = "design" Тогда
				Ответ = ПоказатьСтруктуруУзла(Данные, Запрос);
			КонецЕсли;
		КонецЕсли;
		Если Ответ = Неопределено Тогда
			Ответ = ПоказатьУзел(Данные, Запрос);
		КонецЕсли;
	КонецЕсли;

	структЗадача.Результат = Ответ;

КонецФункции // ВыполнитьЗадачу()

Если АргументыКоманднойСтроки.Количество() Тогда
	procid = АргументыКоманднойСтроки[0];
Иначе
	procid = "1";
КонецЕсли;

Шаблон = ЗагрузитьСценарий(ОбъединитьПути(ТекущийКаталог(), "template.os"));
Шаблон.ЗагрузитьМакет("showdata");

//ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "dbaccess.os"), "dbaccess");
ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "pagedata.os"), "pagedata");

ВсеДанные = Новый Соответствие;

Таймаут = 10;
Хост = "127.0.0.1";
Порт = 8888;
Соединение = Неопределено;

Задачи = Новый Соответствие;
ДанныеСтрокой = "";

Попытка

	Пока Истина Цикл

		Ответ = Неопределено;
		Запрос = " ";

		СтруктЗапрос = Новый Структура("procid", procid);

		Для каждого элЗадача Из Задачи Цикл
			структЗадача = ЭлЗадача.Значение;
			Если структЗадача.Результат = Неопределено Тогда
				ВыполнитьЗадачу(структЗадача);
			КонецЕсли;
			Если Ответ = Неопределено Тогда
				Если НЕ структЗадача.Результат = Неопределено Тогда
					Ответ = структЗадача.Результат;
					СтруктЗапрос.Вставить("taskid", ЭлЗадача.Ключ);
					Прервать;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;

		Попытка
			Соединение = Новый TCPСоединение(Хост, Порт);
			Соединение.ТаймаутОтправки = 100;
			ЗадачиКоличество = Задачи.Количество();
			Если ЗадачиКоличество Тогда
				Соединение.ТаймаутЧтения = 100;
			КонецЕсли;
			Соединение.ОтправитьСтроку(СтруктуруВСтроку(СтруктЗапрос));
			Попытка
				Запрос = Соединение.ПрочитатьСтроку();
			Исключение
				Сообщить("Осталось задач: " + ЗадачиКоличество);
				Продолжить;
			КонецПопытки;
			Если НЕ Ответ = Неопределено Тогда
				Соединение.ОтправитьСтроку(Ответ);
				Задачи.Удалить(СтруктЗапрос.taskid);
			КонецЕсли;
			Соединение.Закрыть();
		Исключение
			Сообщить(ОписаниеОшибки());
			Прервать;
		КонецПопытки;

		Если Запрос = " " Тогда
			Продолжить;
		КонецЕсли;

		Попытка
			Запрос = СтрокуВСтруктуру(Запрос);
			структЗадача = Новый Структура("Запрос, Результат", Запрос);
			Задачи.Вставить(Запрос.taskid, структЗадача);
		Исключение
			Сообщить("Неверный запрос " + Запрос);
			Продолжить;
		КонецПопытки;

	КонецЦикла;

Исключение

	Сообщить(ОписаниеОшибки());

КонецПопытки;
