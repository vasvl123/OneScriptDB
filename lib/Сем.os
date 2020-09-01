// MIT License
// Copyright (c) 2020 vasvl123
// https://github.com/vasvl123/useyourmind

Перем Правила;


Функция УзелСвойство(Узел, Свойство) Экспорт
	УзелСвойство = Неопределено;
	Если НЕ Узел = Неопределено Тогда
		Узел.Свойство(Свойство, УзелСвойство);
	КонецЕсли;
	Возврат УзелСвойство;
КонецФункции // УзелСвойство(Узел)


Функция ИмяЗначение(Имя, Значение = "")
	Возврат Новый Структура("Имя, Значение", Имя, Значение);
КонецФункции


Функция Предложение_Свойства(Данные, оУзел) Экспорт

	Если Правила = Неопределено Тогда // Загрузить правила анализа
		Запрос = Новый Структура("sdata, data", Данные.Процесс.Источник, "semdata");
		Правила = Данные.Процесс.ПолучитьДанные(Новый Структура("Запрос", Запрос));
		Если Правила = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;

	Если НЕ оУзел.Свойство("Свойства") Тогда // новый объект
		Свойства = Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
		// шСвойства = "
		// |Формы.
		// |";
		// Данные.СоздатьСвойства(Свойства, шСвойства);
		оУзел.Вставить("Свойства", Свойства);
	КонецЕсли;

КонецФункции

Функция Предложение_Модель(Данные, Свойства, Изменения) Экспорт

	оУзел = Свойства.Родитель;
	Если НЕ УзелСвойство(оУзел, "Обновить") = Ложь Тогда

		пр = "";
		Если Свойства.д.Свойство("Текст", пр) Тогда
			пр = СтрЗаменить(пр, ".", " . ");
			пр = СтрЗаменить(пр, ",", " , ");
			пр = СтрЗаменить(пр, "!", " ! ");
			пр = СтрЗаменить(пр, "?", " ? ");
			пр = СтрЗаменить(пр, ":", " : ");
			пр = СтрЗаменить(пр, ";", " ; ");
			пр = СтрЗаменить(пр, "«", " « ");
			пр = СтрЗаменить(пр, "»", " » ");
			пр = СтрЗаменить(пр, """", " "" ");
			пр = СтрЗаменить(пр, "'", " ' ");
			м = СтрРазделить(пр, " ");
			Для каждого т Из м Цикл
				Если НЕ т = "" Тогда
					д = Данные.НовыйДочерний(Свойства.Родитель, ИмяЗначение("О", "Сем.Токен"), Данные.Служебный(оУзел), Истина);
					Данные.НовыйАтрибут(д, ИмяЗначение("Слово", т), Данные.Служебный(оУзел));
					Данные.ОбъектыОбновить.Вставить(д, Истина);
				КонецЕсли;
			КонецЦикла;
			оУзел.Вставить("Обновить", Ложь);
		КонецЕсли;
	КонецЕсли;

КонецФункции


Функция Токен_Свойства(Данные, оУзел) Экспорт

	Если НЕ оУзел.Свойство("Свойства") Тогда // новый объект
		Свойства = Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
		шСвойства = "
		|Формы
		|";
		Данные.СоздатьСвойства(Свойства, шСвойства);
		оУзел.Вставить("Свойства", Свойства);
	КонецЕсли;

КонецФункции

Функция Токен_Модель(Данные, Свойства, Изменения) Экспорт

	оУзел = Свойства.Родитель;
	Если НЕ УзелСвойство(оУзел, "Обновить") = Ложь Тогда
		сл = "";
		Если Свойства.д.Свойство("Слово", сл) Тогда
			Если НЕ (сл = "." ИЛИ сл = "," ИЛИ сл = "!" ИЛИ сл = "?" ИЛИ сл = ":" ИЛИ сл = ";" ИЛИ сл = "«" ИЛИ сл = "»" ИЛИ сл = """" ИЛИ сл = "'" ИЛИ сл = "-") Тогда
				Запрос = Новый Структура("Данные, Слова, Свойства, cmd", Данные, Свойства.д.Слово, Свойства, "ФормыСлов");
				Данные.Процесс.НоваяЗадача(Запрос, "Служебный");
				оУзел.Вставить("Обновить", Ложь);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецФункции
