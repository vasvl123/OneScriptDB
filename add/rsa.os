// Источник http://maintenance.kz/?q=node/9
// немного переделано

Функция Степень(знОсн, знПок)
	Осн = Число(знОсн);
	Пок = Число(знПок);
	Рез = Осн;
	Пока Пок > 1 Цикл
		Рез = Рез * Осн;
		Пок = Пок - 1;
	КонецЦикла;
	Возврат Рез;
КонецФункции // Степень()

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

// Функция проверяет является ли проверяемое число простым.
// Тест простоты (Перебор делителей).
// Параметры:
// 	- натуральное число.
// Возврат:
// 	- ИСТИНА - если число является простым.
Функция ТестПростоты(ЧислоДляПроверки)
	Индекс = 2;
	Признак = 0;
	Пока ((Индекс * Индекс) <= ЧислоДляПроверки) Цикл
		Если ЧислоДляПроверки%Индекс = 0 Тогда
			Возврат Ложь;
		КонецЕсли;
		Индекс = Индекс + 1;
	КонецЦикла;
	Возврат Истина;
КонецФункции

// Функция возвращает случайное простое число в заданном диапазоне.
// Параметры:
// 	- НижнийДиапазон - нижняя граница диапазона;
// 	- ВерхнийДиапазон - верхняя граница диапазона.
// Возврат:
// 	- случайное простое число.
Функция ПолучитьПростоеЧисло(НижнийДиапазон, ВерхнийДиапазон, НачальноеЗначение)
	ГСЧ = Новый ГенераторСлучайныхЧисел(НачальноеЗначение);
	СлучайноеЧисло = ГСЧ.СлучайноеЧисло(НижнийДиапазон, ВерхнийДиапазон);
	Пока Не ТестПростоты(СлучайноеЧисло) Цикл
		СлучайноеЧисло = ГСЧ.СлучайноеЧисло(НижнийДиапазон, ВерхнийДиапазон);
	КонецЦикла;
	НачальноеЗначениеи = ГСЧ.СлучайноеЧисло(НижнийДиапазон, ВерхнийДиапазон);
	Возврат СлучайноеЧисло;
КонецФункции

// Функция вычсляет взаимно простое число к заданному числу (Алгоритм Евклида).
// Параметры:
// 	- ЧислоОснова - число являющееся основой для поиска взаимно простых чисел.
// 	- ЧислоПоиска - число от которого начинается поиск взаимно простого числа.
// Возврат:
// 	- структура с взаимно простым числом и обратное число по модулю.
Функция ПолучитьВзаимноПростыеЧисла(ЧислоОснова, ЧислоПоиска)
	СтруктураВозврата = Новый Структура;

	Пока ЧислоПоиска < ЧислоОснова Цикл
		НаибольшийОбщийДелитель = 0;
		Делимое = ЧислоОснова;
		Делитель = ЧислоПоиска;
		Остаток = ЧислоПоиска;

		// Из соотношения Безу.
		АльфаМинус2 = 1;
		АльфаМинус1 = 0;

		ВитаМинус2 = 0;
		ВитаМинус1 = 1;

		Пока Остаток > 0 Цикл
			Частное = Делимое/Делитель;
			Остаток = Делимое - Делитель * Цел(Частное);

			Альфа = АльфаМинус2 - Цел(Частное) * АльфаМинус1;
			Вита = ВитаМинус2 - Цел(Частное) * ВитаМинус1;

			Если Остаток > 0 Тогда
				Делимое = Делитель;
				Делитель = Остаток;
			Иначе
				НаибольшийОбщийДелитель = Делитель;
			КонецЕсли;

			АльфаМинус2 = АльфаМинус1;
			АльфаМинус1 = Альфа;

			ВитаМинус2 = ВитаМинус1;
			ВитаМинус1 = Вита;
		КонецЦикла;

		Если НаибольшийОбщийДелитель = 1 И ВитаМинус2 > 0 Тогда //
			СтруктураВозврата.Вставить("НОД", ЧислоПоиска);
			СтруктураВозврата.Вставить("Вита", ВитаМинус2);

			Возврат СтруктураВозврата;
		КонецЕсли;

		ЧислоПоиска = ЧислоПоиска + 1;
	КонецЦикла;

	Возврат ПолучитьВзаимноПростыеЧисла(ЧислоОснова, Цел(ЧислоПоиска/2));

КонецФункции


// Функция формирует закрытый и открытый ключ.
// Возврат:
// 	- структура с набором ключей, открытый-(e, n) и закрытый-(d, n).
Функция СформироватьКлючи() Экспорт

	// Управление разрядностью ключа
	ВерхняяГраница = 100;
	НижняяГраница = 32;

	// p
	ЧастьПи = ПолучитьПростоеЧисло(НижняяГраница, ВерхняяГраница, ТекущаяДата());
	// q
	ЧастьКью = ЧастьПи;
	Пока ЧастьКью = ЧастьПи Цикл
		ЧастьКью = ПолучитьПростоеЧисло(НижняяГраница, ВерхняяГраница, ТекущаяДата());
	КонецЦикла;

	// n
	ЧастьЭн = ЧастьПи * ЧастьКью;


	// Вычисляем функцию Эйлера.
	ЗначениеЭйлера = (ЧастьПи - 1) * (ЧастьКью - 1);

	// Вычисляем случайное взаимно простое чисело.
	ГСЧ = Новый ГенераторСлучайныхЧисел(ЗначениеЭйлера);
	СлучайноеЧисло = ГСЧ.СлучайноеЧисло(1, ЗначениеЭйлера);

	// e, d
	СтруктураЗначений = ПолучитьВзаимноПростыеЧисла(ЗначениеЭйлера, СлучайноеЧисло);
	ЧастьЕ = СтруктураЗначений.НОД;
	ЧастьД = СтруктураЗначений.Вита;

	// Собираем готовые ключи
	СтруктураВозврата = Новый Структура;
	СтруктураКлюча = Новый Структура;
	СтруктураКлюча.Вставить("ЧастьЕ", ЧастьЕ);
	СтруктураКлюча.Вставить("ЧастьЭн", ЧастьЭн);
	СтруктураВозврата.Вставить("ОткрытыйКлюч", СтруктуруВСтроку(СтруктураКлюча));
	СтруктураКлюча = Новый Структура;
	СтруктураКлюча.Вставить("ЧастьЭн", ЧастьЭн);
	СтруктураКлюча.Вставить("ЧастьД", ЧастьД);
	СтруктураВозврата.Вставить("ЗакрытыйКлюч", СтруктуруВСтроку(СтруктураКлюча));

	Возврат СтруктураВозврата;

КонецФункции


// Функция шифрует текст с использованием открытого ключа.
// Параметры:
// 	- текст подлежащий шифрованию;
// 	- открытый ключ.
// Возврат:
// 	- шифротекст в виде строки чисел через ";".
Функция Шифрование(ШифруемыйТекст, ОткрытыйКлюч) Экспорт
	СтрокаВозврата = "";
	СтруктураКлюча = СтрокуВСтруктуру(ОткрытыйКлюч);

	Для Индекс = 1 По СтрДлина(ШифруемыйТекст) Цикл
		Код = КодСимвола(ШифруемыйТекст, Индекс);
		Степень = Степень(Код, СтруктураКлюча.ЧастьЕ);
		Шифрокод = Степень - СтруктураКлюча.ЧастьЭн * Цел(Степень / СтруктураКлюча.ЧастьЭн);

		СтрокаВозврата = СтрокаВозврата + Шифрокод + ";"
	КонецЦикла;

	Возврат СтрокаВозврата;

КонецФункции


// Функция дешифрует текст с использованием закрытого ключа.
// Параметры:
// 	- шифротекст;
// 	- закрытый ключ.
// Возврат:
// 	- дешифрованный текст.
Функция Дешифрование(Шифротекст, ЗакрытыйКлюч) Экспорт
	СтрокаВозврата = "";
	СтруктураКлюча = СтрокуВСтруктуру(ЗакрытыйКлюч);

	СтрШифрокод = "";
	Для Индекс = 1 По СтрДлина(Шифротекст) Цикл
		Если Сред(Шифротекст, Индекс, 1) = ";" Тогда
			Шифрокод = Число(СтрШифрокод);
			Степень = Степень(Шифрокод, СтруктураКлюча.ЧастьД);
			Код = Степень - СтруктураКлюча.ЧастьЭн * Цел(Степень / СтруктураКлюча.ЧастьЭн);

			СтрокаВозврата = СтрокаВозврата + Символ(Код);
			СтрШифрокод = "";
		Иначе
			Если Не Сред(Шифротекст, Индекс, 1) = " " Тогда
				СтрШифрокод = СтрШифрокод + Сред(Шифротекст, Индекс, 1);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат СтрокаВозврата;

КонецФункции

Ключи = СформироватьКлючи();
Сообщить(Ключи.ОткрытыйКлюч);

Сообщить(Шифрование("123", Ключи.ОткрытыйКлюч));
