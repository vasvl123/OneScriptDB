// MIT License
// Copyright (c) 2019 Vladimir Vasiliev
// https://github.com/vasvl123/OneScriptDB


Перем ИмяФайлаДанных;
Перем КаталогФайловДанных Экспорт;
Перем ПотокДанных;
Перем ВремяИзменения Экспорт;


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


// открыть контейнер для чтения или записи
Функция ОткрытьПотокДанных(ДляЗаписи = Ложь, Позиция = Неопределено) Экспорт

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

			ПотокДанных.Перейти(0, ПозицияВПотоке.Конец);

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


// Получить заголовки из контейнера
Функция ПолучитьЗаголовки() Экспорт

	ОткрытьПотокДанных();

	Если ПотокДанных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	Индекс = 0;
	Результат = Новый Структура();

	ПозицияДанных = ПотокДанных.Размер();

	Пока ПозицияДанных > 12 Цикл

		ПотокДанных.Перейти(ПозицияДанных - 12, ПозицияВПотоке.Начало);

		Буфер = Новый БуферДвоичныхДанных(8);
		ПотокДанных.Прочитать(Буфер, 0, 8);
		ПозицияДанных = Буфер.ПрочитатьЦелое64(0);

		Буфер = Новый БуферДвоичныхДанных(4);
		ПотокДанных.Прочитать(Буфер, 0, 4);
		ТипДанных = Буфер.ПрочитатьЦелое32(0);

		Если ТипДанных = 1 Тогда // Заголовок
			дЗаголовок = ПолучитьДанные(ПозицияДанных);
			Результат.Вставить("З" + Индекс, ДвоичныеДанныеВСтруктуру(дЗаголовок));
			Индекс = Индекс + 1;
		КонецЕсли;

	КонецЦикла;

	Возврат Результат;

КонецФункции // ПолучитьЗаголовки()


// найти заголовок по условиям
Функция НайтиЗаголовок(ЗапросДанных) Экспорт

	Перем СвойствоЗначение, ПозицияДанных, УсловияОтбора, Позиция, ЧислоЗаписей;

	ОткрытьПотокДанных();

	Если ПотокДанных = Неопределено Тогда
		Возврат "ОшибкаПотокаДанных";
	КонецЕсли;

	ЗапросДанных.Свойство("УсловияОтбора", УсловияОтбора);
	Если ТипЗнч(УсловияОтбора) = Тип("Структура") Тогда
		Если НЕ УсловияОтбора.Количество() Тогда
			УсловияОтбора = Неопределено;
		КонецЕсли;
	Иначе
		УсловияОтбора = Неопределено;
	КонецЕсли;

	ЗапросДанных.Свойство("ПозицияДанных", ПозицияДанных);

	Если ПозицияДанных = Неопределено Тогда
		ЗапросДанных.Свойство("НачальнаяПозицияДанных", ПозицияДанных);
	КонецЕсли;

	Если НЕ ПозицияДанных = Неопределено Тогда
		ПозицияДанных = Число(ПозицияДанных);
	Иначе
		ПозицияДанных = ПотокДанных.Размер();
	КонецЕсли;

	Если НЕ ЗапросДанных.Свойство("Позиция", Позиция) Тогда
		Позиция = 0;
	КонецЕсли;
	Если НЕ ЗапросДанных.Свойство("ЧислоЗаписей", ЧислоЗаписей) Тогда
		ЧислоЗаписей = 1;
	КонецЕсли;

	Позиция = Число(Позиция);
	ЧислоЗаписей = Число(ЧислоЗаписей);

	ЗаголовокНайден = Ложь;

	ВремяНачало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ЗаписейПрочитано = 0;

	Результат = "ЗапросВыполняется";

	Пока ПозицияДанных > 12 Цикл

		ПотокДанных.Перейти(ПозицияДанных - 12, ПозицияВПотоке.Начало);

		Буфер = Новый БуферДвоичныхДанных(8);
		ПотокДанных.Прочитать(Буфер, 0, 8);
		ПозицияДанных = Буфер.ПрочитатьЦелое64(0);

		Буфер = Новый БуферДвоичныхДанных(4);
		ПотокДанных.Прочитать(Буфер, 0, 4);
		ТипДанных = Буфер.ПрочитатьЦелое32(0);

		ЗаписейПрочитано = ЗаписейПрочитано + 1;

		Если ТипДанных = 1 Тогда // Заголовок

			дЗаголовок = ПолучитьДанные(ПозицияДанных);
			Заголовок = ДвоичныеДанныеВСтруктуру(дЗаголовок);

			// возвращает первое совпадение
			Если НЕ УсловияОтбора = Неопределено Тогда
				ЗаголовокНайден = Ложь;
				Для каждого элУсловия Из УсловияОтбора Цикл
					Если Заголовок.Свойство(элУсловия.Ключ, СвойствоЗначение) Тогда
						Если элУсловия.Значение.Сравнение = "Равно" Тогда
							ЗаголовокНайден = (СвойствоЗначение = элУсловия.Значение.Значение);
						КонецЕсли;
						Если НЕ ЗаголовокНайден Тогда
							Прервать;
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			Иначе
				ЗаголовокНайден = Истина;
			КонецЕсли;

			Если ЗаголовокНайден Тогда
				Позиция = Позиция + 1;
				ЗапросДанных.Вставить("Заголовок", Заголовок);
				Прервать;
			КонецЕсли;

		КонецЕсли;

		// превышение времени ожидания ответа
		Если ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяНачало > 100 Тогда
			Прервать;
		КонецЕсли;

	КонецЦикла;

	ЗапросДанных.Вставить("Позиция", Позиция);
	ЗапросДанных.Вставить("ЗаголовокНайден", ЗаголовокНайден);

	ЗапросДанных.Вставить("ВремяПоиска", ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяНачало);
	ЗапросДанных.Вставить("ЗаписейПрочитано", ЗаписейПрочитано);

	ЗапросДанных.Вставить("ПозицияДанных", ПозицияДанных);

	Если НЕ Число(ПозицияДанных) > 12 ИЛИ Позиция = ЧислоЗаписей Тогда
		Результат = "ЗапросЗавершен";
		Если ЗапросДанных.Свойство("Обновление") Тогда
			Если ЗапросДанных.Обновление = "Авто" Тогда
				Результат = "ЗапросПриостановлен";
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Возврат Результат;

КонецФункции


// не используется пока сравнение двоичных данных дает неверные результаты
// найти заголовок по ключу
Функция НайтиКлюч(Ключ) Экспорт

	ОткрытьПотокДанных();

	Если ПотокДанных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	ДанныеНайти = ПолучитьДвоичныеДанныеИзСтроки(Ключ);
	ОбъемДанных = ДанныеНайти.Размер();
	БуферНайти = Новый БуферДвоичныхДанных(ОбъемДанных);

	ПозицияДанных = ПотокДанных.Размер();

	Результат = Новый Структура("Результат", "ЗаголовокНеНайден");
	//Сообщить(ДанныеНайти);

	Пока ПозицияДанных > 12 Цикл

		ПотокДанных.Перейти(ПозицияДанных - 12, ПозицияВПотоке.Начало);

		Буфер = Новый БуферДвоичныхДанных(8);
		ПотокДанных.Прочитать(Буфер, 0, 8);
		ПозицияДанных = Буфер.ПрочитатьЦелое64(0);

		Буфер = Новый БуферДвоичныхДанных(4);
		ПотокДанных.Прочитать(Буфер, 0, 4);
		ТипДанных = Буфер.ПрочитатьЦелое32(0);

		Если ТипДанных = 1 Тогда // Заголовок

			ПотокДанных.Перейти(ПозицияДанных + 4, ПозицияВПотоке.Начало);
			ПотокДанных.Прочитать(БуферНайти, 0, ОбъемДанных);

			Если ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(БуферНайти) = ДанныеНайти Тогда
				дЗаголовок = ПолучитьДанные(ПозицияДанных);
				Результат.Вставить("Результат", "ЗаголовокНайден");
				Результат.Вставить("Заголовок", дЗаголовок);
				Возврат Результат;
			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

	Возврат Результат;

КонецФункции


// получить данные из контейнера и записать в файл
Функция ПолучитьФайл(Позиция) Экспорт

	ИмяФайла = ОбъединитьПути(КаталогФайловДанных, Позиция);

	ФайлДанных = Новый Файл(ИмяФайла);

	Если НЕ ФайлДанных.Существует() Тогда

		Попытка

			ОткрытьПотокДанных(Ложь, Позиция);

			Буфер = Новый БуферДвоичныхДанных(4);
			ПотокДанных.Прочитать(Буфер, 0, 4);
			ОбъемДанных = Буфер.ПрочитатьЦелое32(0);

			Буфер = Новый БуферДвоичныхДанных(ОбъемДанных);
			ПотокДанных.Прочитать(Буфер, 0, ОбъемДанных);

			ДанныеФайла = ФайловыеПотоки.ОткрытьДляЗаписи(ИмяФайла);
			ДанныеФайла.Записать(Буфер, 0, ОбъемДанных);

			ДанныеФайла.Закрыть();

		Исключение

			Сообщить(ОписаниеОшибки());
			Возврат Ложь;

		КонецПопытки

	КонецЕсли;

	Возврат Истина;

КонецФункции


// Получить двоичные данные из контейнера
Функция ПолучитьДанные(Позиция) Экспорт

	ОткрытьПотокДанных(Ложь, Позиция);

	Буфер = Новый БуферДвоичныхДанных(4);
	ПотокДанных.Прочитать(Буфер, 0, 4);
	ОбъемДанных = Буфер.ПрочитатьЦелое32(0);

	Буфер = Новый БуферДвоичныхДанных(ОбъемДанных);
	ПотокДанных.Прочитать(Буфер, 0, ОбъемДанных);

	Возврат ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(Буфер);

КонецФункции


// добавить в контейнер заголовок с файлом или без
Функция ДобавитьДанные(Заголовок, дДанные = Неопределено) Экспорт

	Перем ИмяФайла, ТипДанных;

	ОткрытьПотокДанных(Истина);

	ПозицияДанных = ПотокДанных.ТекущаяПозиция();

	Если Заголовок.Свойство("ТипДанных", ТипДанных) И НЕ дДанные = Неопределено Тогда
		Заголовок.Вставить("ОбъемДанных", ЗаписатьДанные(дДанные, Число(ТипДанных)));
		Заголовок.Вставить("ПозицияДанных", ПозицияДанных);
	КонецЕсли;

	Заголовок.Вставить("Дата", "" + ТекущаяДата());

	дЗаголовок = СтруктуруВДвоичныеДанные(Заголовок);

	ЗаписатьДанные(дЗаголовок);

	Возврат ПозицияДанных;

КонецФункции


// добавить содержимое файла в контейнер
Функция ЗаписатьДанныеФайла(ИмяФайла)

	ПозицияДанных = ПотокДанных.ТекущаяПозиция();

	ДанныеФайла = ФайловыеПотоки.ОткрытьДляЧтения(ИмяФайла);
	ОбъемДанных = ДанныеФайла.Размер();

	Буфер = Новый БуферДвоичныхДанных(4);
	Буфер.ЗаписатьЦелое32(0, ОбъемДанных);
	ПотокДанных.Записать(Буфер, 0, 4);

	ДанныеФайла.КопироватьВ(ПотокДанных);
	ДанныеФайла.Закрыть();

	Буфер = Новый БуферДвоичныхДанных(8);
	Буфер.ЗаписатьЦелое64(0, ПозицияДанных);
	ПотокДанных.Записать(Буфер, 0, 8);

	ТипДанных = 2; // 2 = файл

	Буфер = Новый БуферДвоичныхДанных(4);
	Буфер.ЗаписатьЦелое32(0, ТипДанных);
	ПотокДанных.Записать(Буфер, 0, 4);

	ПотокДанных.СброситьБуферы();

	Возврат ОбъемДанных;

КонецФункции


// добавить двоичные данные в контейнер
Функция ЗаписатьДанные(дДанные, ТипДанных = 1)

	ПозицияДанных = ПотокДанных.ТекущаяПозиция();

	ОбъемДанных = дДанные.Размер();

	Буфер = Новый БуферДвоичныхДанных(4);
	Буфер.ЗаписатьЦелое32(0, ОбъемДанных);
	ПотокДанных.Записать(Буфер, 0, 4);

	Буфер = ПолучитьБуферДвоичныхДанныхИзДвоичныхДанных(дДанные);
	ПотокДанных.Записать(Буфер, 0, ОбъемДанных);

	Буфер = Новый БуферДвоичныхДанных(8);
	Буфер.ЗаписатьЦелое64(0, ПозицияДанных);
	ПотокДанных.Записать(Буфер, 0, 8);

	Буфер = Новый БуферДвоичныхДанных(4);
	Буфер.ЗаписатьЦелое32(0, ТипДанных); // 1 = заголовок
	ПотокДанных.Записать(Буфер, 0, 4);

	ПотокДанных.СброситьБуферы();

	Возврат ОбъемДанных;

КонецФункции


Функция ПриСозданииОбъекта(ЗначИмяФайлаДанных);
	ИмяФайлаДанных = ОбъединитьПути(ТекущийКаталог(), "data", ЗначИмяФайлаДанных  + ".osdb");
	КаталогФайловДанных = ОбъединитьПути(ТекущийКаталог(), "data", ЗначИмяФайлаДанных  + ".files");
	Файл = Новый Файл(ИмяФайлаДанных);
	Если НЕ Файл.Существует() Тогда
		Файл = Новый ТекстовыйДокумент;
		Файл.Записать(ИмяФайлаДанных);
		СоздатьКаталог(КаталогФайловДанных);
		Файл = Новый Файл(ИмяФайлаДанных);
	КонецЕсли;
	ВремяИзменения = Файл.ПолучитьВремяИзменения();
КонецФункции
