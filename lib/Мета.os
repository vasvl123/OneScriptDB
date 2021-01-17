// MIT License
// Copyright (c) 2020 vasvl123
// https://github.com/vasvl123/useyourmind


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


Процедура ОбработатьОтвет(Действие, Данные, Свойства, Результат) Экспорт

	Если Действие = "Элементы" Тогда

		Свойства.Вставить("Элементы", Результат.Элементы);

	КонецЕсли;

	Данные.ОбъектыОбновитьДобавить(Свойства.Родитель);
	Свойства.Родитель.Вставить("Обновить", Неопределено);

КонецПроцедуры


Функция Справочник_Свойства(Данные, оУзел) Экспорт

	Свойства = оУзел.Дочерний;
	Если Свойства = Неопределено Тогда // новый объект
		Свойства = Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
		шСвойства = "
		|База
		|Имя
		|Представление
		|";
		Данные.СоздатьСвойства(Свойства, шСвойства);
	КонецЕсли;
	шСвойства = "
	|*События
	|*Показать: Нет
	|*Кнопка
	|*Вид
	|	З: Кнопка
	|	: Если
	|		З: Показать
	|		ul
	|			П: Содержимое
	|";
	Данные.СоздатьСвойства(Свойства, шСвойства, "Только");
	оУзел.Вставить("Свойства", Свойства);

КонецФункции

Функция Справочник_Модель(Данные, Свойства, Изменения) Экспорт

	оУзел = Свойства.Родитель;

	// обработать события
	Если Изменения.Получить(Свойства.д.События) = Истина Тогда
		дУзел = Свойства.д.События.Дочерний;
		Если НЕ дУзел = Неопределено Тогда
			мСобытие = СтрРазделить(дУзел.Значение, Символы.Таб);
			тСобытие = мСобытие[0];
			Если тСобытие = "ПриНажатии" Тогда
				Если Свойства.д.Показать.Значение = "Да" Тогда
					Свойства.д.Показать.Значение = "Нет";
				Иначе
					Свойства.д.Показать.Значение = "Да";
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Данные.УдалитьУзел(дУзел);
		Изменения.Вставить(Свойства.д.События, Истина);
	КонецЕсли;

	Если Свойства.д.Показать.Значение = "Да" Тогда
		Если НЕ Свойства.Свойство("Элементы") Тогда
			// получить элементы справочника
			Запрос = Новый Структура("Библиотека, Данные, Параметры, Свойства, вДействие, cmd", ЭтотОбъект, Данные, Новый Структура("База, Имя", Свойства.д.База.Значение, Свойства.д.Имя.Значение), Свойства, "Элементы", "ВнешниеДанные");
			Данные.Процесс.НоваяЗадача(Запрос, "Служебный");
		Иначе // элементы загружены
			д = Свойства;
			Для каждого эл из Свойства.Элементы Цикл
				д = Данные.НовыйСоседний(д, ИмяЗначение("О", "Мета.Элемент"), Истина);
				д.Вставить("Элемент", эл);
			КонецЦикла;
			Свойства.Удалить("Элементы");
		КонецЕсли;
	КонецЕсли;

	// сформировать представление
	ш = "<button id='_" + оУзел.Код + "' type='button' class='text-left btn1 btn-secondary' onclick='addcmd(this,event); return false' role='sent'>.текст</button>";
	см = ?(Свойства.д.Показать.Значение = "Нет", "&#9655;", "&#9661;");
	Вид = СтрЗаменить(ш, ".текст", см);
	Вид = "<div class='btn-group' role='group'>" + Вид + СтрЗаменить(ш, ".текст", Свойства.д.Имя.Значение) + "</div>";

	Свойства.д.Кнопка.Значение = Вид;

КонецФункции


Функция Элемент_Свойства(Данные, оУзел) Экспорт

	Свойства = оУзел.Дочерний;
	Если Свойства = Неопределено Тогда // новый объект
		Свойства = Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
	КонецЕсли;
	шСвойства = "
	|База
	|Ид
	|Код
	|Наименование
	|*События
	|*Показать: Нет
	|*Кнопка
	|*Вид
	|	З: Кнопка
	|	: Если
	|		З: Показать
	|		ul
	|			П: Содержимое
	|";
	Данные.СоздатьСвойства(Свойства, шСвойства, "Только");
	оУзел.Вставить("Свойства", Свойства);

	// получить элемент справочника
	Запрос = Новый Структура("Библиотека, Данные, Параметры, Свойства, вДействие, cmd", ЭтотОбъект, Данные, Новый Структура("Позиция, База", Свойства.д.Позиция.Значение, Свойства.д.База.Значение), Свойства, "Элемент", "Морфология");
	Данные.Процесс.НоваяЗадача(Запрос, "Служебный");

КонецФункции


Функция Элемент_Модель(Данные, Свойства, Изменения) Экспорт

	оУзел = Свойства.Родитель;

	// обработать события
	Если Изменения.Получить(Свойства.д.События) = Истина Тогда
		дУзел = Свойства.д.События.Дочерний;
		Если НЕ дУзел = Неопределено Тогда
			мСобытие = СтрРазделить(дУзел.Значение, Символы.Таб);
			тСобытие = мСобытие[0];
			Если тСобытие = "ПриНажатии" Тогда
				Если Свойства.д.Показать.Значение = "Да" Тогда
					Свойства.д.Показать.Значение = "Нет";
				Иначе
					Свойства.д.Показать.Значение = "Да";
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Данные.УдалитьУзел(дУзел);
		Изменения.Вставить(Свойства.д.События, Истина);
	КонецЕсли;

	Если Свойства.д.Показать.Значение = "Да" Тогда
		Если Свойства.Свойство("Элементы") Тогда
			д = Свойства;
			зн = "";
			н = 1;
			Для каждого зн из Свойства.Элементы Цикл
				д = Данные.НовыйСоседний(д, ИмяЗначение("О", "Сем.Элемент"), Истина);
				Данные.НовыйАтрибут(д, ИмяЗначение("Позиция", зн), Истина);
				Данные.НовыйАтрибут(д, ИмяЗначение("База", Свойства.д.База.Значение), Истина);
				н = н + 1;
			КонецЦикла;
			Свойства.Удалить("Элементы");
		КонецЕсли;
	КонецЕсли;

	Если Свойства.д.Элемент.Значение = "" Тогда
		Свойства.д.Элемент.Значение = Свойства.д.Номер.Значение;
	КонецЕсли;

	// сформировать представление
	ш = "<button id='_" + оУзел.Код + "' type='button' class='text-left btn1 btn-secondary' onclick='addcmd(this,event); return false' role='sent'>.текст</button>";
	см = ?(Свойства.д.Показать.Значение = "Нет", "&#9655;", "&#9661;");
	Вид = СтрЗаменить(ш, ".текст", см);
	Вид = "<div class='btn-group' role='group'>" + Вид + СтрЗаменить(ш, ".текст", Свойства.д.Элемент.Значение) + "</div>";

	Свойства.д.Кнопка.Значение = Вид;

КонецФункции
