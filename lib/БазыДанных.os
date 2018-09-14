// MIT License
// Copyright (c) 2018 Vladimir Vasiliev
// https://github.com/vasvl123/OneScriptDB


Функция СписокБаз(Данные, Параметр) Экспорт
	Узел = Данные.НовыйУзел(Новый Структура("Имя", "Список"), Истина);
	родУзел = Узел;
	СписокБаз = НайтиФайлы(ОбъединитьПути(ТекущийКаталог(), "data"), "*.osdb", Истина);
	Если СписокБаз.Количество() Тогда
		Для каждого БазаДанных Из СписокБаз Цикл
			стрУзел = Новый Структура("Имя, Значение", "Строка", БазаДанных.ИмяБезРасширения);
			Если Узел.Имя = "Список" Тогда
				Узел = Данные.НовыйДочерний(Узел, стрУзел, Истина);
			Иначе
				Узел = Данные.НовыйСоседний(Узел, стрУзел, Истина);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Возврат родУзел;
КонецФункции


Функция СписокДанных(Данные, Параметр) Экспорт
	БазаДанных = Параметр[0];
	ИндексИмя = ОбъединитьПути(ТекущийКаталог(), "data", БазаДанных + ".files", "index");
	Индекс = Новый Файл(ИндексИмя);
	Если НЕ Индекс.Существует() Тогда
		Соединение = Неопределено;
		Данные.ПередатьСтроку(Соединение, "osdb	" + БазаДанных);
		Попытка
			Соединение.ПрочитатьСтроку();
			Соединение.Закрыть();
		Исключение
			Сообщить(ОписаниеОшибки());
			Возврат Неопределено;
		КонецПопытки;
	КонецЕсли;
	Индекс = Новый ТекстовыйДокумент;
	Индекс.Прочитать(ИндексИмя);
	Узел = Данные.НовыйУзел(Новый Структура("Имя", "Ссылка"), Истина);
	родУзел = Узел;
	Узел = Данные.НовыйДочерний(Узел, Новый Структура("Имя", "Список"), Истина);
	Для н = 1 По Индекс.КоличествоСтрок() Цикл
		нУзел = Данные.СтрокуВСтруктуру(Индекс.ПолучитьСтроку(н));
		стрУзел = Новый Структура("Имя, Значение", "Строка", нУзел.data);
		Если Узел.Имя = "Список" Тогда
			Узел = Данные.НовыйДочерний(Узел, стрУзел, Истина);
		Иначе
			Узел = Данные.НовыйСоседний(Узел, стрУзел, Истина);
		КонецЕсли;
		Данные.НовыйАтрибут(Узел, Новый Структура("Имя, Значение", "ПозицияДанных", нУзел.dataposition), Истина);
		Данные.НовыйАтрибут(Узел, Новый Структура("Имя, Значение", "Размер", нУзел.length), Истина);
		Данные.НовыйАтрибут(Узел, Новый Структура("Имя, Значение", "ВремяИзменения", "" + Данные.УзелСвойство(нУзел, "date")), Истина);
	КонецЦикла;
	Возврат родУзел;
КонецФункции


Функция СписокФайлов(Данные, Параметр) Экспорт
	Узел = Данные.НовыйУзел(Новый Структура("Имя", "Ссылка"), Истина);
	родУзел = Узел;
	Узел = Данные.НовыйДочерний(Узел, Новый Структура("Имя", "Список"), Истина);
	СписокФайлов = НайтиФайлы(ОбъединитьПути(ТекущийКаталог(), "data", ".files"), "*.*", Истина);
	Если СписокФайлов.Количество() Тогда
		Для каждого элФайл Из СписокФайлов Цикл
			стрУзел = Новый Структура("Имя, Значение", "Строка", элФайл.Имя);
			Если Узел.Имя = "Список" Тогда
				Узел = Данные.НовыйДочерний(Узел, стрУзел, Истина);
			Иначе
				Узел = Данные.НовыйСоседний(Узел, стрУзел, Истина);
			КонецЕсли;
			Данные.НовыйАтрибут(Узел, Новый Структура("Имя, Значение", "Размер", элФайл.Размер()), Истина);
			Данные.НовыйАтрибут(Узел, Новый Структура("Имя, Значение", "ВремяИзменения", элФайл.ПолучитьВремяИзменения()), Истина);
		КонецЦикла;
	КонецЕсли;
	Возврат родУзел;
КонецФункции
