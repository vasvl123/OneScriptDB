// Контроллер системный
Перем Шаблон;
Перем НомерФрейма;
Перем ИмяКонтроллера Экспорт;
Перем ТаблицаФайлов;

Функция Transliterate(srtRusWord)
	strRUS = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";
	strENG = "A///B///V///G///D///E///YO//ZH//Z///I///Y///K///L///M///N///O///P///R///S///T///U///F///KH//TS//CH//SH//SHCH'///Y///////E///YU//JA//";
	strResult = "";
	Для i = 1 по СтрДлина(srtRusWord) Цикл
		s = Сред(srtRusWord, i,1);
		s=ВРег(s);
		k = Найти(strRUS, s);
		Если k = 0 тогда
			strResult = strResult + s;
		Иначе
			strResult = strResult + СтрЗаменить(Сред(strENG, (k - 1) * 4 + 1, 4), "/", "");
		КонецЕсли
	КонецЦикла ;
	Возврат strResult;
КонецФункции 

Процедура Сканировать(Запрос,Ответ)
	
	Перем ИскатьВПапке;

	Если Запрос.Заголовок.Получить("Method") = "POST" Тогда
		POSTДанные = Запрос.Заголовок.Получить("POSTData");
		ИскатьВПапке = POSTДанные.path;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ИскатьВПапке) Тогда
		Ответ.ТекстОтвета = Ответ.ТекстОтвета + "Не выбран каталог поиска";
		Возврат;
	КонецЕсли; 
	
	ИскатьВПодкаталогах = Истина;
	
	Файлы = НайтиФайлы(ИскатьВПапке, "*", ИскатьВПодкаталогах);	
	
	ТаблицаФайлов = Новый ТаблицаЗначений;
	ТаблицаФайлов.Колонки.Добавить("КодФайла", "Число", 6);
	ТаблицаФайлов.Колонки.Добавить("ПутьКФайлу", "Строка");
	ТаблицаФайлов.Колонки.Добавить("ИмяФайла", "Строка");
	ТаблицаФайлов.Колонки.Добавить("Размер", "Число", 12);
	ТаблицаФайлов.Колонки.Добавить("Длина", "Число", 3);
	ТаблицаФайлов.Колонки.Добавить("Ранг", "Число", 3);
	
	КодФайла = 0;
	
	Для каждого Файл Из Файлы Цикл
	
		КодФайла = КодФайла + 1;
		
		НовыйФайл = ТаблицаФайлов.Добавить();
		НовыйФайл.КодФайла = КодФайла;
		НовыйФайл.ПутьКФайлу = Файл.Путь;
		НовыйФайл.ИмяФайла = Файл.Имя;
		НовыйФайл.Длина = СтрДлина(Файл.Имя);
		Попытка
			Если НЕ Файл.ЭтоФайл() Тогда
				Продолжить;
			КонецЕсли;  
			Размер = Файл.Размер();
			Если Размер >= 1073741824  Тогда
				НовыйФайл.Размер = Формат(Размер / 1073741824, "ЧДЦ=1") + "&nbsp;Гб";
			ИначеЕсли Размер >= 1048576 Тогда
				НовыйФайл.Размер = Формат(Размер / 1048576, "ЧДЦ=1") + "&nbsp;Мб";
			ИначеЕсли Размер >= 1024 Тогда
				НовыйФайл.Размер = Формат(Размер / 1024, "ЧДЦ=1") + "&nbsp;Кб";
			Иначе	
				НовыйФайл.Размер = "" + Размер + "&nbsp;б";
			КонецЕсли; 
		Исключение	
			//Сообщить(ОписаниеОшибки());
		КонецПопытки;
	
	КонецЦикла; 
	
	Ответ.ТекстОтвета = Ответ.ТекстОтвета + "Найдено " + ТаблицаФайлов.Количество() + " файлов";

	Ответ.ТекстОтвета = Ответ.ТекстОтвета + Шаблон.ПолучитьОбласть("ОбластьФорма2");
	
КонецПроцедуры

Процедура НайтиНаСервере(Запрос,Ответ)
	
	Перем СтрокаПоискаФайла;
	
	УчитыватьДлину = Истина;
	Транслит = Ложь;
	
	Если Запрос.Заголовок.Получить("Method") = "POST" Тогда
		POSTДанные = Запрос.Заголовок.Получить("POSTData");
		СтрокаПоискаФайла = POSTДанные.str;
	КонецЕсли;
	
	СтрокаПоиска = Лев(СтрокаПоискаФайла, 300);
	
	Если Транслит Тогда
		СтрокаПоиска = Нрег(Transliterate(СтрокаПоиска));
	КонецЕсли;
	
	ДлинаСтроки = СтрДлина(СтрокаПоиска);

	Если НЕ ДлинаСтроки > 2 Тогда
		Ответ.ТекстОтвета = Ответ.ТекстОтвета + "Короткая строка поиска";
		Возврат;	
	КонецЕсли;

	НачалоЗамера = ТекущаяДата();

	Для каждого СтрокаФайл Из ТаблицаФайлов Цикл
		ДлинаИмяФайла = СтрДлина(СтрокаФайл.ИмяФайла);
		Ранг = 0;
		Для Индекс = 1 По ДлинаИмяФайла - 2 Цикл
			Если СтрНайти(СтрокаПоиска, Сред(СтрокаФайл.ИмяФайла, Индекс, 3)) Тогда
				Ранг = Ранг + 1; 
			КонецЕсли;
		КонецЦикла;
		Если УчитыватьДлину Тогда
			Если ДлинаИмяФайла > ДлинаСтроки Тогда
				Ранг = 100 * Ранг / (ДлинаИмяФайла - 2);
			Иначе
				Ранг = 100 * Ранг / (ДлинаСтроки - 2);
			КонецЕсли
		КонецЕсли;
		СтрокаФайл.Ранг = Ранг;
	КонецЦикла;
	
	ТаблицаФайлов.Сортировать("Ранг УБЫВ");
	
	КоличествоЗаписей = ТаблицаФайлов.Количество();
	ВремяВыполнения = ТекущаяДата() - НачалоЗамера + 1;
	
	Результат = "Время выполнения запроса: "+ ВремяВыполнения + " сек (" + Формат(КоличествоЗаписей / ВремяВыполнения, "ЧДЦ=0") + " стр/сек)<table><tr><td><b>Ранг</b></td><td><b>Имя файла<b></td><td><b>Размер<b></td><td><b>Путь к файлу<b></td></tr>";

	Для каждого Выборка из ТаблицаФайлов Цикл
		
		Если Выборка.Ранг = 0 Тогда
			Прервать;
		КонецЕсли; 
		
		Индекс = 1;
		НайденнаяСтрока = Выборка.ИмяФайла;
		
		Пока Индекс < ДлинаСтроки Цикл
			Длина = 2;
			Пока Индекс + Длина <= ДлинаСтроки Цикл
				Если Найти(НайденнаяСтрока, Сред(СтрокаПоиска, Индекс, Длина + 1)) > 0 Тогда
					Длина = Длина + 1;
				Иначе
					Прервать;
				КонецЕсли; 
			КонецЦикла; 
			Если Длина > 2 Тогда
				Подстрока = Сред(СтрокаПоиска, Индекс, Длина);
				НайденнаяСтрока = СтрЗаменить(НайденнаяСтрока, Подстрока, "<b>" + Подстрока + "</b>");
			Иначе
				Длина = 0;
			КонецЕсли; 
			Индекс = Индекс + Длина + 1;
		КонецЦикла;
		
		Результат = Результат + "<tr><td>";
		Результат = Результат + Цел(Выборка.Ранг);
		Результат = Результат + "</td><td style=""word-wrap:break-word;"">";
		Результат = Результат + НайденнаяСтрока;
		Результат = Результат + "</td><td>";		
		Результат = Результат + Выборка.Размер;
		Результат = Результат + "</td><td style=""word-wrap:break-word;"">";		
		Результат = Результат + Выборка.ПутьКФайлу;
		Результат = Результат + "</td></tr>";
		
	КонецЦикла;
	
	Ответ.ТекстОтвета = Ответ.ТекстОтвета +  Результат + "</table></body></html>";
	
КонецПроцедуры

Процедура Button(Запрос, Ответ)
	НомерФрейма = НомерФрейма + 1;
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяФрейма", "frame" + (НомерФрейма));
	Ответ.ТекстОтвета = "<html>" + Шаблон.ПолучитьОбласть("ОбластьТело", Параметры);
	Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьКнопка", Параметры));
	iFrame("", Запрос, Ответ);
	Ответ.Добавить("</body></html>");
КонецПроцедуры

Процедура iFrame(ИмяМетода, Запрос, Ответ)
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяФрейма", "frame" + (НомерФрейма));
	Параметры.Вставить("ИмяМетода", ИмяМетода);
	Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьФрейм", Параметры));
КонецПроцедуры

Процедура СоздатьФайлДанных(ИмяФайла)

    ЗаписьXML = Новый ЗаписьXML;
    ЗаписьXML.ОткрытьФайл(ИмяФайла);
    ЗаписьXML.ЗаписатьОбъявлениеXML();
    ЗаписьXML.ЗаписатьНачалоЭлемента("Root");
	ЗаписьXML.ЗаписатьАтрибут("Код", 0);
		ЗаписьXML.ЗаписатьНачалоЭлемента("Root1");
		ЗаписьXML.ЗаписатьАтрибут("Код", 1);
		ЗаписьXML.ЗаписатьКонецЭлемента(); //Root1
		ЗаписьXML.ЗаписатьНачалоЭлемента("Root2");
		ЗаписьXML.ЗаписатьАтрибут("Код", 2);
			ЗаписьXML.ЗаписатьНачалоЭлемента("Root3");
			ЗаписьXML.ЗаписатьАтрибут("Код", 3);
			ЗаписьXML.ЗаписатьКонецЭлемента(); //Root3
		ЗаписьXML.ЗаписатьКонецЭлемента(); //Root2
	ЗаписьXML.ЗаписатьКонецЭлемента(); //Root
    ЗаписьXML.Закрыть();

КонецПроцедуры

Процедура ДобавитьУзел(Узел, Ответ)
	КодТекущегоУзла = Узел.ЗначениеАтрибута("Код");
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяФрейма", "frame" + (КодТекущегоУзла));
	Параметры.Вставить("Метод", "root.xml?NodeID=" + КодТекущегоУзла);
	Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьКнопка", Параметры));
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяФрейма", "frame" + (КодТекущегоУзла));
	Параметры.Вставить("ИмяМетода", "");
	Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьФрейм", Параметры));
КонецПроцедуры

Процедура ПоказатьУзел(Запрос, Ответ)

	ИмяФайла = Запрос.ИмяМетода;

    Файл = Новый ЧтениеXML;
    Попытка
		Файл.ОткрытьФайл(ИмяФайла);
	Исключение
		СоздатьФайлДанных(ИмяФайла);
		Файл.ОткрытьФайл(ИмяФайла);
	КонецПопытки;

	КодУзла = "";
	GETДанные = Запрос.Заголовок.Получить("GETData");
	Если НЕ GETДанные.Свойство("NodeID", КодУзла) Тогда
		КодУзла = "0";
	КонецЕсли;

	УзелНайден = Ложь;

	Параметры = Новый Структура;
	Параметры.Вставить("ИмяФрейма", "frame" + (КодУзла));
	
    Пока Файл.Прочитать() Цикл
		Если Файл.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если УзелНайден Тогда
				ДобавитьУзел(Файл, Ответ);
				Файл.Пропустить();
				Продолжить;
			КонецЕсли;
			КодТекущегоУзла = Файл.ЗначениеАтрибута("Код");
			Если КодУзла = КодТекущегоУзла Тогда
				УзелНайден = Истина;
				Продолжить;
			КонецЕсли;			
		КонецЕсли;
		Если Файл.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если УзелНайден Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Файл.Закрыть();
	
КонецПроцедуры

Процедура Main(Запрос,Ответ)
	// Ответ.ТекстОтвета = Ответ.ТекстОтвета + Шаблон.ПолучитьОбласть("ОбластьФорма");
	
	КодТекущегоУзла = "0";
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяМетода", "Default/root.xml");
	Параметры.Вставить("ИмяФрейма", "frame" + (КодТекущегоУзла));
	Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьФрейм", Параметры));

КонецПроцедуры

Процедура Метод(Запрос, Ответ) Экспорт

	ИмяМетода = Запрос.ИмяМетода;
	Ответ.ТекстОтвета = Шаблон.ПолучитьОбласть("ОбластьШапка");
	Если Запрос.ИмяМетода = "Main" Тогда
		Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьМеню"));
		Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьСкрипт"));
		Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьТело"));
		Main(Запрос,Ответ);
	ИначеЕсли Запрос.ИмяМетода = "Button" Тогда
		Button(Запрос,Ответ);
	ИначеЕсли Запрос.ИмяМетода = "Scan" Тогда
		Сканировать(Запрос,Ответ);
	ИначеЕсли Запрос.ИмяМетода = "Search" Тогда
		НайтиНаСервере(Запрос,Ответ);
	ИначеЕсли Прав(Запрос.ИмяМетода, 4) = ".xml" Тогда
		Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьСкрипт"));
		Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьТело"));
		ПоказатьУзел(Запрос, Ответ);
	Иначе
		Ответ.Добавить("404");	
	КонецЕсли;
	Ответ.Добавить(Шаблон.ПолучитьОбласть("ОбластьПодвал"));
	
КонецПроцедуры

Процедура Инициализировать()
	Шаблон = Новый vHttpTemplate();
	Шаблон.ЗагрузитьМакет("simple");
	НомерФрейма = 0;
КонецПроцедуры

Инициализировать();