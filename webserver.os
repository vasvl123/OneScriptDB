// /*----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------*/
// Включает программный код https://github.com/nextkmv/vServer


Перем Порт;
Перем ОстановитьСервер;
Перем СтатусыHTTP;
Перем СоответствиеРасширенийТипамMIME;
Перем Задачи, мЗадачи;
Перем Ресурсы;
Перем Контроллеры;
Перем Загрузка;
Перем Параметры;
Перем МоментЗапуска;
Перем Сообщения;
Перем Соединения;
Перем СоединенияО;


Функция ПолучитьИД()
	МоментЗапуска = МоментЗапуска - 1;
	Возврат Цел(ТекущаяУниверсальнаяДатаВМиллисекундах() - МоментЗапуска);
КонецФункции // ПолучитьИД()


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


Функция ПередатьДанные(Хост, Порт, стрДанные) Экспорт
	Попытка
		Соединение = Новый TCPСоединение(Хост, Порт);
		Соединение.ТаймаутОтправки = 5000;
		Соединение.ОтправитьДвоичныеДанныеАсинхронно(СтруктуруВДвоичныеДанные(стрДанные));
		Возврат Соединение;
	Исключение
		Сообщить(ОписаниеОшибки());
		Если Соединение = Неопределено Тогда
			Сообщить("webserver: Хост недоступен: " + Хост + ":" + Порт);
		Иначе
			Соединение.Закрыть();
			Соединение = Неопределено;
		КонецЕсли;
	КонецПопытки;
	Возврат Соединение;
КонецФункции // ПередатьДанные()


Функция УдаленныйУзелАдрес(УдаленныйУзел)
	Возврат Лев(УдаленныйУзел, Найти(УдаленныйУзел, ":") - 1);
КонецФункции


// Разбирает вошедший запрос и возвращает структуру запроса
Функция РазобратьЗапросКлиента(ТекстЗапроса)

	Перем ИмяКонтроллера;
	Перем ИмяМетода;
	Перем ПараметрыМетода;

	Заголовок = Новый Соответствие();

	мТекстовыеДанные = ТекстЗапроса;
	Разделитель = "";
	Пока Истина Цикл
		П = Найти(мТекстовыеДанные, Символы.ПС);
		Если П = 0 Тогда
			Прервать;
		КонецЕсли;
		Подстрока = Лев(мТекстовыеДанные, П);
		мТекстовыеДанные = Прав(мТекстовыеДанные, СтрДлина(мТекстовыеДанные) - П);
		// Разбираем ключ значение
		Если Найти(Подстрока,"HTTP/1") > 0 Тогда
			// Это строка протокола
			// Определим метод
			П1 = 0;
			Метод = Неопределено;
			Если Лев(Подстрока, 3) = "GET" Тогда
				Метод ="GET";
				П1 = 3;
			ИначеЕсли Лев(Подстрока, 4) = "POST" Тогда
				Метод ="POST";
				П1 = 4;
			ИначеЕсли Лев(Подстрока, 3) = "PUT" Тогда
				Метод = "PUT";
				П1 = 3;
			ИначеЕсли Лев(Подстрока, 6) = "DELETE" Тогда
				Метод ="DELETE";
				П1 = 6;
			КонецЕсли;
			Заголовок.Вставить("Method", Метод);
			// Определим Путь
			П2 = Найти(Подстрока,"HTTP/1");
			Путь = СокрЛП(Сред(Подстрока,П1+1,СтрДлина(Подстрока)-10-П1));
			Заголовок.Вставить("Path", Путь);
		Иначе
			Если Подстрока = Символы.ВК + Символы.ПС Тогда
				Прервать;
			ИначеЕсли Найти(Подстрока,":") > 0 Тогда
				П3 = Найти(Подстрока,":");
				Ключ 		= СокрЛП(Лев(Подстрока,П3-1));
				Значение	= СокрЛП(Прав(Подстрока,СтрДлина(Подстрока)-П3));
				Заголовок.Вставить(Ключ, Значение);
				Если Ключ = "Content-Type" Тогда
					Если Лев(Значение, 20) = "multipart/form-data;" Тогда
						Разделитель = "--" + Сред(Значение, 31);
					КонецЕсли;
				КонецЕсли;
			Иначе
				Ключ 		= "unknown";
				Значение	= СокрЛП(Подстрока);
				Если СтрДлина(Значение) > 0 Тогда
					Заголовок.Вставить(Ключ, Значение);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Если Метод ="POST" Тогда
		Содержимое = Заголовок.Получить("Content-Type");
		Если Содержимое = "text/plain;charset=UTF-8" Тогда // параметры строкой
			// Получим данные запроса
			ПД = Найти(мТекстовыеДанные,Символы.ВК+Символы.ПС+Символы.ВК+Символы.ПС);
			POSTДанные = Сред(мТекстовыеДанные,ПД,СтрДлина(мТекстовыеДанные)-ПД);
			// Разбираем данные пост
			Если СтрДлина(POSTДанные) > 0 Тогда
				POSTДанные = POSTДанные + "&";
			КонецЕсли;
			Заголовок.Вставить("POSTДанные", POSTДанные);
			POSTСтруктура = Новый Структура();
			Пока Найти(POSTДанные, "&") > 0 Цикл
				П1 = Найти(POSTДанные, "&");
				П2 = Найти(POSTДанные, "=");
				Ключ = Лев(POSTДанные, П2-1);
				Значение = Сред(POSTДанные, П2+1, П1-(П2+1));
				POSTДанные = Прав(POSTДанные, СтрДлина(POSTДанные)-П1);
				Если НЕ Ключ = "" Тогда
					POSTСтруктура.Вставить(Ключ, РаскодироватьСтроку(Значение, СпособКодированияСтроки.КодировкаURL));
				КонецЕсли;
			КонецЦикла;
			Заголовок.Вставить("POSTData", POSTСтруктура);
		ИначеЕсли Лев(Содержимое, 20) = "multipart/form-data;" Тогда // параметры формы
			POSTСтруктура = Новый Структура();
			Пока Истина Цикл
				П = Найти(мТекстовыеДанные, Разделитель);
				Если П = 0 Тогда
					Прервать;
				КонецЕсли;
				Подстрока = Лев(мТекстовыеДанные, П);
				мТекстовыеДанные = Прав(мТекстовыеДанные, СтрДлина(мТекстовыеДанные) - П - СтрДлина(Разделитель) - 1);
				Если Найти(Подстрока, "Content-Disposition: form-data;") Тогда
					П1 = Найти(Подстрока, "name=");
					П2 = Найти(Подстрока, Символы.ПС);
					П3 = Найти(Подстрока, Символы.ВК + Символы.ПС + Символы.ВК + Символы.ПС);
					П4 = Найти(Подстрока, "; filename");
					Если НЕ П4 = 0 Тогда
						Значение = ПолучитьДвоичныеДанныеИзСтроки(Сред(Подстрока, П3 + 4, СтрДлина(Подстрока) - П3 - 6), "windows-1251");
						POSTСтруктура.Вставить("filename", РаскодироватьСтроку(Сред(Подстрока, П4 + 12, П2 - П4 - 14), СпособКодированияСтроки.КодировкаURL));
						Ключ = Сред(Подстрока, П1 + 6, П4 - П1 - 7);
					Иначе
						Ключ = Сред(Подстрока, П1 + 6, П2 - П1 - 8);
						Значение = РаскодироватьСтроку(Сред(Подстрока, П2 + 3, СтрДлина(Подстрока) - П2 - 5), СпособКодированияСтроки.КодировкаURL);
					КонецЕсли;
					Если НЕ Ключ = "" Тогда
						POSTСтруктура.Вставить(Ключ, Значение);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			Заголовок.Вставить("POSTData", POSTСтруктура);
		КонецЕсли;
	КонецЕсли;

	//ЛогСообщить(ПД);
	// Разбор пути на имена контроллеров
	Путь = СокрЛП(Заголовок.Получить("Path"));
	// ПараметрыМетода = Новый Массив();
	Если Не Путь = Неопределено Тогда
		Если Лев(Путь,1) = "/" Тогда
			Путь = Прав(Путь, СтрДлина(Путь)-1);
		КонецЕсли;
		Если Прав(Путь,1) <> "/" Тогда
			Путь = Путь+"/";
		КонецЕсли;
		Сч = 0;
		Пока Найти(Путь,"/") > 0 Цикл
			П = Найти(Путь,"/");
			Сч = Сч + 1;
			ЗначениеПараметра = РаскодироватьСтроку(Лев(Путь,П-1), СпособКодированияСтроки.КодировкаURL);
			Путь = Прав(Путь, СтрДлина(Путь)-П);
			Если Сч = 1 Тогда
				ИмяКонтроллера = ЗначениеПараметра;
			ИначеЕсли Сч = 2 Тогда
				ИмяМетода = ЗначениеПараметра;
			ИначеЕсли НЕ ЗначениеПараметра = ".." Тогда
				ИмяМетода = ОбъединитьПути(ИмяМетода, ЗначениеПараметра);
			КонецЕсли;
		КонецЦикла;
		GETСтруктура = Новый Структура();
		Если НЕ СокрЛП(ИмяМетода) = "" Тогда
			Если Найти(ИмяМетода, "?") Тогда
				GETДанные = ИмяМетода;
				ИмяМетода = Лев(GETДанные, Найти(GETДанные, "?") - 1);
				GETДанные = СтрЗаменить(GETДанные, ИмяМетода + "?", "") + "&";
				// Разбираем данные гет
				Пока Найти(GETДанные, "&") > 0 Цикл
					П1 = Найти(GETДанные, "&");
					П2 = Найти(GETДанные, "=");
					Ключ = Лев(GETДанные, П2-1);
					Значение = Сред(GETДанные, П2 + 1, П1 - (П2 + 1));
					GETДанные = Прав(GETДанные, СтрДлина(GETДанные) - П1);
					Если НЕ Ключ = "" Тогда
						GETСтруктура.Вставить(Ключ, РаскодироватьСтроку(Значение, СпособКодированияСтроки.КодировкаURL));
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Заголовок.Вставить("GETData", GETСтруктура);

	Запрос = Новый Структура;
	Запрос.Вставить("Заголовок", Заголовок);
	Запрос.Вставить("ИмяКонтроллера", "" + ИмяКонтроллера);
	Запрос.Вставить("ИмяМетода", "" + ИмяМетода);
	// Запрос.Вставить("ПараметрыМетода", ПараметрыМетода);

	Возврат Запрос;

КонецФункции


Функция ОбработатьЗапросКлиента(Запрос, Знач Соединение)

	Метод = Запрос.Заголовок.Получить("Method");

	Если НЕ Метод = Неопределено Тогда

		ПараметрыЗапроса = Запрос.Заголовок.Получить(Метод + "Data");

		Если ПараметрыЗапроса = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;

		Задача = Новый Структура;
		ИдЗадачи = ПолучитьИД();
		Задачи.Вставить("" + ИдЗадачи, Задача);
		мЗадачи.Вставить(0, Задача);
		Задача.Вставить("ИдЗадачи", "" + ИдЗадачи);
		Задача.Вставить("структКонтроллер", Неопределено);
		Задача.Вставить("ВремяНачало", ТекущаяУниверсальнаяДатаВМиллисекундах());
		Задача.Вставить("Соединение", Соединение);
		Задача.Вставить("ИдКонтроллера", Неопределено);
		Задача.Вставить("Результат", Неопределено);
		Задача.Вставить("Этап", "Новая");
		Задача.Вставить("УдаленныйУзел", УдаленныйУзелАдрес(Соединение.УдаленныйУзел));
		ПараметрыЗапроса.Вставить("УдаленныйУзел", Задача.УдаленныйУзел);
		ПараметрыЗапроса.Вставить("ИмяМетода", Запрос.ИмяМетода);
		ПараметрыЗапроса.Вставить("ИмяКонтроллера", Запрос.ИмяКонтроллера);
		Задача.Вставить("ПараметрыЗапроса", ПараметрыЗапроса);

		Если Запрос.ИмяКонтроллера = "resource" Тогда // запрос к файлам сервера

			Задача.Вставить("ИмяДанных", ОбъединитьПути(Запрос.ИмяКонтроллера, Запрос.ИмяМетода));
			Задача.Вставить("Результат", "Файл");
			Задача.Этап = "Обработка";

		ИначеЕсли Запрос.ИмяКонтроллера = "favicon.ico" ИЛИ Запрос.ИмяКонтроллера = "robots.txt" Тогда // запрос к файлам сервера

			Задача.Вставить("ИмяДанных", ОбъединитьПути("resource", Запрос.ИмяКонтроллера));
			Задача.Вставить("Результат", "Файл");
			Задача.Этап = "Обработка";

		КонецЕсли;

		ЛогСообщить(Задача.УдаленныйУзел + " -> taskid=" + Задача.ИдЗадачи + " " + СокрЛП(Запрос.Заголовок.Получить("Method")) + " " + Запрос.Заголовок.Получить("Path"));

	КонецЕсли;

КонецФункции


Процедура ОбработатьОтветСервера(Задача)

	Перем ИмяФайла;

	Попытка

		СтатусОтвета = 200;
		Заголовок = Новый Соответствие();
		Если ТипЗнч(Задача.Результат) = Тип("ДвоичныеДанные") Тогда
			ДвоичныеДанныеОтвета =  Задача.Результат;
			Заголовок.Вставить("Content-Length", ДвоичныеДанныеОтвета.Размер());
			ContentType = "";
			Если Задача.Свойство("ContentType", ContentType) Тогда
				Заголовок.Вставить("Content-Type", ContentType);
			КонецЕсли;
		Иначе
			ДвоичныеДанныеОтвета = ПолучитьДвоичныеДанныеИзСтроки(Задача.Результат);
			Заголовок.Вставить("Content-Length", ДвоичныеДанныеОтвета.Размер());
			Заголовок.Вставить("Content-Type", "text/html");
			//Заголовок.Вставить("taskid", Задача.ИдЗадачи);
		КонецЕсли;

		// Разбор маршрута
		Если Задача.Свойство("ИмяДанных") Тогда

			ИмяФайла = ОбъединитьПути(ТекущийКаталог(), Задача.ИмяДанных);

			//ЛогСообщить(ИмяФайла);

			Файл = Новый Файл(ИмяФайла);
			Расширение = Файл.Расширение;

			Если НЕ Файл.Существует() Тогда
				ИмяФайла = СтрЗаменить(ИмяФайла, "/", "\");
				Файл = Новый Файл(ИмяФайла);
			КонецЕсли;

			Если НЕ Файл.Существует() Тогда
				СтатусОтвета = 404;
			КонецЕсли;

			Если СтатусОтвета = 200 Тогда
				MIME = СоответствиеРасширенийТипамMIME.Получить(Расширение);
				Если MIME = Неопределено Тогда
					MIME = СоответствиеРасширенийТипамMIME.Получить("default");
				КонецЕсли;
				ДвоичныеДанныеОтвета = Новый ДвоичныеДанные(СокрЛП(ИмяФайла));

				Заголовок.Вставить("Content-Length", ДвоичныеДанныеОтвета.Размер());
				Заголовок.Вставить("Content-Type", MIME);
			КонецЕсли;

		КонецЕсли;

		//Если Задача.Соединение.Активно Тогда

		Попытка

			ПС = Символы.ВК + Символы.ПС;
			ТекстОтветаКлиенту = СокрЛП(СтатусыHTTP[Число(СтатусОтвета)]) + ПС;
			Для Каждого СтрокаЗаголовкаответа из Заголовок Цикл
				ТекстОтветаКлиенту = ТекстОтветаКлиенту + СтрокаЗаголовкаответа.Ключ + ":" + СтрокаЗаголовкаответа.Значение + ПС;
			КонецЦикла;

			мДанные = Новый Массив;
			мДанные.Добавить(ПолучитьДвоичныеДанныеИзСтроки(ТекстОтветаКлиенту + ПС));
			//Сообщить(ТекстОтветаКлиенту);
			мДанные.Добавить(ДвоичныеДанныеОтвета);

			Задача.Соединение.ОтправитьДвоичныеДанныеАсинхронно(СоединитьДвоичныеДанные(мДанные));
			Задача.Этап = "Вернуть";

		Исключение

			Сообщить("webserver: " + ОписаниеОшибки());
			Задача.Этап = "УдалитьЗадачу";

		КонецПопытки;

		//КонецЕсли;

	Исключение
		ЛогСообщить("Ошибка формирования ответа");
		ЛогСообщить(ОписаниеОшибки());
		Задача.Этап = "Удалить";
	КонецПопытки;

КонецПроцедуры


Процедура ОбработатьЗадачи()

	НачалоЦикла = ТекущаяУниверсальнаяДатаВМиллисекундах();

	к = мЗадачи.Количество();
	Пока к > 0 И НЕ ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоЦикла > 50 Цикл
		к = к - 1;
		Задача = мЗадачи.Получить(0);
		мЗадачи.Удалить(0);

		Если Задача.Этап = "Новая" Тогда
			ПарИдКонтроллера = "";
			ИмяКонтроллера = Задача.ПараметрыЗапроса.ИмяКонтроллера;
			Если ИмяКонтроллера = "procid" Тогда // конкретный процесс
				ПарИдКонтроллера = Задача.ПараметрыЗапроса.ИмяМетода;
				Если Контроллеры.Получить(ПарИдКонтроллера) = Неопределено Тогда
					ПарИдКонтроллера = "";
				КонецЕсли;
			Иначе
				Если ИмяКонтроллера = "" ИЛИ ИмяКонтроллера = "doc" Тогда // общий процесс
					ПарИдКонтроллера = "1";
				Иначе
					ПарИдКонтроллера = "" + ПолучитьИд();
				КонецЕсли;
				Если Контроллеры.Получить(ПарИдКонтроллера) = Неопределено Тогда
					Если ПередатьДанные(Параметры.Хост, Параметры.ПортС, Новый Структура("procid, cmd", ПарИдКонтроллера, "startproc")) = Неопределено Тогда
						Сообщить("webserver: ошибка создания процесса");
						ПарИдКонтроллера = "";
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Если НЕ ПарИдКонтроллера = "" Тогда
				Задача.ИдКонтроллера = ПарИдКонтроллера;
				Задача.Этап = "Ожидание";
			Иначе
				Задача.Результат = "<div id='container' class='container-fluid data'>wrong session id</div><script>aupd=false</script>";
				Задача.Этап = "Обработка";
			КонецЕсли;
		КонецЕсли;

		Если Задача.Этап = "Ожидание" Тогда
			структКонтроллер = Контроллеры.Получить(Задача.ИдКонтроллера);
			Если НЕ структКонтроллер = Неопределено Тогда
				структКонтроллер.Вставить("ВремяНачало", ТекущаяУниверсальнаяДатаВМиллисекундах());
				Задача.Вставить("структКонтроллер", структКонтроллер);
				Задача.Вставить("ВремяНачало", ТекущаяУниверсальнаяДатаВМиллисекундах());
				Задача.ПараметрыЗапроса.Вставить("taskid", Задача.ИдЗадачи);
				Задача.Этап = "Передать";
			КонецЕсли;

		КонецЕсли;

		Если Задача.Этап = "Передать" Тогда
			Если НЕ ПередатьДанные(Задача.структКонтроллер.Хост, Задача.структКонтроллер.Порт, Задача.ПараметрыЗапроса) = Неопределено Тогда
				Задача.Этап = "Обработка";
			КонецЕсли;
		КонецЕсли;

		Если Задача.Этап = "Обработка" Тогда
			Если НЕ Задача.Соединение = Неопределено Тогда
				Если НачалоЦикла - Задача.ВремяНачало > 30 * 1000 Тогда
					Задача.ВремяНачало = НачалоЦикла;
					Если НЕ Задача.Соединение.Активно Тогда
						Сообщить("webserver: соединение потеряно");
						структКонтроллер = Контроллеры.Получить(Задача.ИдКонтроллера);
						Если НЕ структКонтроллер = Неопределено Тогда
							ПараметрыЗапроса = Новый Структура("ИдЗадачи, cmd", Задача.ИдЗадачи, "taskend"); // сообщить контроллеру чтобы завершил задачу
							ПередатьДанные(структКонтроллер.Хост, структКонтроллер.Порт, ПараметрыЗапроса);
						КонецЕсли;
						Задача.Этап = "Завершить";
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Если НЕ Задача.Результат = Неопределено Тогда
				ОбработатьОтветСервера(Задача);
			КонецЕсли;
		КонецЕсли;

		Если Задача.Этап = "Вернуть" Тогда
			Если НЕ Задача.Соединение.Статус = "Занят" Тогда
				Задача.Соединение.Закрыть();
				Задача.Соединение = Неопределено;
				Задача.Этап = "Завершить";
			КонецЕсли;
		КонецЕсли;

		Если Задача.Этап = "Завершить" Тогда
			Задачи.Удалить(Задача.ИдЗадачи);
			ЛогСообщить("<- taskid=" + СокрЛП(Задача.ИдЗадачи) + " time=" + Цел(ТекущаяУниверсальнаяДатаВМиллисекундах() - Задача.ВремяНачало) + Загрузка + Задачи.Количество() + " tasks");
			Продолжить;
		КонецЕсли;

		мЗадачи.Добавить(Задача);

	КонецЦикла;

КонецПроцедуры


Процедура ЛогСообщить(Сообщение, Тип = 0)
	Сообщить("" + ТекущаяДата() + " " + Сообщение);
	// // Если нужен лог
	// Если НЕ Параметры = Неопределено Тогда
	// 	Сообщения.Добавить(Новый Структура("БазаДанных, Заголовок, Команда", "web", Новый Структура("Тип, Сообщение", Тип, Сообщение), "ЗаписатьЗаголовок"));
	// КонецЕсли;
КонецПроцедуры


Процедура УдалитьКонтроллерИЗадачи(структКонтроллер)
	Контроллеры.Удалить(структКонтроллер.ИдКонтроллера);
	Для каждого элЗадача Из Задачи Цикл
		Если ЭлЗадача.Значение.структКонтроллер = структКонтроллер Тогда
			//ЭлЗадача.Значение.Этап = "Завершить";
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры


Процедура ОбработатьСоединения()

	Версия = "0.0.1";
	Порт = 8888;
	ПортО = 8889;

	Если АргументыКоманднойСтроки.Количество() > 1 Тогда
		ПортО = АргументыКоманднойСтроки[0];
		Порт = АргументыКоманднойСтроки[1];
	КонецЕсли;

	Таймаут = 10;

	TCPСервер = Новый TCPСервер(Порт);
	TCPСервер.ЗапуститьАсинхронно();
	ЛогСообщить("Веб-сервер запущен на порту: " + Порт);

	TCPСерверО = Новый TCPСервер(ПортО);
	TCPСерверО.ЗапуститьАсинхронно();
	ЛогСообщить("Ответы на порту: " + ПортО);

	ОстановитьСервер = Ложь;
	Соединение = Неопределено;

	Задачи = Новый Соответствие;
	мЗадачи = Новый Массив;
	Контроллеры = Новый Соответствие;
	Сообщения = Новый Массив;

	Соединения = Новый Массив;
	СоединенияО = Новый Массив;

	СуммаЦиклов = 0;
	РабочийЦикл = 0;
	ЗамерВремени = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Загрузка = " ";

	Пока Не ОстановитьСервер Цикл

		НачалоЦикла = ТекущаяУниверсальнаяДатаВМиллисекундах();
		СуммаЦиклов = СуммаЦиклов + 1;

		Если СуммаЦиклов > 999 Тогда
			ПредЗамер = ЗамерВремени;
			ЗамерВремени = ТекущаяУниверсальнаяДатаВМиллисекундах();
			Загрузка = " " + РабочийЦикл / 10 + "% " + Цел(1000 * РабочийЦикл / (ЗамерВремени - ПредЗамер)) + " q/s ";
			СуммаЦиклов = 0;
			РабочийЦикл = 0;
		КонецЕсли;

		// Ожидаем ответ контроллера
		т = Таймаут;
		Пока Истина Цикл
			Соединение = TCPСерверО.ПолучитьСоединение(т);
			Если Соединение = Неопределено Тогда
				Прервать;
			КонецЕсли;
			СоединенияО.Вставить(0, Соединение);
			т = 0;
		КонецЦикла;

		к = СоединенияО.Количество();
		Пока к > 0 Цикл
			к = к - 1;
			Соединение = СоединенияО.Получить(0);
			СоединенияО.Удалить(0);

			Если Соединение.Статус = "Успех" Тогда
				Попытка
					КонтроллерЗапрос = Неопределено;
					КонтроллерЗапрос = ДвоичныеДанныеВСтруктуру(Соединение.ПолучитьДвоичныеДанные());
				Исключение
					Сообщить("webserver: " + ОписаниеОшибки());
				КонецПопытки;

				Если НЕ КонтроллерЗапрос = Неопределено Тогда
					Если КонтроллерЗапрос.Свойство("procid") Тогда
						структКонтроллер = Контроллеры.Получить(КонтроллерЗапрос.procid);
						Если КонтроллерЗапрос.Свойство("cmd") Тогда
							Сообщить("webserver: " + КонтроллерЗапрос.cmd);
							Если КонтроллерЗапрос.cmd = "termproc" Тогда // удалить контроллер
								Если НЕ структКонтроллер = Неопределено Тогда
									УдалитьКонтроллерИЗадачи(структКонтроллер);
								КонецЕсли
							ИначеЕсли КонтроллерЗапрос.cmd = "init" Тогда // зарегистрировать контроллер
								Если структКонтроллер = Неопределено Тогда
									ЛогСообщить("Подключен контроллер procid=" + КонтроллерЗапрос.procid);
									структКонтроллер = Новый Структура("ИдКонтроллера, Хост, Порт, ВремяНачало", КонтроллерЗапрос.procid, КонтроллерЗапрос.Хост, КонтроллерЗапрос.Порт, ТекущаяУниверсальнаяДатаВМиллисекундах());
									Контроллеры.Вставить(КонтроллерЗапрос.procid, структКонтроллер);
								КонецЕсли;
							КонецЕсли;
						КонецЕсли;

						Если КонтроллерЗапрос.Свойство("taskid") Тогда
							Задача = Задачи.Получить(КонтроллерЗапрос.taskid);
							Если НЕ Задача = Неопределено Тогда
								ContentType = "";
								Если КонтроллерЗапрос.Свойство("ContentType", ContentType) Тогда
									Задача.Вставить("ContentType", ContentType);
								КонецЕсли;
								Задача.Результат = КонтроллерЗапрос.Результат;
							КонецЕсли;
						КонецЕсли;

					ИначеЕсли КонтроллерЗапрос.Свойство("cmd") Тогда
						Если КонтроллерЗапрос.cmd = "stopserver" Тогда
							ОстановитьСервер = Истина;

						ИначеЕсли КонтроллерЗапрос.cmd = "init" Тогда
							Если Параметры = Неопределено Тогда
								Сообщить("Получены параметры");
								Параметры = КонтроллерЗапрос;
							КонецЕсли;

						КонецЕсли;

					КонецЕсли;

				КонецЕсли;

				Соединение.Закрыть();
				РабочийЦикл = РабочийЦикл + 1;
				Продолжить;

			ИначеЕсли Соединение.Статус = "Ошибка" Тогда

				Соединение.Закрыть();
				Продолжить;

			КонецЕсли;

			СоединенияО.Добавить(Соединение);

		КонецЦикла;

		Если Параметры = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		// Ожидаем подключение клиента
		т = Таймаут;
		Пока Истина Цикл
			Соединение = TCPСервер.ПолучитьСоединение(т);
			Если Соединение = Неопределено Тогда
				Прервать;
			КонецЕсли;
			Соединения.Вставить(0, Соединение);
			т = 0;
		КонецЦикла;

		к = Соединения.Количество();
		Пока к > 0 Цикл
			к = к - 1;
			Соединение = Соединения.Получить(0);
			Соединения.Удалить(0);

			Если Соединение.Статус = "Успех" Тогда

				Попытка
					ТекстовыеДанныеВходящие = "";
					ТекстовыеДанныеВходящие = ПолучитьСтрокуИзДвоичныхДанных(Соединение.ПолучитьДвоичныеДанные(), "windows-1251");
				Исключение
					Сообщить("webserver: " + ОписаниеОшибки());
				КонецПопытки;

				Если НЕ ТекстовыеДанныеВходящие = "" Тогда

					// Запрос http

					Попытка
						Запрос = РазобратьЗапросКлиента(ТекстовыеДанныеВходящие);
						ОбработатьЗапросКлиента(Запрос, Соединение);
						//Сообщить("webserver: всего задач " + Задачи.Количество());
					Исключение
						ЛогСообщить(ОписаниеОшибки());
						ЛогСообщить("Ошибка обработки запроса:");
						ЛогСообщить(ТекстовыеДанныеВходящие);
						Попытка
							Соединение.ОтправитьСтроку("500");
						Исключение
						КонецПопытки;
					КонецПопытки;

					РабочийЦикл = РабочийЦикл + 1;

				КонецЕсли;

				Продолжить;

			ИначеЕсли Соединение.Статус = "Ошибка" Тогда

				Соединение.Закрыть();
				Продолжить;

			КонецЕсли;

			Соединения.Добавить(Соединение);

		КонецЦикла;

		Если Задачи.Количество() Тогда
			ОбработатьЗадачи();
		КонецЕсли;

		Если Сообщения.Количество() Тогда
			ПередатьДанные(Параметры.Хост, Параметры.ПортД, Сообщения.Получить(0));
			Сообщения.Удалить(0);
		КонецЕсли;

		ВремяЦикла = ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоЦикла;
		Если ВремяЦикла > 100 Тогда
			Сообщить("!webserver ВремяЦикла=" + ВремяЦикла);
		КонецЕсли;
		Таймаут = ?(ВремяЦикла > 25, 0, 10);

	КонецЦикла;

	TCPСервер.Остановить();
	TCPСерверО.Остановить();

КонецПроцедуры

МоментЗапуска = ТекущаяУниверсальнаяДатаВМиллисекундах();

СтатусыHTTP = Новый Массив(1000);
СтатусыHTTP.Вставить(200,"HTTP/1.1 200 OK");
СтатусыHTTP.Вставить(400,"HTTP/1.1 400 Bad Request");
СтатусыHTTP.Вставить(401,"HTTP/1.1 401 Unauthorized");
СтатусыHTTP.Вставить(402,"HTTP/1.1 402 Payment Required");
СтатусыHTTP.Вставить(403,"HTTP/1.1 403 Forbidden");
СтатусыHTTP.Вставить(404,"HTTP/1.1 404 Not Found");
СтатусыHTTP.Вставить(405,"HTTP/1.1 405 Method Not Allowed");
СтатусыHTTP.Вставить(406,"HTTP/1.1 406 Not Acceptable");
СтатусыHTTP.Вставить(500,"HTTP/1.1 500 Internal Server Error");
СтатусыHTTP.Вставить(501,"HTTP/1.1 501 Not Implemented");
СтатусыHTTP.Вставить(502,"HTTP/1.1 502 Bad Gateway");
СтатусыHTTP.Вставить(503,"HTTP/1.1 503 Service Unavailable");
СтатусыHTTP.Вставить(504,"HTTP/1.1 504 Gateway Timeout");
СтатусыHTTP.Вставить(505,"HTTP/1.1 505 HTTP Version Not Supported");

СоответствиеРасширенийТипамMIME = Новый Соответствие();
СоответствиеРасширенийТипамMIME.Вставить(".html","text/html");
СоответствиеРасширенийТипамMIME.Вставить(".css","text/css");
СоответствиеРасширенийТипамMIME.Вставить(".js","text/javascript");
СоответствиеРасширенийТипамMIME.Вставить(".jpg","image/jpeg");
СоответствиеРасширенийТипамMIME.Вставить(".svg","image/svg+xml");
СоответствиеРасширенийТипамMIME.Вставить(".jpeg","image/jpeg");
СоответствиеРасширенийТипамMIME.Вставить(".png","image/png");
СоответствиеРасширенийТипамMIME.Вставить(".gif","image/gif");
СоответствиеРасширенийТипамMIME.Вставить(".ico","image/x-icon");
СоответствиеРасширенийТипамMIME.Вставить(".zip","application/x-compressed");
СоответствиеРасширенийТипамMIME.Вставить(".rar","application/x-compressed");

СоответствиеРасширенийТипамMIME.Вставить("default","text/plain");

ОбработатьСоединения();
