Перем procid;
Перем Шаблон;
Перем Буфер;
Перем БуферУзел;
Перем События, ИдСобытия;
Перем Хост, Порт;
Перем Вкладки, ИдВкладки, ТекущаяВкладка;

Функция ПоказатьПанель()
	Текст = "";
	ПараметрыШаблона = Новый Структура;
	ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
	Для каждого элВкладка Из Вкладки Цикл
		Вкладка = элВкладка.Значение;
		ПараметрыШаблона.Вставить("ПараметрВкладка", элВкладка.Ключ);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "tabselect");
		ПараметрыШаблона.Вставить("ПараметрЗаголовок", Вкладка.Заголовок);
		ПараметрыШаблона.Вставить("ПараметрАктивный", ?(элВкладка.Ключ = ТекущаяВкладка, "active", ""));
		Текст = Текст + Шаблон.ПолучитьОбласть("ОбластьВкладка", ПараметрыШаблона);
		Если элВкладка.Ключ = ТекущаяВкладка Тогда
			ПараметрыШаблона.Вставить("ПараметрКоманда", "tabclose");
			ПараметрыШаблона.Вставить("ПараметрЗаголовок", "✕");
			Текст = Текст + Шаблон.ПолучитьОбласть("ОбластьВкладка", ПараметрыШаблона);
		КонецЕсли;
	КонецЦикла;
	ПараметрыШаблона.Вставить("ПараметрВкладка", "newtab");
	ПараметрыШаблона.Вставить("ПараметрКоманда", "newtab");
	ПараметрыШаблона.Вставить("ПараметрЗаголовок", "➕");
	ПараметрыШаблона.Вставить("ПараметрАктивный", "");
	Текст = Текст + Шаблон.ПолучитьОбласть("ОбластьВкладка", ПараметрыШаблона);
	Текст = Шаблон.ПолучитьОбласть("ОбластьПанель", Новый Структура("ПараметрВкладки", Текст));
	Возврат Текст;
КонецФункции // ПоказатьПанель()


Функция НоваяВкладка(структЗадача)
	Данные = Новый pagedata("datalisp.txt", Шаблон);
	ИдВкладки = ИдВкладки + 1;
	ТекущаяВкладка = "" + ИдВкладки;
	структВкладка = Новый Структура("ИдВкладки, Данные, Режим, ИдУзла, Заголовок", ТекущаяВкладка, Данные, "design", "316", "newpage");
	Вкладки.Вставить(ТекущаяВкладка, структВкладка);
	структЗадача.Вставить("Вкладка", структВкладка);
КонецФункции


Функция НачальнаяСтраница()
	Текст = Шаблон.ПолучитьОбласть("ОбластьШапка", Новый Структура("ПараметрИдПроцесса", procid));
	Текст = Текст + Шаблон.ПолучитьОбласть("ОбластьПодвал");
	Вкладки = Новый Соответствие;
	Возврат Текст;
КонецФункции


Функция СтрокуВСтруктуру(Стр)
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
	Для каждого Элемент Из Структ Цикл
		Результат = Результат + ?(Результат = "", "", Символы.Таб) + Элемент.Ключ + Символы.Таб + Элемент.Значение;
	КонецЦикла;
	Возврат Результат;
КонецФункции


Функция ПоказатьУзел(Вкладка, КодУзла, Уровень = "", ПервыйВызов = Истина) Экспорт

	Данные = Вкладка.Данные;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел " + КодУзла + " не найден!";
	КонецЕсли;

	Текст = Символы.ПС + Уровень;

	Если Узел.Имя = "#text" Тогда
		Если Узел.Свойство("Значение") Тогда
			Текст = Текст + Узел.Значение;
		Иначе
			Текст = "";
		КонецЕсли;
	ИначеЕсли Узел.Имя = "#comment" Тогда
		Если Узел.Свойство("Значение") Тогда
			Текст = Текст + "<!-- " + Узел.Значение + " -->";
		КонецЕсли;
	Иначе
		Текст = Текст + "<" + Узел.Имя;

		Атрибут = Неопределено;
		Если НЕ УзелСвойство(Узел, "Атрибут") = Неопределено Тогда
			Атрибут = Данные.ПолучитьУзел(Узел.Атрибут);
			Пока НЕ Атрибут = Неопределено Цикл
				АтрибутИмя = Атрибут.Имя;
				АтрибутИмя = СтрЗаменить(АтрибутИмя, "xml_lang", "xml:lang");
				АтрибутИмя = СтрЗаменить(АтрибутИмя, "_", "-");
				АтрибутЗначение = Атрибут.Значение;
				Текст = Текст + " " + АтрибутИмя + "=""" + АтрибутЗначение + """";
				Если Атрибут.Свойство("Соседний", Атрибут) Тогда
					Атрибут = Данные.ПолучитьУзел(Атрибут)
				КонецЕсли;
		    КонецЦикла;
		КонецЕсли;

		Текст = Текст + ">";
	КонецЕсли;

	Если НЕ УзелСвойство(Узел, "Дочерний") = Неопределено Тогда
		Текст = Текст + ПоказатьУзел(Вкладка, Узел.Дочерний, Уровень + Символы.Таб, Ложь);
	КонецЕсли;

	Если НЕ (Узел.Имя = "#text" ИЛИ Узел.Имя = "#comment") Тогда
		Если Узел.Свойство("Значение") Тогда
			Текст = Текст + Узел.Значение;
		КонецЕсли;
		Текст = Текст + Символы.ПС + Уровень + "</" + Узел.Имя + ">";
	КонецЕсли;

	Если НЕ ПервыйВызов Тогда
		Если НЕ УзелСвойство(Узел, "Соседний") = Неопределено Тогда
			Текст = Текст + ПоказатьУзел(Вкладка, Узел.Соседний, Уровень, Ложь);
		КонецЕсли;
	КонецЕсли;

	Возврат Текст;

КонецФункции // ПоказатьУзел()


Функция УзелПросмотр(Вкладка,  КодУзла) Экспорт

	Данные = Вкладка.Данные;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел " + КодУзла + " не найден!";
	КонецЕсли;

	Текст = "";

	УзелПросмотр = УзелСостояние(Узел, "УзелПросмотр");
	Если УзелПросмотр = Истина Тогда
		ПараметрПредставление = ПоказатьУзел(Вкладка, Узел.Код);
		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрПредставление", ПараметрПредставление);
		Текст = Шаблон.ПолучитьОбласть("ОбластьПросмотр", ПараметрыШаблона);
	КонецЕсли;

	Возврат Текст;

КонецФункции // УзелПросмотр()


Функция ПоказатьСтруктуруУзла(Вкладка, КодУзла, ПервыйВызов = Истина) Экспорт

	Представление = "";
	Атрибуты = "";

	Данные = Вкладка.Данные;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел " + КодУзла + " не найден!";
	КонецЕсли;

	УзелОткрыт = УзелСостояние(Узел, "УзелОткрыт");
	Если УзелОткрыт = Неопределено Тогда
		УзелОткрыт = Ложь;
	КонецЕсли;

	УзелИмя = Узел.Имя;

	УзелЗначение = "";
	Если Узел.Свойство("Значение") Тогда
		УзелЗначение = Узел.Значение;
	КонецЕсли;

	ГлУзелИзменить = УзелСвойство(Узел, "mainodedit");
	УзелРедактируется = УзелСостояние(Узел, "УзелРедактируется");
	РедактироватьЗначение = УзелСостояние(Узел, "РедактироватьЗначение");
	УзелПросмотр = УзелСостояние(Узел, "УзелПросмотр");
	этоАтрибут = УзелСвойство(Узел, "attr");

	Если этоАтрибут = Истина Тогда
		УзелИмя = СтрЗаменить(УзелИмя, "xml_lang", "xml:lang");
		УзелИмя = СтрЗаменить(УзелИмя, "_", "-");
	КонецЕсли;

	КнопкаУзел = "";

	Если НЕ УзелСвойство(Узел, "Дочерний") = Неопределено Тогда
		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
		ПараметрыШаблона.Вставить("ПараметрВкладка", Вкладка.ИдВкладки);
		ПараметрыШаблона.Вставить("ПараметрРежим", Вкладка.Режим);
		ПараметрыШаблона.Вставить("ПараметрКоманда", ?(УзелОткрыт, "nodeclose", "nodeopen"));
		ПараметрыШаблона.Вставить("ПараметрНадписьНаКнопке", ?(УзелОткрыт, "⚪" , "⚫"));
		КнопкаУзел = Шаблон.ПолучитьОбласть("ОбластьКнопкаУзел", ПараметрыШаблона);
	КонецЕсли;

	КнопкиИнструменты = "";
	ПараметрМенюИнструменты = "";

	Если УзелРедактируется = Истина Тогда

		Родитель = Данные.Родитель(Узел);
		Если Родитель = Неопределено Тогда
			Родитель = Узел;
		КонецЕсли;

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрНеактивно", "");
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
		ПараметрыШаблона.Вставить("ПараметрВкладка", Вкладка.ИдВкладки);
		ПараметрыШаблона.Вставить("ПараметрРежим", Вкладка.Режим);
		ПараметрыШаблона.Вставить("ПараметрВидимость", "");

		Если НЕ этоАтрибут = Истина Тогда
			ПараметрыШаблона.Вставить("ПараметрКоманда", ?(УзелПросмотр = Истина, "nopreview", "preview"));
			ПараметрыШаблона.Вставить("ПараметрПодсказка", ?(УзелПросмотр = Истина, "Скрыть", "Показать"));
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрКоманда", "attradd");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Новый атрибут");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрКоманда", "childadd");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Новый дочерний");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);
		КонецЕсли;

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Родитель.Код);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "nextadd");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Новый соседний");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		ПараметрыШаблона.Вставить("ПараметрКоманда", "nodecut");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вырезать узел");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "nodecopy");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Копировать узел");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		Если НЕ этоАтрибут = Истина Тогда
			ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Родитель.Код);
			ПараметрыШаблона.Вставить("ПараметрКоманда", "nodepasteattr");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вставить атрибут");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
			ПараметрыШаблона.Вставить("ПараметрКоманда", "nodepastechild");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вставить дочерний");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);
		КонецЕсли;

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Родитель.Код);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "nodepastenext");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вставить соседний");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		Если НЕ этоАтрибут = Истина Тогда
			ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
			ПараметрыШаблона.Вставить("ПараметрКоманда", "attremove");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Удалить все атрибуты");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрКоманда", "childremove");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Удалить все дочерние");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);
		КонецЕсли;

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Родитель.Код);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "noderemove");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Удалить узел");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрМенюИнструменты", ПараметрМенюИнструменты);
		КнопкиИнструменты = Шаблон.ПолучитьОбласть("ОбластьКнопкаИнструменты", ПараметрыШаблона);

	КонецЕсли;

	Если УзелСвойство(Узел, "namedit") = Истина Тогда

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
		ПараметрыШаблона.Вставить("ПараметрВкладка", Вкладка.ИдВкладки);
		ПараметрыШаблона.Вставить("ПараметрРежим", Вкладка.Режим);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "submitname");
		ПараметрыШаблона.Вставить("ПараметрИмяЗначение", УзелИмя);
		ПараметрИмя = Шаблон.ПолучитьОбласть("ОбластьИзменитьИмяЗначение", ПараметрыШаблона);

	Иначе

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрНеактивно", "");
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
		ПараметрыШаблона.Вставить("ПараметрВкладка", Вкладка.ИдВкладки);
		ПараметрыШаблона.Вставить("ПараметрРежим", Вкладка.Режим);
		ПараметрыШаблона.Вставить("ПараметрКоманда", ?(УзелРедактируется = Истина, "namedit", "nodedit"));
		ПараметрыШаблона.Вставить("ПараметрНадписьНаКнопке", УзелИмя);
		ПараметрИмя = Шаблон.ПолучитьОбласть("ОбластьКнопкаИмяЗначение", ПараметрыШаблона);

	КонецЕсли;

	Если РедактироватьЗначение = Истина Тогда

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
		ПараметрыШаблона.Вставить("ПараметрВкладка", Вкладка.ИдВкладки);
		ПараметрыШаблона.Вставить("ПараметрРежим", Вкладка.Режим);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "submitvalue");
		ПараметрыШаблона.Вставить("ПараметрИмяЗначение", УзелЗначение);
		ПараметрЗначение = Шаблон.ПолучитьОбласть("ОбластьИзменитьИмяЗначение", ПараметрыШаблона);

	ИначеЕсли НЕ УзелЗначение = "" ИЛИ (УзелРедактируется = Истина ИЛИ ГлУзелИзменить = Истина) Тогда

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрНеактивно", ?(УзелРедактируется = Истина, "", "disabled"));
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", procid);
		ПараметрыШаблона.Вставить("ПараметрВкладка", Вкладка.ИдВкладки);
		ПараметрыШаблона.Вставить("ПараметрРежим", Вкладка.Режим);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "valuedit");
		ПараметрыШаблона.Вставить("ПараметрНадписьНаКнопке", УзелЗначение);
		ПараметрЗначение = Шаблон.ПолучитьОбласть("ОбластьКнопкаИмяЗначение", ПараметрыШаблона);

	КонецЕсли;

	ПараметрыШаблона = Новый Структура;
	ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
	ПараметрыШаблона.Вставить("ПараметрИнструменты", КнопкиИнструменты);
	ПараметрыШаблона.Вставить("ПараметрИмя", ПараметрИмя);
	ПараметрыШаблона.Вставить("ПараметрЗначение", ПараметрЗначение);
	ПараметрИмяУзла = КнопкаУзел + Шаблон.ПолучитьОбласть("ОбластьИмяЗначение", ПараметрыШаблона);

	Если НЕ УзелСвойство(Узел, "Атрибут") = Неопределено Тогда
		УзелАтрибут = Данные.Атрибут(Узел);
		УзелАтрибут.Вставить("mainodedit", УзелРедактируется = Истина);
		УзелАтрибут.Вставить("attr", Истина);
		Атрибуты = ПоказатьСтруктуруУзла(Вкладка, Узел.Атрибут, Ложь);
	КонецЕсли;

	Если этоАтрибут = Истина Тогда
		Если НЕ УзелСвойство(Узел, "Соседний") = Неопределено Тогда
			УзелАтрибут = Данные.Соседний(Узел);
			УзелАтрибут.Вставить("mainodedit", ГлУзелИзменить = Истина);
			УзелАтрибут.Вставить("attr", Истина);
			ПараметрИмяУзла = ПараметрИмяУзла + ПоказатьСтруктуруУзла(Вкладка, Узел.Соседний, Ложь);
		КонецЕсли;

		Возврат ПараметрИмяУзла;
	КонецЕсли;

	ПараметрЗаголовокУзла = ПараметрИмяУзла + Атрибуты;

	ДочернийУзел = "";
	Если УзелОткрыт Тогда
		Если НЕ УзелСвойство(Узел, "Дочерний") = Неопределено Тогда
			ДочернийУзел = ПоказатьСтруктуруУзла(Вкладка, Узел.Дочерний, Ложь);
		КонецЕсли;
	КонецЕсли;

	Если УзелПросмотр = Истина Тогда
		ДочернийУзел = ДочернийУзел + УзелПросмотр(Вкладка, Узел.Код);
	КонецЕсли;

	ПараметрыШаблона = Новый Структура;
	ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
	ПараметрыШаблона.Вставить("ПараметрЗаголовокУзла", ПараметрЗаголовокУзла);
	ПараметрыШаблона.Вставить("ПараметрДочернийУзел", ДочернийУзел);
	Представление = Шаблон.ПолучитьОбласть("ОбластьУзел", ПараметрыШаблона);

	Если НЕ ПервыйВызов Тогда
		Если НЕ УзелСвойство(Узел, "Соседний") = Неопределено Тогда
				Представление = Представление + ПоказатьСтруктуруУзла(Вкладка, Узел.Соседний, Ложь);
		КонецЕсли;
	КонецЕсли;

	УзелСостояниеЗначение(Узел, "ОбновитьУзел", Ложь);

	Возврат Представление;

КонецФункции


Функция ОбработатьКоманду(структЗадача) Экспорт

	Запрос = структЗадача.Запрос;

	ДействиеИмя = Запрос.cmd;

	ДействиеИмя = СтрЗаменить(ДействиеИмя, "domupdate",		"ОбновитьDOM");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "nodeopen",		"ОткрытьУзел");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "nodeclose",		"ЗакрытьУзел");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "nodedit",		"РедактироватьУзел");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "preview",		"ПоказатьУзел");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "nopreview",		"СкрытьУзел");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "nodereload",	"ОбновитьУзел");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "newtab",		"НоваяВкладка");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "tabselect",		"ВыбратьВкладку");
	ДействиеИмя = СтрЗаменить(ДействиеИмя, "tabclose",		"ЗакрытьВкладку");

	структЗадача.Действие = Новый Структура("Имя, Результат", ДействиеИмя);
	Возврат "ВыполнитьДействия";


	Данные = структЗадача.Данные;
	КодУзла = Запрос.nodeid;
	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Сообщить ("Узел не найден!");
		Возврат "СформироватьОтвет";
	КонецЕсли;

	Если Запрос.cmd = "nodeopen" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "ОткрытьУзел", Узел);
		Если Запрос.mode = "lisp" Тогда
			Попытка
				Значение = Данные.Интерпретировать(Данные.Окружение, Узел);
			Исключение
				Значение = ОписаниеОшибки();
			КонецПопытки;
			Узел.Вставить("Значение", Значение);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "nodeclose" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "ЗакрытьУзел", Узел);
	ИначеЕсли Запрос.cmd = "nodedit" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "РедактироватьУзел", Узел);
	ИначеЕсли Запрос.cmd = "preview" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "ПоказатьУзел", Узел);
	ИначеЕсли Запрос.cmd = "nopreview" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "СкрытьУзел", Узел);
	ИначеЕсли Запрос.cmd = "nodereload" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "ОбновитьУзел", Узел);
	ИначеЕсли Запрос.cmd = "attradd" Тогда
		СтруктураУзла = Новый Структура("Имя, Значение, Старший, namedit, valuedit", "", "", Узел.Код, Истина, Истина);
		УзелСоседний = Данные.Атрибут(Узел);
		Если НЕ УзелСоседний = Неопределено Тогда
			СтруктураУзла.Вставить("Соседний", УзелСоседний.Код);
		КонецЕсли;
		НовыйУзел = Данные.НовыйУзел(СтруктураУзла);
		НовыйУзел.Вставить("attr", Истина);
		УзелСостояниеЗначение(НовыйУзел, "ТребуетсяРедактировать", Истина);
		Узел.Вставить("Атрибут", НовыйУзел.Код);
		Если НЕ УзелСоседний = Неопределено Тогда
			УзелСоседний.Вставить("Старший", НовыйУзел.Код);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "childadd" Тогда
		СтруктураУзла = Новый Структура("Имя, Значение, Старший, namedit, valuedit", "", "", Узел.Код, Истина, Истина);
		УзелСоседний = Данные.Дочерний(Узел);
		Если НЕ УзелСоседний = Неопределено Тогда
			СтруктураУзла.Вставить("Соседний", УзелСоседний.Код);
		КонецЕсли;
		НовыйУзел = Данные.НовыйУзел(СтруктураУзла);
		УзелСостояниеЗначение(НовыйУзел, "ТребуетсяРедактировать", Истина);
		УзелСостояниеЗначение(НовыйУзел, "ТребуетсяОткрыть", Истина);
		УзелСостояниеЗначение(Узел, "ТребуетсяОткрыть", Истина);
		Узел.Вставить("Дочерний", НовыйУзел.Код);
		Если НЕ УзелСоседний = Неопределено Тогда
			УзелСоседний.Вставить("Старший", НовыйУзел.Код);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "nextadd" Тогда
		СтруктураУзла = Новый Структура("Имя, Значение, Старший, namedit, valuedit", "", "", Узел.Код, Истина, Истина);
		УзелСоседний = Данные.Соседний(Узел);
		Если НЕ УзелСоседний = Неопределено Тогда
			СтруктураУзла.Вставить("Соседний", УзелСоседний.Код);
		КонецЕсли;
		НовыйУзел = Данные.НовыйУзел(СтруктураУзла);
		УзелСостояниеЗначение(НовыйУзел, "ТребуетсяРедактировать", Истина);
		Узел.Вставить("Соседний", НовыйУзел.Код);
		Если НЕ УзелСоседний = Неопределено Тогда
			УзелСоседний.Вставить("Старший", НовыйУзел.Код);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "noderemove" Тогда
		Данные.УдалитьУзел(Узел);
	ИначеЕсли Запрос.cmd = "nodecopy" Тогда
		Если НЕ Буфер = Неопределено Тогда
			ОсвободитьОбъект(Буфер);
		КонецЕсли;
		Буфер = Новый Соответствие;
		БуферУзел = Узел.Код;
		Данные.КопироватьУзел(Узел, Буфер);
	ИначеЕсли Запрос.cmd = "nodecut" Тогда
		Если НЕ Буфер = Неопределено Тогда
			ОсвободитьОбъект(Буфер);
		КонецЕсли;
		Буфер = Новый Соответствие;
		БуферУзел = Узел.Код;
		Данные.КопироватьУзел(Узел, Буфер);
		Данные.УдалитьУзел(Узел, Ложь);
	ИначеЕсли Запрос.cmd = "nodepasteattr" Тогда
		Если НЕ Буфер = Неопределено Тогда
			НовыйУзел = Данные.ВставитьУзел(Буфер, БуферУзел, Истина);
			НовыйУзел.Вставить("Старший", Узел.Код);
			НовыйУзел.Вставить("Атрибут", Неопределено);
			НовыйУзел.Вставить("Дочерний", Неопределено);
			УзелАтрибут = Данные.Атрибут(Узел);
			Узел.Вставить("Атрибут", НовыйУзел.Код);
			Если НЕ УзелАтрибут = Неопределено Тогда
				НовыйУзел.Вставить("Соседний", УзелАтрибут.Код);
				УзелАтрибут.Вставить("Старший", НовыйУзел.Код);
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "nodepastechild" Тогда
		Если НЕ Буфер = Неопределено Тогда
			НовыйУзел = Данные.ВставитьУзел(Буфер, БуферУзел);
			НовыйУзел.Вставить("Старший", Узел.Код);
			УзелДочерний = Данные.Дочерний(Узел);
			Узел.Вставить("Дочерний", НовыйУзел.Код);
			Если НЕ УзелДочерний = Неопределено Тогда
				НовыйУзел.Вставить("Соседний", УзелДочерний.Код);
				УзелДочерний.Вставить("Старший", НовыйУзел.Код);
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "nodepastenext" Тогда
		Если НЕ Буфер = Неопределено Тогда
			НовыйУзел = Данные.ВставитьУзел(Буфер, БуферУзел);
			НовыйУзел.Вставить("Старший", Узел.Код);
			УзелСоседний = Данные.Соседний(Узел);
			Узел.Вставить("Соседний", НовыйУзел.Код);
			Если НЕ УзелСоседний = Неопределено Тогда
				НовыйУзел.Вставить("Соседний", УзелСоседний.Код);
				УзелСоседний.Вставить("Старший", НовыйУзел.Код);
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "attremove" Тогда
		Если НЕ УзелСвойство(Узел, "Атрибут") = Неопределено Тогда
			Данные.УдалитьУзел(Данные.Атрибут(Узел), Ложь);
			//Узел.Удалить("Атрибут");
			Узел.Атрибут = Неопределено;
		КонецЕсли
	ИначеЕсли Запрос.cmd = "childremove" Тогда
		Если НЕ УзелСвойство(Узел, "Дочерний") = Неопределено Тогда
			Данные.УдалитьУзел(Данные.Дочерний(Узел), Ложь);
			//Узел.Удалить("Дочерний");
			Узел.Дочерний = Неопределено;
		КонецЕсли
	ИначеЕсли Запрос.cmd = "namedit" Тогда
		Узел.Вставить("namedit", Истина);
	ИначеЕсли Запрос.cmd = "valuedit" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, Результат", "РедактироватьЗначение", Узел);
	ИначеЕсли Запрос.cmd = "submitvalue" Тогда
		структЗадача.Действие = Новый Структура("Имя, Узел, НовоеЗначение, Результат", "НовоеЗначениеУзла", Узел, Неопределено);
		Если Запрос.Свойство("valuedit") Тогда
			структЗадача.Действие.Вставить("НовоеЗначение", Запрос.valuedit);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "submitname" Тогда
		Узел.Вставить("namedit", Ложь);
		Если Запрос.Свойство("valuedit") Тогда
			Узел.Вставить("Имя", Запрос.valuedit);
		КонецЕсли;
	КонецЕсли;

	Возврат "ВыполнитьДействия";
КонецФункции // ОбработатьКоманду()


Функция ЗапросВыполнитьЗадачу(структЗадача)

	Если структЗадача.Этап = "ВыполнитьЗадачу" Тогда

		Если Вкладки = Неопределено Тогда
			структЗадача.Результат = НачальнаяСтраница();
			структЗадача.Этап = "ЕстьРезультат";
			Возврат Истина;
		КонецЕсли;

		Запрос = структЗадача.Запрос;
		tab =  УзелСвойство(Запрос, "tab");

		Если tab = Неопределено Тогда
			tab = ТекущаяВкладка;
		КонецЕсли;

		Если НЕ tab = Неопределено Тогда
			Если НЕ ТекущаяВкладка = tab Тогда
				ОбновитьВкладки = Истина;
			КонецЕсли;
			ТекущаяВкладка = tab;
			структВкладка = Вкладки.Получить(ТекущаяВкладка);
			Если НЕ структВкладка = Неопределено Тогда
				структЗадача.Вставить("Вкладка", структВкладка);
			КонецЕсли;
		КонецЕсли;

		Если Запрос.Свойство("cmd") Тогда
			структЗадача.Этап = ОбработатьКоманду(структЗадача);
		Иначе
			структЗадача.Этап = "СформироватьОтвет";
		КонецЕсли;

	КонецЕсли;

	Если структЗадача.Этап = "ВыполнитьДействия" Тогда
		Если ВыполнитьДействия(структЗадача) = Истина Тогда
			структЗадача.Этап = "СформироватьОтвет";
		КонецЕсли;
	КонецЕсли;

	Если структЗадача.Этап = "СформироватьОтвет" Тогда
		Запрос = структЗадача.Запрос;
		Вкладка = структЗадача.Вкладка;
		Данные = Вкладка.Данные;
		Узел = ПолучитьИзмененныйУзел(Данные);
		Если НЕ Узел = Неопределено Тогда
			Ответ = "";
			Режим = структЗадача.Вкладка.Режим;
			Если Режим = "design" Тогда
				Ответ = ПоказатьСтруктуруУзла(Вкладка, Узел.Код);
			ИначеЕсли Режим = "lisp" Тогда
				Ответ = ПоказатьСтруктуруУзла(Вкладка, Узел.Код);
			Иначе
				Ответ = ПоказатьУзел(Вкладка, Узел.Код);
			КонецЕсли;
			структЗадача.Результат = Ответ;
			структЗадача.Этап = "ЕстьРезультат";
		КонецЕсли;
	КонецЕсли;

	Если структЗадача.Этап = "ЕстьРезультат" Тогда
		Соединение = Неопределено;
		Если ПередатьСтроку(Соединение, "<!--" + структЗадача.Запрос.taskid + "-->" + структЗадача.Результат + "<!--end-->") Тогда
			Если НЕ Соединение = Неопределено Тогда
				Соединение.Закрыть();
				структЗадача.Этап = "УдалитьЗадачу";
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецФункции // ЗапросВыполнитьЗадачу()


Функция УзелСвойство(Узел, Свойство) Экспорт
	УзелСвойство = Неопределено;
	Если НЕ Узел = Неопределено Тогда
		Узел.Свойство(Свойство, УзелСвойство);
	КонецЕсли;
	Возврат УзелСвойство;
КонецФункции // УзелСвойство(Узел)


Функция УзелСвойствоЗначение(Узел, СвойствоИмя, СвойствоЗначение) Экспорт
	Если НЕ Узел = Неопределено Тогда
		Узел.Вставить(СвойствоИмя, СвойствоЗначение);
	КонецЕсли;
	Возврат Неопределено;
КонецФункции // УзелСвойствоЗначение(Узел)


Функция УзелСостояние(Узел, СостояниеИмя = Неопределено) Экспорт
	УзелСостояние = Неопределено;
	Если НЕ Узел = Неопределено Тогда
		Узел.Свойство("Состояние", УзелСостояние);
		Если НЕ УзелСостояние = Неопределено Тогда
			Если НЕ СостояниеИмя = Неопределено Тогда
				УзелСостояние.Свойство(СостояниеИмя, УзелСостояние);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат УзелСостояние;
КонецФункции // УзелСостояние(Узел)


Функция УзелСостояниеЗначение(Узел, СостояниеИмя, СостояниеЗначение, Событие = Истина) Экспорт
	Если НЕ Узел = Неопределено Тогда
		Если УзелСвойство(Узел, "Состояние") = Неопределено Тогда
			Узел.Вставить("Состояние", Новый Структура());
		КонецЕсли;
		Узел.Состояние.Вставить(СостояниеИмя, СостояниеЗначение);
		Если НЕ СостояниеИмя = "ОбновитьУзел" Тогда
			Узел.Состояние.Вставить("ОбновитьУзел", Истина);
		КонецЕсли;
		Если Событие Тогда
			//Сообщить(СостояниеИмя + "=" + СостояниеЗначение);
			//НовоеСобытие(Новый Структура("Имя, Узел, СостояниеИмя", "ОбновитьСостояние", Узел, СостояниеИмя));
		КонецЕсли;
	КонецЕсли;
	Возврат Неопределено;
КонецФункции // УзелСостояниеЗначение(Узел)


Функция НовоеСобытие(СтруктураСобытия)
	ИдСобытия = ИдСобытия + 1;
	Событие = Новый Структура(СтруктураСобытия);
	События.Вставить(ИдСобытия, Событие);
	Возврат Событие;
КонецФункции // НовоеСобытие()


Функция ОбработатьСобытия(Данные)
	Для каждого элСобытие Из События Цикл
		Событие = элСобытие.Значение;
		Если Событие.Имя = "ОбновитьСостояние" Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
КонецФункции // ОбработатьСобытия()


Функция ОбновитьСостояние(Данные, Узел, Состояние, Значение)

	Если Узел = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	Результат = Истина;

	Если Состояние = "УзелПросмотр" И Значение = Истина Тогда
		Результат = ОбновитьСостояние(Данные, Узел, "УзелОткрыт", Истина);

	ИначеЕсли Состояние = "УзелПросмотр" И Значение = Ложь Тогда
		ОбновитьСостояние(Данные, Узел, "ОбновитьУзел", Истина);

	ИначеЕсли Состояние = "НовоеЗначениеУзла" Тогда
		ОбновитьСостояние(Данные, Узел, "РедактироватьЗначение", Ложь);
		УзелСвойствоЗначение(Узел, "Значение", Значение);
		ОбновитьСостояние(Данные, Узел, "ОбновитьУзел", Истина);

	// ИначеЕсли Состояние = "ОбновитьУзел" И Значение = Истина Тогда
	// 	ОбновитьСостояние(Данные, Данные.Родитель(Узел), "ОбновитьУзел", Истина);
	// 	Результат = (УзелСостояние(Узел, "УзелПросмотр") = Истина);

	ИначеЕсли Состояние = "ОбновитьУзел" И Значение = Ложь Тогда
		Результат = УзелСостояние(Узел, "ОбновитьУзел");

	КонецЕсли;

	Если НЕ Результат = Ложь Тогда
		УзелСостояниеЗначение(Узел, Состояние, Значение);
	КонецЕсли;

	Возврат Результат;

КонецФункции // ОбновитьСостояние()


Функция ПолучитьИзмененныйУзел(Данные)
	Для каждого элУзел Из Данные.Узлы Цикл
		Узел = элУзел.Значение;
		Если УзелСостояние(Узел, "ОбновитьУзел") = Истина Тогда
			Если ОбновитьСостояние(Данные, Узел, "ОбновитьУзел", Ложь) = Истина Тогда
				Возврат Узел;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
КонецФункции // ПолучитьИзмененныйУзел()


Функция ВыполнитьДействия(структЗадача)
	Действие = УзелСвойство(структЗадача, "Действие");
	Если НЕ Действие = Неопределено Тогда

		Если Действие.Имя = "НоваяВкладка" Тогда
			НоваяВкладка(структЗадача);
			Данные = структЗадача.Вкладка.Данные;
			Узел = Данные.ПолучитьУзел(структЗадача.Вкладка.ИдУзла);
			УзелСостояниеЗначение(Узел, "ОбновитьУзел", Истина);
			структЗадача.Результат = ПоказатьПанель();
			структЗадача.Этап = "ЕстьРезультат";
			Возврат Ложь;
		ИначеЕсли Действие.Имя = "ВыбратьВкладку" Тогда
			Данные = структЗадача.Вкладка.Данные;
			Узел = Данные.ПолучитьУзел(структЗадача.Вкладка.ИдУзла);
			УзелСостояниеЗначение(Узел, "ОбновитьУзел", Истина);
			структЗадача.Результат = ПоказатьПанель();
			структЗадача.Этап = "ЕстьРезультат";
			Возврат Ложь;
		ИначеЕсли Действие.Имя = "ЗакрытьВкладку" Тогда
			Вкладка1 = Неопределено;
			Вкладка2 = Неопределено;
			Для каждого элВкладка Из Вкладки Цикл
				Вкладка = элВкладка.Значение;
				Вкладка1 = Вкладка2;
				Вкладка2 = Вкладка;
				Если ТекущаяВкладка = Вкладка1 Тогда
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Вкладки.Удалить(ТекущаяВкладка);
			Если НЕ Вкладка1 = Неопределено Тогда
				ТекущаяВкладка = Вкладка1;
			Иначе
				НоваяВкладка(структЗадача);
			КонецЕсли;
			структЗадача.Результат = ПоказатьПанель();
			структЗадача.Этап = "ЕстьРезультат";
			Возврат Ложь;
		ИначеЕсли Действие.Имя = "ОбновитьDOM" Тогда
			Возврат Истина;
		КонецЕсли;

		Данные = структЗадача.Вкладка.Данные;
		Если Данные = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;

		Узел = Данные.ПолучитьУзел(УзелСвойство(структЗадача.Запрос, "nodeid"));

		Если Действие.Имя = "ОткрытьУзел" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "УзелОткрыт", Истина);

		ИначеЕсли Действие.Имя = "ЗакрытьУзел" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "УзелОткрыт", Ложь);

		ИначеЕсли Действие.Имя = "РедактироватьУзел" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "УзелРедактируется", Истина);

		ИначеЕсли Действие.Имя = "РедактироватьЗначение" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "РедактироватьЗначение", Истина);

		ИначеЕсли Действие.Имя = "НовоеЗначениеУзла" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "НовоеЗначениеУзла", Действие.НовоеЗначение);

		ИначеЕсли Действие.Имя = "ПоказатьУзел" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "УзелПросмотр", Истина);

		ИначеЕсли Действие.Имя = "СкрытьУзел" Тогда
			Возврат ОбновитьСостояние(Данные, Узел, "УзелПросмотр", Ложь);

		КонецЕсли;
	КонецЕсли;

	Возврат Ложь;
КонецФункции // ВыполнитьДействия()


Функция ПередатьСтроку(Соединение, СтрокаДанные)
	Попытка
		Соединение = Новый TCPСоединение(Хост, Порт);
		Соединение.ТаймаутОтправки = 100;
		Соединение.ОтправитьСтроку(СтрокаДанные);
		Возврат Истина;
	Исключение
		Соединение = Неопределено;
		Возврат Ложь;
	КонецПопытки;
КонецФункции // ПередатьСтроку()



Если АргументыКоманднойСтроки.Количество() Тогда
	procid = АргументыКоманднойСтроки[0];
Иначе
	procid = "1";
КонецЕсли;

Шаблон = ЗагрузитьСценарий(ОбъединитьПути(ТекущийКаталог(), "template.os"));
Шаблон.ЗагрузитьМакет("showdata");

//ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "dbaccess.os"), "dbaccess");
ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "pagedata.os"), "pagedata");

Буфер = Неопределено;

События = Новый Соответствие;
ИдСобытия = 0;
ИдВкладки = 0;

Таймаут = 10;
Хост = "127.0.0.1";
Порт = 8888;
Соединение = Неопределено;

Задачи = Новый Соответствие;

СтруктЗапрос = СтруктуруВСтроку(Новый Структура("procid", procid));
КоличествоПопыток = 100;

Попытка

	Пока Истина Цикл

		ПрерватьЦикл = Ложь;
		Пока Не ПрерватьЦикл Цикл
			ПрерватьЦикл = Истина;
			Для каждого элЗадача Из Задачи Цикл
				структЗадача = ЭлЗадача.Значение;
				Если структЗадача.Тип = "Запрос" Тогда
					ЗапросВыполнитьЗадачу(структЗадача);
				КонецЕсли;
				Если структЗадача.Этап = "УдалитьЗадачу" Тогда
					Задачи.Удалить(элЗадача.Ключ);
					ПрерватьЦикл = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;

		Если Соединение = Неопределено Тогда
			Если НЕ ПередатьСтроку(Соединение, СтруктЗапрос) Тогда
				КоличествоПопыток = КоличествоПопыток - 1;
				Если КоличествоПопыток = 0 Тогда
					Сообщить("Хост недоступен");
					Прервать;
				КонецЕсли;
				Продолжить;
			КонецЕсли;
			КоличествоПопыток = 100;
		Иначе
			Если НЕ Соединение.Активно Тогда
				Соединение = Неопределено;
				Продолжить;
			КонецЕсли;
		КонецЕсли;

		Попытка
			ЗадачиКоличество = Задачи.Количество();
			Если ЗадачиКоличество Тогда
				Соединение.ТаймаутЧтения = 100;
			КонецЕсли;
			Запрос = Соединение.ПрочитатьСтроку();
		Исключение
			//Сообщить("Осталось задач: " + ЗадачиКоличество);
			Продолжить;
		КонецПопытки;

		Попытка
			Запрос = СтрокуВСтруктуру(Запрос);
			структЗадача = Новый Структура("Тип, Этап, Запрос, Действие, Результат", "Запрос", "ВыполнитьЗадачу", Запрос);
		Исключение
			структЗадача = Новый Структура("Тип, Этап, Запрос, Результат", "Запрос", "ЕстьРезультат", Неопределено, "Неверный запрос");
		КонецПопытки;

		Задачи.Вставить(Запрос.taskid, структЗадача);

		Соединение.Закрыть();
		Соединение = Неопределено;

	КонецЦикла;

Исключение
	Сообщить(ОписаниеОшибки());
КонецПопытки;
