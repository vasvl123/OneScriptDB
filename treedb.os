// /*----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------*/

Перем ИмяФайлаДанных;
Перем ПотокДанных;


Функция МассивИзСтроки(стр) Экспорт
	м = Новый Массив();
	дстр = СтрДлина(стр);
	Для н = 1 По дстр Цикл
		м.Добавить(КодСимвола(Сред(стр, н, 1)));
	КонецЦикла;
	Возврат м;
КонецФункции // МассивИзСтроки()


// открыть контейнер для чтения или записи
Функция ОткрытьПотокДанных(ДляЗаписи = Ложь, Позиция = Неопределено)

	Попытка

		Если ДляЗаписи Тогда

			Если НЕ ПотокДанных = Неопределено Тогда
				Если НЕ ПотокДанных.ДоступнаЗапись Тогда
					ПотокДанных.Закрыть();
					ПотокДанных = Неопределено;
				КонецЕсли;
			КонецЕсли;

			Если ПотокДанных = Неопределено Тогда
				ПотокДанных = ФайловыеПотоки.ОткрытьДляЗаписи(ИмяФайлаДанных);
			КонецЕсли;

			Если Позиция = Неопределено Тогда
				ПотокДанных.Перейти(0, ПозицияВПотоке.Конец);
			Иначе
				ПотокДанных.Перейти(Позиция, ПозицияВПотоке.Начало);
			КонецЕсли;

			ВремяИзменения = ТекущаяДата();

		Иначе

			Если НЕ ПотокДанных = Неопределено Тогда
				Если НЕ ПотокДанных.ДоступноЧтение Тогда
					ПотокДанных.Закрыть();
					ПотокДанных = Неопределено;
				КонецЕсли;
			КонецЕсли;

			Если ПотокДанных = Неопределено Тогда
				ПотокДанных = ФайловыеПотоки.ОткрытьДляЧтения(ИмяФайлаДанных);
			КонецЕсли;

			Если НЕ Позиция = Неопределено Тогда
				ПотокДанных.Перейти(Позиция, ПозицияВПотоке.Начало);
			КонецЕсли;

		КонецЕсли;

		Возврат Истина;

	Исключение

		Возврат Ложь;

	КонецПопытки;

КонецФункции


Функция ДобавитьЗначение(гр, Знач н = 0) Экспорт

	// пройти по дереву
	ОткрытьПотокДанных();
	буф = Новый БуферДвоичныхДанных(16);

	// н = 0;
	к = 1;
	рн = 0;

	сгр = гр.Количество();

	Если НЕ ПотокДанных.Размер() = 0 Тогда

		Пока Истина Цикл
			ф = гр.Получить(к - 1);
			Пока Истина Цикл
				ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
				ПотокДанных.Прочитать(буф, 0, 16);
				ф1 = буф.ПрочитатьЦелое32(0);
				нн = буф.ПрочитатьЦелое32(4); // позиция следующего
				Если ф1 = ф ИЛИ ф = 0 Тогда  // найден элемент
					рн = н;
					к = к + 1;
					Если НЕ к > сгр Тогда
						нн = буф.ПрочитатьЦелое32(8); // позиция вложенного
						Если нн = 0 Тогда // создать ссылку на вложенный
							ОткрытьПотокДанных(Истина);
							кн = ПотокДанных.Размер();
							буф.ЗаписатьЦелое32(8, кн); // вложенный в конец
							ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
							ПотокДанных.Записать(буф, 0, 14);
							//ПотокДанных.СброситьБуферы();
						КонецЕсли;
					КонецЕсли;
					Прервать;
				КонецЕсли;
				нн = буф.ПрочитатьЦелое32(4); // позиция следующего
				Если нн = 0 Тогда // это последний
					ОткрытьПотокДанных(Истина);
					кн = ПотокДанных.Размер();
					буф.ЗаписатьЦелое32(4, кн); // соседний в конец
					ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
					ПотокДанных.Записать(буф, 0, 16);
					//ПотокДанных.СброситьБуферы();
					Прервать;
				КонецЕсли;
				н = нн;
			КонецЦикла;
			Если нн = 0 ИЛИ к > сгр Тогда
				Прервать;
			КонецЕсли;
			н = нн;
		КонецЦикла;

	КонецЕсли;

	Если НЕ к > сгр Тогда

		// создать новые элементы
		ОткрытьПотокДанных(Истина);

		Для к = к по сгр Цикл
			ф = гр.Получить(к - 1);
			ПотокДанных.Перейти(0, ПозицияВПотоке.Конец);
			н = ПотокДанных.ТекущаяПозиция();
			Если НЕ к = сгр Тогда
				кн = н + 16;
			Иначе
				кн = 0;
			КонецЕсли;
			буф.ЗаписатьЦелое32(0, ф); // код символа
			буф.ЗаписатьЦелое32(4, 0); // нет соседнего
			буф.ЗаписатьЦелое32(8, кн); // вложенный в конец
			буф.ЗаписатьЦелое32(12, рн); // родитель
			ПотокДанных.Записать(буф, 0, 16);
			рн = н;
		КонецЦикла;

		ПотокДанных.СброситьБуферы();

	КонецЕсли;

	Возврат н;

КонецФункции // ДобавитьЗначение()


Функция ПолучитьЭлемент(Знач н) Экспорт
	буф = Новый БуферДвоичныхДанных(16);
	эл = Новый Структура;
	ОткрытьПотокДанных();
	ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
	ПотокДанных.Прочитать(буф, 0, 16);
	эл.Вставить("Значение", буф.ПрочитатьЦелое32(0));
	эл.Вставить("Соседний", буф.ПрочитатьЦелое32(4));
	эл.Вставить("Дочерний", буф.ПрочитатьЦелое32(8));
	эл.Вставить("Родитель", буф.ПрочитатьЦелое32(12));
	Возврат эл;
КонецФункции // ПолучитьЭлемент()


Функция ПолучитьЗначения(Знач н) Экспорт
	буф = Новый БуферДвоичныхДанных(16);
	мр = Новый Массив;
	Пока Истина Цикл
		Если н = 0 Тогда
			Прервать;
		КонецЕсли;
		ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
		ПотокДанных.Прочитать(буф, 0, 16);
		ф = буф.ПрочитатьЦелое32(0);
		сн = буф.ПрочитатьЦелое32(4);
		мф = Новый Массив;
		мф.Добавить(ф);
		мф.Добавить(н);
		мр.Добавить(мф);
		н = сн;
	КонецЦикла;
	Возврат мр;
КонецФункции


Функция ПолучитьВложенныеЗначения(Знач н) Экспорт
	буф = Новый БуферДвоичныхДанных(16);
	ОткрытьПотокДанных();
	ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
	ПотокДанных.Прочитать(буф, 0, 16);
	вн = буф.ПрочитатьЦелое32(8); // позиция вложенного
	Возврат ПолучитьЗначения(вн);
КонецФункции // ПолучитьВложенныеЗначения()


Функция ПолучитьСтроку(Знач н) Экспорт

	гр = "";
	буф = Новый БуферДвоичныхДанных(16);

	ОткрытьПотокДанных();

	Пока Истина Цикл
		ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
		ПотокДанных.Прочитать(буф, 0, 16);
		ф = буф.ПрочитатьЦелое32(0);
		н = буф.ПрочитатьЦелое32(12); // позиция родителя
		Если н = 0 Тогда // это первый
			Прервать;
		КонецЕсли;
		гр = Символ(ф) + гр;
	КонецЦикла;

	Возврат гр;

КонецФункции // ПолучитьСтроку()


Функция НайтиЗначение(нгр, Знач н = 0) Экспорт

	буф = Новый БуферДвоичныхДанных(16);

	ОткрытьПотокДанных();

	Если НЕ н = 0 Тогда // искать внутри
		ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
		ПотокДанных.Прочитать(буф, 0, 16);
		н = буф.ПрочитатьЦелое32(8); // позиция вложенного
		Если н = 0 Тогда
			Возврат н;
		КонецЕсли;
	КонецЕсли;

	// Если НЕ ТипЗнч(нгр) = Тип("Массив") Тогда
	// 	зн = нгр;
	// 	нгр = Новый Массив;
	// 	нгр.Добавить(зн);
	// КонецЕсли;

	сгр = нгр.Количество();

	// пройти по дереву

	к = 1;

	Пока Истина Цикл
		ф = нгр.Получить(к - 1);
		Пока Истина Цикл
			ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
			ПотокДанных.Прочитать(буф, 0, 16);
			ф1 = буф.ПрочитатьЦелое32(0);
			Если ф1 = ф ИЛИ ф = 42 Тогда  // найден элемент
				Если ф = 42 Тогда // *
					Если ф1 = нгр.Получить(к + 1) Тогда
						к = к + 1;
					КонецЕсли;
				Иначе
					к = к + 1;
				КонецЕсли;
				Если НЕ к > сгр Тогда
					н = буф.ПрочитатьЦелое32(8); // позиция вложенного
				КонецЕсли;
				Прервать;
			КонецЕсли;
			н = буф.ПрочитатьЦелое32(4); // позиция следующего
			Если н = 0 ИЛИ к > сгр Тогда // это последний
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если н = 0 ИЛИ к > сгр Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат н;

КонецФункции // НайтиЗначение()


Функция УдалитьЗначение(Знач н) Экспорт

	буф = Новый БуферДвоичныхДанных(16);

	ОткрытьПотокДанных();
	ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
	ПотокДанных.Прочитать(буф, 0, 16);
	сн = буф.ПрочитатьЦелое32(4); // позиция соседнего
	рн = буф.ПрочитатьЦелое32(12); // позиция родителя

	ПотокДанных.Перейти(рн, ПозицияВПотоке.Начало);
	ПотокДанных.Прочитать(буф, 0, 16);
	нн = буф.ПрочитатьЦелое32(8); // позиция дочернего

	Если нн = н Тогда // если это первый дочерний
		ОткрытьПотокДанных(Истина);
		буф.ЗаписатьЦелое32(8, сн);
		ПотокДанных.Перейти(рн, ПозицияВПотоке.Начало);
		ПотокДанных.Записать(буф, 0, 16);
		ПотокДанных.СброситьБуферы();

	Иначе // перебрать остальные

		Пока Истина Цикл
			ПотокДанных.Перейти(нн, ПозицияВПотоке.Начало);
			ПотокДанных.Прочитать(буф, 0, 16);
			пс = буф.ПрочитатьЦелое32(4); // позиция следующего
			Если пс = н Тогда // найден элемент
				ОткрытьПотокДанных(Истина);
				буф.ЗаписатьЦелое32(4, сн);
				ПотокДанных.Перейти(нн, ПозицияВПотоке.Начало);
				ПотокДанных.Записать(буф, 0, 16);
				ПотокДанных.СброситьБуферы();
				Прервать;
			КонецЕсли;
			Если пс = 0 Тогда
				Прервать;
			КонецЕсли;
			нн = пс;
		КонецЦикла;

	КонецЕсли;

КонецФункции // УдалитьЗначение()


Функция Закрыть() Экспорт
	Если НЕ ПотокДанных = Неопределено Тогда
		ПотокДанных.Закрыть();
	КонецЕсли;
КонецФункции // Закрыть()


Функция ПриСозданииОбъекта(ЗначИмяФайлаДанных);
	ИмяФайлаДанных = ЗначИмяФайлаДанных;
	Файл = Новый Файл(ИмяФайлаДанных);
	Если НЕ Файл.Существует() Тогда
		Файл = Новый ТекстовыйДокумент;
		Файл.Записать(ИмяФайлаДанных);
	КонецЕсли;
КонецФункции
