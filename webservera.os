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
Перем Задачи;
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
		//Соединение.Закрыть();
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
		Задача.Вставить("ИдЗадачи", "" + ИдЗадачи);
		Задача.Вставить("структКонтроллер", Неопределено);
		Задача.Вставить("ИмяМетода", Запрос.ИмяМетода);
		Задача.Вставить("ИмяКонтроллера", Запрос.ИмяКонтроллера);
		Задача.Вставить("ВремяНачало", ТекущаяУниверсальнаяДатаВМиллисекундах());
		Задача.Вставить("Соединение", Соединение);
		Задача.Вставить("ИдКонтроллера", Неопределено);
		Задача.Вставить("Результат", Неопределено);
		Задача.Вставить("Этап", "Новая");
		Задача.Вставить("ПараметрыЗапроса", ПараметрыЗапроса);
		Задача.Вставить("УдаленныйУзел", УдаленныйУзелАдрес(Соединение.УдаленныйУзел));
		ПараметрыЗапроса.Вставить("УдаленныйУзел", Задача.УдаленныйУзел);

		Если Запрос.ИмяКонтроллера = "resource" Тогда // запрос к файлам сервера

			Задача.Вставить("ИмяДанных", ОбъединитьПути(Запрос.ИмяКонтроллера, Запрос.ИмяМетода));
			Задача.Вставить("Результат", "Файл");
			Задача.Этап = "Обработка";

		//ИначеЕсли Запрос.ИмяКонтроллера = "webdata" Тогда
		ИначеЕсли Запрос.ИмяКонтроллера = "procid" Тогда
		//ИначеЕсли Запрос.ИмяКонтроллера = "showdata" Тогда
		Иначе
			Если Запрос.ИмяМетода = "" Тогда
				Задача.Вставить("ИмяКонтроллера", "");
				Задача.Вставить("ИмяМетода", Запрос.ИмяКонтроллера);
			КонецЕсли;
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
		Иначе
			ДвоичныеДанныеОтвета = ПолучитьДвоичныеДанныеИзСтроки(Задача.Результат);
			Заголовок.Вставить("Content-Length", ДвоичныеДанныеОтвета.Размер());
			Заголовок.Вставить("Content-Type", "text/html");
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

			ПС = Символы.ВК + Символы.ПС;
			мЗаголовок = СокрЛП(СтатусыHTTP[Число(СтатусОтвета)]) + ПС;
			Задача.Соединение.ОтправитьСтроку(мЗаголовок);
			ТекстОтветаКлиенту = "";
			Для Каждого СтрокаЗаголовкаответа из Заголовок Цикл
				ТекстОтветаКлиенту = ТекстОтветаКлиенту + СтрокаЗаголовкаответа.Ключ + ":" + СтрокаЗаголовкаответа.Значение + ПС;
			КонецЦикла;

			Задача.Соединение.ОтправитьСтроку(ТекстОтветаКлиенту);
			Задача.Соединение.ОтправитьСтроку(ПС);

			Задача.Соединение.ОтправитьДвоичныеДанныеАсинхронно(ДвоичныеДанныеОтвета);
			Задача.Этап = "Вернуть";

		//КонецЕсли;

	Исключение
		ЛогСообщить("Ошибка формирования ответа");
		ЛогСообщить(ОписаниеОшибки());
		Задача.Этап = "Удалить";
	КонецПопытки;

КонецПроцедуры


Процедура ОбработатьЗадачи()

	ПереченьЗадач = Новый СписокЗначений;
	Для каждого элЗадача Из Задачи Цикл
		ПереченьЗадач.Добавить(ЭлЗадача.Значение, элЗадача.Ключ);
	КонецЦикла;

	ПереченьЗадач.СортироватьПоПредставлению(НаправлениеСортировки.Возр);
	Для каждого элПеречень Из ПереченьЗадач Цикл
		Задача = элПеречень.Значение;

		Если Задача.Этап = "Новая" Тогда

			ПарИдКонтроллера = "";

			// Если Задача.ИмяКонтроллера = "webdata" Тогда // по умолчанию контроллер webdata
			//
			// 	ПарИдКонтроллера = "0";
			// 	Задача.ПараметрыЗапроса.Вставить("data", Задача.ИмяМетода); // имя данных
			//
			Если Задача.ИмяКонтроллера = "procid" Тогда // конкретный процесс

				ПарИдКонтроллера = Задача.ИмяМетода;

			Иначе // запустить новый процесс

				ПарИдКонтроллера = "" + ПолучитьИд();
				Если НЕ ПередатьДанные(Параметры.Хост, Параметры.ПортС, Новый Структура("procid, sdata, data, УдаленныйУзел, cmd", ПарИдКонтроллера, Задача.ИмяКонтроллера, Задача.ИмяМетода, Задача.УдаленныйУзел, "startproc")) = Неопределено Тогда // запустить новый процесс контроллера
					Задача.ИмяКонтроллера = "procid";
					Задача.ИмяМетода = ПарИдКонтроллера;
				КонецЕсли;

			КонецЕсли;

			Если НЕ ПарИдКонтроллера = "" Тогда
				Задача.ИдКонтроллера = ПарИдКонтроллера;
				Задача.Этап = "Ожидание";
			Иначе
				Задача.Этап = "Удалить";
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
			Если НЕ Задача.Результат = Неопределено Тогда
				ОбработатьОтветСервера(Задача);
			КонецЕсли;
		КонецЕсли;

		Если Задача.Этап = "Вернуть" Тогда
			Если НЕ Задача.Соединение.Занят Тогда
				Задача.Соединение.Закрыть();
				Задача.Соединение = Неопределено;
				Задача.Этап = "Завершить";
				ЛогСообщить("<- taskid=" + СокрЛП(Задача.ИдЗадачи) + " time=" + Цел(ТекущаяУниверсальнаяДатаВМиллисекундах() - Задача.ВремяНачало) + Загрузка + Задачи.Количество() + " tasks");
			КонецЕсли;
		КонецЕсли;

		// Если НЕ Задача.Соединение = Неопределено Тогда
		// 	Если НЕ Задача.Соединение.Активно Тогда
		// 		Сообщить("webserver: соединение потеряно");
		// 		структКонтроллер = Контроллеры.Получить(Задача.ИдКонтроллера);
		// 		Если НЕ структКонтроллер = Неопределено Тогда
		// 			ПараметрыЗапроса = Новый Структура("ИдЗадачи, cmd", Задача.ИдЗадачи, "taskend"); // сообщить контроллеру чтобы завершил задачу
		// 			ПередатьДанные(структКонтроллер.Хост, структКонтроллер.Порт, ПараметрыЗапроса);
		// 		КонецЕсли;
		// 		Задачи.Удалить(Задача.ИдЗадачи);
		// 	КонецЕсли;
		// КонецЕсли;

		Если Задача.Этап = "Завершить" Тогда
			Задачи.Удалить(Задача.ИдЗадачи);
		КонецЕсли;

	КонецЦикла;

	Если Сообщения.Количество() Тогда
		ПередатьДанные(Параметры.Хост, Параметры.ПортД, Сообщения.Получить(0));
		Сообщения.Удалить(0);
	КонецЕсли;

КонецПроцедуры


Процедура ЛогСообщить(Сообщение, Тип = 0)
	Сообщить("" + ТекущаяДата() + " " + Сообщение);
	Если НЕ Параметры = Неопределено Тогда
		Сообщения.Добавить(Новый Структура("БазаДанных, Заголовок, Команда", "web", Новый Структура("Тип, Сообщение", Тип, Сообщение), "ЗаписатьЗаголовок"));
	КонецЕсли;
КонецПроцедуры


Процедура УдалитьКонтроллерИЗадачи(структКонтроллер)
	Контроллеры.Удалить(структКонтроллер.ИдКонтроллера);
	Для каждого элЗадача Из Задачи Цикл
		Если ЭлЗадача.Значение.структКонтроллер = структКонтроллер Тогда
			ЭлЗадача.Значение.Этап = "Завершить";
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры


Процедура ОбработатьСоединения()

	Версия = "0.0.1";
	Порт = 8888;
	ПортО = 8889;

	Таймаут = 10;
	Если АргументыКоманднойСтроки.Количество() > 1 Тогда
		ПортО = АргументыКоманднойСтроки[0];
		Порт = АргументыКоманднойСтроки[1];
	КонецЕсли;

	TCPСервер = Новый TCPСервер(Порт);
	TCPСервер.Запустить();
	ЛогСообщить("Веб-сервер запущен на порту: " + Порт);

	TCPСерверО = Новый TCPСервер(ПортО);
	TCPСерверО.Запустить();
	ЛогСообщить("Ответы на порту: " + ПортО);

	ОстановитьСервер = Ложь;
	Соединение = Неопределено;

	Задачи = Новый Соответствие;
	Контроллеры = Новый Соответствие;
	Сообщения = Новый Массив;

	Соединения = Новый Соответствие;
	СоединенияО = Новый Соответствие;

	ПустойЦикл = 0;
	РабочийЦикл = 0;
	ЗамерВремени = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Пока Не ОстановитьСервер Цикл

		Если ПустойЦикл + РабочийЦикл > 999 Тогда
			ПредЗамер = ЗамерВремени;
			ЗамерВремени = ТекущаяУниверсальнаяДатаВМиллисекундах();
			Загрузка = " " + РабочийЦикл / 10 + "% " + Цел(1000 * РабочийЦикл / (ЗамерВремени - ПредЗамер)) + " q/s ";
			ПустойЦикл = 0;
			РабочийЦикл = 0;
		КонецЕсли;

		// Ожидаем подключение клиента
		Соединение = TCPСервер.ОжидатьСоединения(Таймаут);

		Если НЕ Соединение = Неопределено Тогда

			Соединение.ТаймаутОтправки = 5000;
			Соединение.ТаймаутЧтения = 5000;

			Соединение.ПрочитатьДвоичныеДанныеАсинхронно();
			Соединения.Вставить(Соединение, Истина);

		КонецЕсли;

		Для каждого зСоединение Из Соединения Цикл
			Соединение = зСоединение.Ключ;
			Если НЕ Соединение.Занят Тогда

				Попытка
					ТекстовыеДанныеВходящие = "";
					дд = Соединение.ПолучитьДвоичныеДанные();
					//Сообщить("webserver: " + дд.Размер());
					ТекстовыеДанныеВходящие = ПолучитьСтрокуИзДвоичныхДанных(дд, "windows-1251");
				Исключение
					Сообщить("webserver: " + ОписаниеОшибки());
				КонецПопытки;

				Если ТекстовыеДанныеВходящие = "" Тогда
					Соединение.Закрыть();
					ПустойЦикл = ПустойЦикл + 1;
					Продолжить;

				Иначе // Запрос http

					РабочийЦикл = РабочийЦикл + 1;

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
						Соединение.Закрыть();
					КонецПопытки;

				КонецЕсли;

				Соединения.Удалить(Соединение);
				Прервать;

			КонецЕсли;
		КонецЦикла;

		//Иначе // Ожидаем ответ контроллера

			Соединение = TCPСерверО.ОжидатьСоединения(Таймаут);

			Если НЕ Соединение = Неопределено Тогда

				//Соединение.ТаймаутОтправки = 300;
				Соединение.ТаймаутЧтения = 5000;

				мДанные = Новый Массив;

				Попытка
					КонтроллерЗапрос = Неопределено;
					Пока КонтроллерЗапрос = Неопределено Цикл
						дд = Соединение.ПрочитатьДвоичныеДанные();
						Если дд.Размер() = 0 Тогда
							Прервать;
						КонецЕсли;
						мДанные.Добавить(дд);
						КонтроллерЗапрос = ДвоичныеДанныеВСтруктуру(СоединитьДвоичныеДанные(мДанные));
					КонецЦикла;
				Исключение
					Сообщить("webserver: " + ОписаниеОшибки());
				КонецПопытки;

				Если НЕ Соединение = Неопределено Тогда
					Соединение.Закрыть();
				КонецЕсли;

				Если КонтроллерЗапрос = Неопределено Тогда
					Продолжить;
				КонецЕсли;

				РабочийЦикл = РабочийЦикл + 1;

				Если КонтроллерЗапрос.Свойство("procid") Тогда
					структКонтроллер = Контроллеры.Получить(КонтроллерЗапрос.procid);
					Если КонтроллерЗапрос.Свойство("cmd") Тогда
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
							Задача.Результат = КонтроллерЗапрос.Результат;
						КонецЕсли;
						Соединение.Закрыть();
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

			Иначе

				ПустойЦикл = ПустойЦикл + 1;

			КонецЕсли;

		//КонецЕсли;

		Если Задачи.Количество() Тогда
			ОбработатьЗадачи();
		КонецЕсли;

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
