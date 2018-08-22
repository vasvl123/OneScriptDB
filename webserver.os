// Сделано на основе https://github.com/nextkmv/vServer


Перем Хост, Порт, ПерезапуститьСервер, ОстановитьСервер;
Перем СтатусыHTTP;
Перем СоответствиеРасширенийТипамMIME;
Перем Задачи, ИдЗадачи;
Перем Ресурсы;
Перем Процессы, ИдПроцесса;
Перем Загрузка;
Перем ВсеДанные;



Функция ПолучитьОбласть(ИмяОбласти, ЗначенияПараметров = Неопределено)
	Если ИмяОбласти = "ОбластьШапка" Тогда ОбластьТекст = "<!DOCTYPE html><html lang=""ru""><head><meta charset=""utf-8""/></head><body>";
	ИначеЕсли ИмяОбласти = "ОбластьПеренаправить" Тогда ОбластьТекст = "<!DOCTYPE html><html><script type='text/javascript'>setTimeout(function(){window.location.href = '" + ЗначенияПараметров.Путь + "';}, " + ЗначенияПараметров.Пауза + ");</script>wait...</html>";
	ИначеЕсли ИмяОбласти = "ОбластьПодвал" Тогда ОбластьТекст = "</body></html>";
	Иначе ОбластьТекст = "";
	КонецЕсли;
	Возврат ОбластьТекст;
КонецФункции


Функция СтрокуВСтруктуру(Знач Стр)
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
	Если НЕ Структ = Неопределено Тогда
		Для каждого Элемент Из Структ Цикл
			Результат = ?(Результат = "", "", Результат + Символы.Таб) + Элемент.Ключ + Символы.Таб + Элемент.Значение;
		КонецЦикла;
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Разбирает вошедший запрос и возвращает структуру запроса
Функция РазобратьЗапросКлиента(ТекстЗапроса)

	Перем ИмяКонтроллера;
	Перем ИмяМетода;
	Перем ПараметрыМетода;

	Заголовок = Новый Соответствие();

	мТекстовыеДанные = ТекстЗапроса;
	Пока Найти(мТекстовыеДанные,Символы.ПС) > 0 Цикл
		П = Найти(мТекстовыеДанные,Символы.ПС);
		Подстрока = Лев(мТекстовыеДанные, П);
		мТекстовыеДанные = Прав(мТекстовыеДанные,СтрДлина(мТекстовыеДанные)-П);
		// Разбираем ключ значение
		Если Найти(Подстрока,"HTTP/1.1") > 0 Тогда
			// Это строка протокола
			// Определим метод
			П1 = 0;
			Метод = Неопределено;
			Если Найти(Подстрока,"POST") > 0 Тогда
				Метод ="POST";
				П1 = 4;
			ИначеЕсли Найти(Подстрока,"PUT") > 0 Тогда
				Метод = "PUT";
				П1 = 3;
			ИначеЕсли Найти(Подстрока,"DELETE") > 0 Тогда
				Метод ="DELETE";
				П1 = 6;
			ИначеЕсли Найти(Подстрока,"GET") > 0 Тогда
				Метод ="GET";
				П1 = 3;
			КонецЕсли;
			Заголовок.Вставить("Method", Метод);
			// Определим Путь
			П2 = Найти(Подстрока,"HTTP/1.1");
			Путь = СокрЛП(Сред(Подстрока,П1+1,СтрДлина(Подстрока)-10-П1));
			Заголовок.Вставить("Path", Путь);

		Иначе
			Если Найти(Подстрока,":") > 0 Тогда
				П3 = Найти(Подстрока,":");
				Ключ 		= СокрЛП(Лев(Подстрока,П3-1));
				Значение	= СокрЛП(Прав(Подстрока,СтрДлина(Подстрока)-П3));
				Заголовок.Вставить(Ключ, Значение);
			Иначе
				Ключ 		= "unknown";
				Значение	= СокрЛП(Подстрока);
				Если СтрДлина(Значение) > 0 Тогда
					Заголовок.Вставить(Ключ, Значение);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	// Получим данные запроса
	ПД = Найти(мТекстовыеДанные,Символы.ВК+Символы.ПС+Символы.ВК+Символы.ПС);
	POSTДанные = Сред(мТекстовыеДанные,ПД,СтрДлина(мТекстовыеДанные)-ПД);
	// Разбираем данные пост
	Если СтрДлина(POSTДанные) > 0 Тогда
		POSTДанные = POSTДанные + "&";
	КонецЕсли;
	Заголовок.Вставить("POSTДанные", POSTДанные);
	POSTСтруктура = Новый Структура();
	Пока Найти(POSTДанные,"&") > 0 Цикл
		П1 = Найти(POSTДанные,"&");
		П2 = Найти(POSTДанные,"=");
		Ключ = Лев(POSTДанные, П2-1);
		Значение = Сред(POSTДанные,П2+1, П1-(П2+1));
		Значение = РаскодироватьСтроку(Значение, СпособКодированияСтроки.КодировкаURL);
		POSTДанные = Прав(POSTДанные,СтрДлина(POSTДанные)-П1);
		POSTСтруктура.Вставить(Ключ,Значение);
	КонецЦикла;
	Заголовок.Вставить("POSTData", POSTСтруктура);
	//Сообщить(ПД);
	// Разбор пути на имена контроллеров
	Путь = СокрЛП(Заголовок.Получить("Path"));
	// ПараметрыМетода = Новый Массив();
	Если Не Путь = Неопределено Тогда
		Если Лев(Путь,1) = "/" Тогда
			Путь = Прав(Путь,СтрДлина(Путь)-1);
		КонецЕсли;
		Если Прав(Путь,1) <> "/" Тогда
			Путь = Путь+"/";
		КонецЕсли;
		Сч = 0;
		Пока Найти(Путь,"/") > 0 Цикл
			П = Найти(Путь,"/");
			Сч = Сч + 1;
			ЗначениеПараметра = Лев(Путь,П-1);
			Путь = Прав(Путь,СтрДлина(Путь)-П);
			Если Сч = 1 Тогда
				ИмяМетода = ЗначениеПараметра;
				ИмяКонтроллера = "showdata"; // Контроллер по умолчанию
			ИначеЕсли Сч = 2 Тогда
				ИмяКонтроллера = ИмяМетода;
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
					Значение = РаскодироватьСтроку(Значение, СпособКодированияСтроки.КодировкаURL);
					GETДанные = Прав(GETДанные, СтрДлина(GETДанные) - П1);
					GETСтруктура.Вставить(Ключ, Значение);
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Заголовок.Вставить("GETData", GETСтруктура);

	Запрос = Новый Структура;
	Запрос.Вставить("Заголовок", Заголовок);
	Запрос.Вставить("ИмяКонтроллера", ИмяКонтроллера);
	Запрос.Вставить("ИмяМетода", ИмяМетода);
	// Запрос.Вставить("ПараметрыМетода", ПараметрыМетода);

	Возврат Запрос;

КонецФункции


Функция ОбработатьЗапросКлиента(Запрос, Знач Соединение)

	ПараметрыЗапроса = Запрос.Заголовок.Получить(Запрос.Заголовок.Получить("Method") + "Data");

	Задача = Новый Структура;
	ИдЗадачи = ИдЗадачи + 1;
	Задачи.Вставить("" + ИдЗадачи, Задача);
	Задача.Вставить("ИдЗадачи", "" + ИдЗадачи);
	Задача.Вставить("структПроцесс", Неопределено);
	Задача.Вставить("ИмяМетода", Запрос.ИмяМетода);
	Задача.Вставить("ИмяКонтроллера", Запрос.ИмяКонтроллера);
	Задача.Вставить("ВремяНачало", ТекущаяДата());
	Задача.Вставить("Соединение", Соединение);
	Задача.Вставить("СоединениеПроцесс", Неопределено);
	Задача.Вставить("Результат", Неопределено);

	Если Запрос.ИмяКонтроллера = "tasks" Тогда
		Если Запрос.ИмяМетода = "stopserver" Тогда
			Задача.Вставить("Результат", "goodbye!");
			ОстановитьСервер = Истина;
		ИначеЕсли Запрос.ИмяМетода = "restartserver" Тогда
			Задача.Вставить("Результат", ПолучитьОбласть("ОбластьПеренаправить", Новый Структура("Путь, Пауза", "/", 500)));
			ПерезапуститьСервер = Истина;
		Иначе
			Задача.Вставить("Результат", "непонятно...");
		КонецЕсли;
	ИначеЕсли Запрос.ИмяКонтроллера = "resource" Тогда

		Задача.Вставить("ИмяДанных", ОбъединитьПути(Запрос.ИмяКонтроллера, Запрос.ИмяМетода));
		Задача.Вставить("Результат", "Файл");

	ИначеЕсли Запрос.ИмяКонтроллера = "test" Тогда

		Результат = ПолучитьОбласть("ОбластьШапка") + ТекущаяДата() + ПолучитьОбласть("ОбластьПодвал");
		Задача.Вставить("Результат", Результат);

	ИначеЕсли Запрос.ИмяКонтроллера = "showdata" Тогда

		Задача.Вставить("ПараметрыЗапроса", ПараметрыЗапроса);

	Иначе

		Задача.Результат = "404";

	КонецЕсли;

	Сообщить(СокрЛП(ТекущаяДата()) + " -> taskid=" + Задача.ИдЗадачи + " " + СокрЛП(Запрос.Заголовок.Получить("Method")) + " " + Запрос.Заголовок.Получить("Path"));

КонецФункции


Процедура ОбработатьОтветСервера(Задача)

	Перем ИмяФайла;

	Попытка

		СтатусОтвета = 200;
		Заголовок = Новый Соответствие();
		Если ТипЗнч(Задача.Результат) = Тип("ДвоичныеДанные") Тогда
			ДвоичныеДанныеОтвета =  Задача.Результат;
			ТекстОтвета = Неопределено;
		Иначе
			ДвоичныеДанныеОтвета = Неопределено;
			ТекстОтвета = Задача.Результат;
		КонецЕсли;
		Размер = 0;

		// Разбор маршрута
		Если Задача.Свойство("ИмяДанных") Тогда

			ИмяФайла = ОбъединитьПути(ТекущийКаталог(), Задача.ИмяДанных);

			Сообщить(ИмяФайла);

			Файл = Новый Файл(ИмяФайла);
			Расширение = Файл.Расширение;

			Если НЕ Файл.Существует() Тогда
				ИмяФайла = СтрЗаменить(ИмяФайла, "/", "\");
				Файл = Новый Файл(ИмяФайла);
				// Если НЕ Файл.Существует() Тогда
					// СтатусОтвета = 500;
				// КонецЕсли;
			КонецЕсли;

			Если Файл.Существует() Тогда
				Размер	= Файл.Размер();
				//Ресурсы.ДобавитьДанные(Новый Структура("ИмяФайла, ИмяДанных, Расширение", ИмяФайла, Задача.ИмяДанных, Расширение));
			Иначе

				ЗаголовокФайла = Ресурсы.ПолучитьФайл(Задача.ИмяДанных);

				Если НЕ ЗаголовокФайла = Неопределено Тогда

					ИмяФайла = ОбъединитьПути(Ресурсы.КаталогФайловДанных, ЗаголовокФайла.ПозицияДанныхФайла);
					Расширение = ЗаголовокФайла.Расширение;
					Размер		= ЗаголовокФайла.ОбъемДанных;
				Иначе
					СтатусОтвета = 500;
				КонецЕсли;

			КонецЕсли;

			Если НЕ СтатусОтвета = 500 Тогда
				MIME = СоответствиеРасширенийТипамMIME.Получить(Расширение);
				Если MIME = Неопределено Тогда
					MIME = СоответствиеРасширенийТипамMIME.Получить("default");
				КонецЕсли;
				ДвоичныеДанные = Новый ДвоичныеДанные(СокрЛП(ИмяФайла));
				ДвоичныеДанныеОтвета = ДвоичныеДанные;

				Заголовок.Вставить("Content-Length", Размер);
				Заголовок.Вставить("Content-Type", MIME);
			КонецЕсли;

		КонецЕсли;

		Если Задача.Соединение.Активно Тогда

			ПС = Символы.ВК + Символы.ПС;
			мЗаголовок = СокрЛП(СтатусыHTTP[Число(СтатусОтвета)]) + ПС;
			Задача.Соединение.ОтправитьСтроку(мЗаголовок);
			ТекстОтветаКлиенту = "";
			Для Каждого СтрокаЗаголовкаответа из Заголовок Цикл
				ТекстОтветаКлиенту = ТекстОтветаКлиенту + СтрокаЗаголовкаответа.Ключ + ":" + СтрокаЗаголовкаответа.Значение + ПС;
			КонецЦикла;
			//ТекстОтветаКлиенту = ТекстОтветаКлиенту + "Content-Length:"+Строка((СтрДлина(Ответ.ТекстОтвета)-2)*2)+ПС+ПС;

			Попытка
				Задача.Соединение.ОтправитьСтроку(ТекстОтветаКлиенту);
				Задача.Соединение.ОтправитьСтроку(ПС);

				Если НЕ ДвоичныеДанныеОтвета = Неопределено Тогда
					Задача.Соединение.ОтправитьДвоичныеДанные(ДвоичныеДанныеОтвета);
				Иначе
					Задача.Соединение.ОтправитьСтроку(СокрЛП(ТекстОтвета));
				КонецЕсли;
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;

		КонецЕсли;

	Исключение
		Сообщить("Ошибка формирования ответа");
		Сообщить(ОписаниеОшибки());
	КонецПопытки;

	Задача.Соединение.Закрыть();
	Сообщить(СокрЛП(ТекущаяДата()) + " <- taskid=" + СокрЛП(Задача.ИдЗадачи) + " time=" + (ТекущаяДата() - Задача.ВремяНачало) + Загрузка);
	Задача.Вставить("Завершена");

КонецПроцедуры


Функция ОбработатьДанные(Запрос)
	Перем Команда, ИмяДанных, БазаДанных, ПозицияДанных;

	Запрос.Свойство("osdb", БазаДанных);
	Если НЕ "" + БазаДанных = "" Тогда

		ФайлДанных = "";

		Данные = ВсеДанные.Получить(БазаДанных);
		Если Данные = Неопределено Тогда
			Данные = Новый dbaccess(ОбъединитьПути(ТекущийКаталог(), "data" , БазаДанных));
			ВсеДанные.Вставить(БазаДанных, Данные);
		КонецЕсли;

		Запрос.Свойство("datafile", ФайлДанных);
		Запрос.Свойство("dataposition", ПозицияДанных);
		Запрос.Свойство("data", ИмяДанных);

		Если НЕ "" + ФайлДанных = "" Тогда
			Если Данные.ОткрытьПотокДанных(Истина) Тогда
				Данные.ДобавитьДанные(Новый Структура("datafile, data, ext, date", ФайлДанных, ИмяДанных, "s", ТекущаяДата()));
			КонецЕсли;
		ИначеЕсли НЕ "" + ПозицияДанных = "" Тогда
			Если Данные.ПрочитатьДанные(Число(ПозицияДанных)) Тогда
				ФайлДанных = ПозицияДанных;
			КонецЕсли;
		Иначе
			ФайлДанных = Данные.ПолучитьСписокФайлов();
		КонецЕсли;
	КонецЕсли;
	Возврат ФайлДанных;

КонецФункции


Процедура ОбработатьЗадачи()

	ПрерватьЦикл = Ложь;
	Пока Не ПрерватьЦикл Цикл
		ПрерватьЦикл = Истина;
		Для каждого элЗадача Из Задачи Цикл
			Задача = элЗадача.Значение;
			Если Задача.Свойство("Завершена") Тогда
				Задачи.Удалить(элЗадача.Ключ);
				ПрерватьЦикл = Ложь;
				Прервать
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	Для каждого элЗадача Из Задачи Цикл

		Задача = элЗадача.Значение;

		Если НЕ Задача.Результат = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Если Задача.структПроцесс = Неопределено Тогда

			структПроцесс = Неопределено;
			ПарИдПроцесса = "";

			Если НЕ Задача.ПараметрыЗапроса.Свойство("procid", ПарИдПроцесса) Тогда
				ИдПроцесса = ИдПроцесса + 1;
				ПарИдПроцесса = ИдПроцесса;
			КонецЕсли;

			структПроцесс = Процессы.Получить("" + ПарИдПроцесса);
			Если НЕ структПроцесс = Неопределено Тогда
				Если структПроцесс.Процесс.Завершен Тогда
					Процессы.Удалить("" + ПарИдПроцесса);
					//Сообщить("Процесс " + ПарИдПроцесса + " упал!");
					Задача.Результат = "Процесс " + ПарИдПроцесса + " упал!";
					Продолжить;
				КонецЕсли;
			Иначе
				Сообщить("Процесс " + ПарИдПроцесса + " не найден!");
				Процесс = СоздатьПроцесс("oscript " + ОбъединитьПути(ТекущийКаталог(), Задача.ИмяКонтроллера + ".os " + ПарИдПроцесса + " " + Порт));
				структПроцесс = Новый Структура("ИдПроцесса, Процесс, Соединение", ПарИдПроцесса, Процесс);
				Сообщить("Запустил процесс " + Задача.ИмяКонтроллера + " procid=" + ПарИдПроцесса);
				Процесс.Запустить();
				Процессы.Вставить("" + ПарИдПроцесса, структПроцесс);
				Задача.ПараметрыЗапроса.Вставить("data", Задача.ИмяМетода); // сразу открыть файл
			КонецЕсли;

			структПроцесс.Вставить("ВремяНачало", ТекущаяДата());
			Задача.Вставить("структПроцесс", структПроцесс);

			Задача.Вставить("ВремяНачало", ТекущаяДата());
			Задача.ПараметрыЗапроса.Вставить("taskid", Задача.ИдЗадачи);

		КонецЕсли;

		Если Задача.СоединениеПроцесс = Неопределено Тогда
			Если НЕ Задача.структПроцесс.Соединение = Неопределено Тогда
				Если Задача.структПроцесс.Соединение.Активно Тогда
					Попытка
						Задача.структПроцесс.Соединение.ОтправитьСтроку(СтруктуруВСтроку(Задача.ПараметрыЗапроса));
						Задача.структПроцесс.Соединение.Закрыть();
						Задача.структПроцесс.Соединение = Неопределено;
						Задача.СоединениеПроцесс = Истина;

						Если Задача.ПараметрыЗапроса.Свойство("cmd") Тогда
							Задача.Результат = "";
						КонецЕсли;

					Исключение
					КонецПопытки;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;

	КонецЦикла;

	Для каждого элЗадача Из Задачи Цикл
		Задача = элЗадача.Значение;
		Если НЕ Задача.Результат = Неопределено Тогда
			ОбработатьОтветСервера(Задача);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Функция ЗавершитьВсеПроцессы()
	Для каждого элПроцесс Из Процессы Цикл
		Процесс = ЭлПроцесс.Значение.Процесс;
		Если НЕ Процесс.Завершен Тогда
			Процесс.Завершить();
		КонецЕсли;
	КонецЦикла;
КонецФункции

Процедура ОбработатьСоединения() Экспорт

	Версия = "0.0.1";
	Хост = "127.0.0.1";

	Таймаут = 10;
	Если АргументыКоманднойСтроки.Количество() Тогда
		Порт = АргументыКоманднойСтроки[0];
	Иначе
		Порт = 8888; // Локальный режим
	КонецЕсли;

	TCPСервер = Новый TCPСервер(Порт);
	TCPСервер.Запустить();
	Сообщить(СокрЛП(ТекущаяДата()) + " - Сервер запущен на порту: " + СокрЛП(Порт));

	ОстановитьСервер = Ложь;
	ПерезапуститьСервер = Ложь;
	Соединение = Неопределено;

	Задачи = Новый Соответствие;
	ИдЗадачи = 0;

	Процессы = Новый Соответствие;
	ИдПроцесса = 0;

	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "dbaccess.os"), "dbaccess");
	ВсеДанные = Новый Соответствие();
	Ресурсы = Новый dbaccess("resource");
	ВсеДанные.Вставить("resource", Ресурсы);

	ПустойЦикл = 0;
	РабочийЦикл = 0;
	ЗамерВремени = ТекущаяДата();

	Пока Истина Цикл

		Если Задачи.Количество() Тогда
			ОбработатьЗадачи();
			Если Порт = 8888 Тогда
				Если ПерезапуститьСервер Тогда
					TCPСервер.Остановить();
					ЗавершитьВсеПроцессы();
					ЗапуститьПриложение("oscript webserver.os", ТекущийКаталог());
					Прервать;
				КонецЕсли;
				Если ОстановитьСервер Тогда
					TCPСервер.Остановить();
					Прервать;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;

		Если ПустойЦикл + РабочийЦикл > 999 Тогда
			ПредЗамер = ЗамерВремени;
			ЗамерВремени = ТекущаяДата();
			Загрузка = " " + РабочийЦикл / 10 + "% " + Цел(РабочийЦикл/(ЗамерВремени - ПредЗамер)) + " запр/сек";
			ПустойЦикл = 0;
			РабочийЦикл = 0;

			Если НЕ Порт = 8888 Тогда
				Для каждого элПроцесс Из Процессы Цикл
					структПроцесс = ЭлПроцесс.Значение;
					Если ЗамерВремени - структПроцесс.ВремяНачало > 30*60 Тогда
						Если НЕ структПроцесс.Процесс.Завершен Тогда
							Сообщить("Процесс " + структПроцесс.ИдПроцесса + " простаивает, завершил.");
							структПроцесс.Процесс.Завершить();
							Процессы.Удалить(элПроцесс.Ключ);
							Прервать;
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;

		КонецЕсли;

		Попытка
			Соединение = TCPСервер.ОжидатьСоединения(Таймаут);
			Соединение.ТаймаутОтправки = 50;
			Соединение.ТаймаутЧтения = 20;
		Исключение
			ПустойЦикл = ПустойЦикл + 1;
			Продолжить;
		КонецПопытки;

		Попытка
			ТекстовыеДанныеВходящие	= Соединение.ПрочитатьСтроку();
		Исключение
			ТекстовыеДанныеВходящие = "";
		КонецПопытки;

		Если ТекстовыеДанныеВходящие = "" Тогда
			Если НЕ Соединение = Неопределено Тогда
				Соединение.Закрыть();
			КонецЕсли;
			ПустойЦикл = ПустойЦикл + 1;
			Продолжить;
		КонецЕсли;

		РабочийЦикл = РабочийЦикл + 1;
		Запрос	= Неопределено;

		Если Лев(ТекстовыеДанныеВходящие, 6) = "procid" Тогда
			//Сообщить(ТекстовыеДанныеВходящие);
			Попытка
				ПроцессЗапрос = СтрокуВСтруктуру(ТекстовыеДанныеВходящие);
				структПроцесс = Процессы.Получить(ПроцессЗапрос.procid);
				структПроцесс.Вставить("Соединение", Соединение);
			Исключение
				Соединение.Закрыть();
				Соединение = Неопределено;
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
			Соединение = Неопределено;
			Продолжить;
		КонецЕсли;

		Если Лев(ТекстовыеДанныеВходящие, 4) = "<!--" Тогда
			taskid = Сред(ТекстовыеДанныеВходящие, 5, 10);
			taskid = Лев(taskid, СтрНайти(taskid, "-->")-1);
			Задача = Задачи.Получить(taskid);
			Если НЕ Задача = Неопределено Тогда
				Задача.Результат = ТекстовыеДанныеВходящие;
				Пока НЕ Прав(ТекстовыеДанныеВходящие, 6) = "end-->" Цикл
					Попытка
						ТекстовыеДанныеВходящие	= Соединение.ПрочитатьСтроку();
						Задача.Результат = Задача.Результат + ТекстовыеДанныеВходящие;
					Исключение
						Прервать;
					КонецПопытки;
				КонецЦикла;
			КонецЕсли;
			Соединение.Закрыть();
			Соединение = Неопределено;
			Продолжить;
		КонецЕсли;

		Если Лев(ТекстовыеДанныеВходящие, 4) = "osdb" Тогда
			Попытка
				Соединение.ОтправитьСтроку(ОбработатьДанные(СтрокуВСтруктуру(ТекстовыеДанныеВходящие)));
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
			Соединение.Закрыть();
			Соединение = Неопределено;
			Продолжить;
		КонецЕсли;

		Попытка
			Запрос = РазобратьЗапросКлиента(ТекстовыеДанныеВходящие);
			ОбработатьЗапросКлиента(Запрос, Соединение);
		Исключение
			Сообщить(СокрЛП(ТекущаяДата())+ " " + ОписаниеОшибки());
			Сообщить("Ошибка обработки запроса:");
			Сообщить(ТекстовыеДанныеВходящие);
			Попытка
				Соединение.ОтправитьСтроку("непонятно...");
			Исключение
			КонецПопытки;
			Соединение.Закрыть();
		КонецПопытки;

		Соединение = Неопределено;

	КонецЦикла;

	ЗавершитьВсеПроцессы();

КонецПроцедуры

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
