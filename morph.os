сл = Новый ТекстовыйДокумент;
сл.Прочитать("dict.opcorpora.txt");
Сообщить("Прочитал!");

нсл = Неопределено;
нф = Неопределено;

нфс = Новый Соответствие;

инд = Новый Соответствие;

Для н = 1 по 1000 Цикл //сл.КоличествоСтрок() Цикл

	стр = сл.ПолучитьСтроку(н);

	Если стр = "" Тогда
		нсл = Неопределено;
		нф = Неопределено;
	ИначеЕсли нсл = Неопределено Тогда
		нсл = стр;
	Иначе
		Если нф = Неопределено Тогда
			нф = стр;
			нфс.Вставить(нсл, нф);
		КонецЕсли;
		мс = стрРазделить(стр, Символы.Таб);
		ф = инд.Получить(мс[1]);
		Если ф = Неопределено Тогда
			ф = Новый Соответствие;
			инд.Вставить(мс[1], ф);
		КонецЕсли;
		слф = мс[0];
		к = стрДлина(слф);
		Пока к > 0 Цикл
			бс = Сред(слф, к, 1);
			б = ф.Получить(бс);
			Если б = Неопределено Тогда
				б = Новый Соответствие;
				ф.Вставить(бс, б);
			КонецЕсли;
			ф = б;
			к = к - 1;
		КонецЦикла;
		ф.Вставить("нсл", нсл);
	КонецЕсли;

КонецЦикла;

слф = "ЕЖИХУ";

Для каждого мор Из инд Цикл

	//Сообщить(мор.Ключ);
	ф = мор.Значение;

	к = стрДлина(слф);
	Пока к > 0 Цикл
		бс = Сред(слф, к, 1);
		б = ф.Получить(бс);
		Если б = Неопределено Тогда
			Прервать;
		КонецЕсли;
		ф = б;
		к = к - 1;
	КонецЦикла;

	//Сообщить(к);

	Если НЕ б = Неопределено Тогда
		Сообщить(нфс.Получить(б.Получить("нсл")));
	КонецЕсли;

КонецЦикла;

ф.Вставить("нсл", нсл);
