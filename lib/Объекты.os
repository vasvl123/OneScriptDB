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


Функция ИмяЗначение(Имя, Значение)
	Возврат Новый Структура("Имя, Значение", Имя, Значение);
КонецФункции


Функция НоваяФорма(Имя)
	Возврат "
	|Форма.
	|	name: '" + Имя + "'
	|	form: 'box'
	|	role: 'thing'
	|	movable: true
	|	color: 0x555555
	|	transparent: true
	|	opacity: 0.3
	|	position_x: 0
	|	position_y: 0
	|	position_z: 0
	|	scale_x: 2
	|	scale_y: 2
	|	scale_z: 2
	|";
КонецФункции // НоваяФорма()


Функция Субъект_Свойства() Экспорт
	Возврат "
	|События
	|" + НоваяФорма("Субъект") + "
	|	camera_x: 0
	|	camera_y: 50
	|	camera_z: 100
	|	role: 'player'
	|";
КонецФункции


Функция Предмет_Свойства() Экспорт
	Возврат "
	|События
	|" + НоваяФорма("Предмет");
КонецФункции


Функция Комната_Свойства() Экспорт
	Возврат "
	|События
	|" + НоваяФорма("Комната") + "
	|	role: 'room'
	|	movable: false
	|";
КонецФункции


Функция Кнопка_Свойства() Экспорт
	Возврат "
	|События
	|Текст
	|Вид
	|	button	class=btn btn-primary	onclick=addcmd(this); return false	type=button
	|		Значение: Текст
	|";
КонецФункции


Функция Надпись_Свойства() Экспорт
	Возврат "
	|События
	|Текст
	|Вид
	|";
КонецФункции


// Выполнить
Функция Выполнить_Свойства() Экспорт
	Возврат "
	|События
	|Условие
	|Тогда
	|Иначе
	|Результат
	|";
КонецФункции

Функция Выполнить_Модель(Данные, Свойства, Изменения) Экспорт
	Если Изменения.Получить(Свойства.д.Условие) = Истина ИЛИ Изменения.Получить(Свойства.Родитель) = Истина Тогда
		Условие = Данные.ЗначениеСвойства(Свойства.д.Условие);
		Если Условие Тогда
			Результат = Данные.ЗначениеСвойства(Свойства.д.Тогда);
		Иначе
			Результат = Данные.ЗначениеСвойства(Свойства.д.Иначе);
		КонецЕсли;
		Данные.НовоеЗначениеУзла(Свойства.д.Результат, ИмяЗначение("" + ТипЗнч(Результат), Результат), Истина);
		Изменения.Вставить(Свойства.д.Результат, Истина);
	КонецЕсли;
	Возврат Изменения;
КонецФункции


// Источник данных
Функция ИсточникДанных_Свойства() Экспорт
	Возврат "
	|События
	|ЗапросДанных.
	|	БазаДанных
	|	УсловияОтбора
	|	Обновление: Авто
	|	ЧислоЗаписей: 10
	|	СписокПолей.
	|	Команда: НайтиЗаголовок
	|	Задача
	|Записи.
	|";
КонецФункции

Функция ИсточникДанных_Модель(Данные, Свойства, Изменения) Экспорт
	Если Данные.ЗначениеСвойства(Свойства.д.ЗапросДанных.д.Задача) = "" Тогда
		Запрос = Новый Структура("Данные, Узел, ЗапросДанных, cmd", Данные, Свойства.д.Записи, Данные.СвойстваВСтуктуру(Свойства.д.ЗапросДанных), "ЗапросДанных");
		ИдЗадачи = Данные.Процесс.НоваяЗадача(Запрос, "Служебный");
		Данные.НовоеЗначениеУзла(Свойства.д.ЗапросДанных.д.Задача, ИмяЗначение("Строка", ИдЗадачи), Истина);
		Изменения.Вставить(Свойства.д.ЗапросДанных.д.Задача, Истина);
	КонецЕсли;
	Возврат Изменения;
КонецФункции


// СтрокаТаблицы
Функция СтрокаТаблицы_Свойства() Экспорт
	Возврат "
	|События
	|Источник
	|Поля
	|Вид
	|	tr
	|		Значение: Содержимое
	|";
КонецФункции

Функция СтрокаТаблицы_Модель(Данные, Свойства, Изменения) Экспорт
	Если Изменения.Получить(Свойства.д.Источник) = Истина Тогда
	КонецЕсли;

	// Конструктор
	Если Изменения.Получить(Свойства.Родитель) = Истина Тогда
		УзелПоля = Данные.ЗначениеСвойства(Свойства.д.Поля); // получить узел по ссылке
		Поля = Данные.СтруктураСвойств(УзелПоля);
		Источник = Данные.ЗначениеСвойства(Свойства.д.Источник); // получить узел по ссылке
		Узел = Свойства;
		Для каждого элПоле Из Поля.д Цикл
			свПоле = Данные.СтруктураСвойств(элПоле.Значение);
			Шаблон = УзелСвойство(свПоле.д, "Шаблон");
			Если НЕ Шаблон = Неопределено Тогда
				стрУзел = Данные.КопироватьВетку(Данные.Дочерний(Шаблон), , Узел, Узел);
			Иначе
				Поле = элПоле.Ключ;
				ПолеЗначение = УзелСвойство(Источник.Значение, Поле);
				стрУзел = ИмяЗначение("td", ПолеЗначение);
			КонецЕсли;
			Узел = Данные.НовыйСоседний(Узел, стрУзел, Истина);
		КонецЦикла;
	КонецЕсли;

	Возврат Изменения;
КонецФункции


// Таблица
Функция Таблица_Свойства() Экспорт
	Возврат "
	|События
	|СвойстваСтроки.
	|СписокПолей.
	|ИсточникСтрок
	|Вид
	|	table
	|		Значение: Содержимое
	|";
КонецФункции

Функция Таблица_Модель(Данные, Свойства, Изменения) Экспорт

	УзелСвойства = Свойства;
	УзелЗаголовок = Данные.Соседний(УзелСвойства);

	// Конструктор
	Если Изменения.Получить(Свойства.Родитель) = Истина Тогда
		Если УзелЗаголовок = Неопределено Тогда // создать заголовок
			УзелЗаголовок = Данные.НовыйСоседний(УзелСвойства, ИмяЗначение("thread",  ""), Истина);
			Узел = Данные.НовыйДочерний(УзелЗаголовок, ИмяЗначение("tr",  ""), Истина);
			Для каждого элПоле Из Свойства.д.СписокПолей.д Цикл
				Поле = элПоле.Значение;
				стрУзел = ИмяЗначение("th", Данные.ЗначениеСвойства(Поле.д.Заголовок));
				Если Узел.Имя = "tr" Тогда
					Узел = Данные.НовыйДочерний(Узел, стрУзел, Истина);
				Иначе
					Узел = Данные.НовыйСоседний(Узел, стрУзел, Истина);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;

	ИсточникСтрок = Данные.ЗначениеСвойства(Свойства.д.ИсточникСтрок);

	Если Изменения.Получить(Свойства.д.ИсточникСтрок) = Истина Тогда
		Строки = Новый Соответствие;
		Пока НЕ УзелЗаголовок = Неопределено Цикл
			УзелСтроки = УзелЗаголовок;
			Строки.Вставить(УзелСтроки.Значение, "");
			УзелЗаголовок = Данные.Соседний(УзелЗаголовок);
		КонецЦикла;
		// добавить строки
		Если НЕ ИсточникСтрок = Неопределено Тогда
			ИсточникСтрок = Данные.Дочерний(ИсточникСтрок);
			Пока НЕ ИсточникСтрок = Неопределено Цикл
				ИмяСтроки = "СтрокаТаблицы " + ИсточникСтрок.Имя;
				Если Строки.Получить(ИмяСтроки) = Неопределено Тогда
					УзелСтроки = Данные.НовыйСоседний(УзелСтроки, ИмяЗначение("О", ИмяСтроки), Истина);
					СвойстваСтроки = Данные.ОбработатьОбъект(УзелСтроки);
					// дополнительные свойства
					Если Свойства.д.Свойство("СвойстваСтроки") Тогда
						Узел = Данные.Дочерний(СвойстваСтроки);
						Пока НЕ Узел = Неопределено Цикл
							стСвойстваСтроки = Узел;
							Узел = Данные.Соседний(Узел);
						КонецЦикла;
						Для каждого элСвойство Из Свойства.д.СвойстваСтроки.д Цикл
							свУзел = Данные.КопироватьВетку(ЭлСвойство.Значение, , стСвойстваСтроки, СвойстваСтроки);
							стСвойстваСтроки = Данные.НовыйСоседний(стСвойстваСтроки, свУзел, Истина);
						КонецЦикла;
					КонецЕсли;
					Данные.НовоеЗначениеУзла(СвойстваСтроки.д.Источник, ИмяЗначение("Указатель", ИсточникСтрок.Код), Истина);
					Данные.НовоеЗначениеУзла(СвойстваСтроки.д.Поля, ИмяЗначение("Указатель", Свойства.д.СписокПолей.Код), Истина);
				КонецЕсли;
				ИсточникСтрок = Данные.Соседний(ИсточникСтрок);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;

	Возврат Изменения;
КонецФункции
