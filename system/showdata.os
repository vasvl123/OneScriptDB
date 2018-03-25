Перем ВсеДанные, procid, data;
Перем Шаблон;
Перем Буфер;

Функция СкопироватьДанные(Знач Данные)
	Возврат Данные;
КонецФункции

Функция НачальнаяСтраница()
	Перем Ответ;

	Ответ = Шаблон.ПолучитьОбласть("ОбластьШапка", Новый Структура("ПараметрИдПроцесса", procid));
	Ответ = Ответ + Шаблон.ПолучитьОбласть("ОбластьТело", Новый Структура("ПараметрИдПроцесса, ПараметрИдУзла", procid, "316"));

	//Ответ = Ответ + Шаблон.ПолучитьОбласть("ОбластьПриветствие");

	Ответ = Ответ + Шаблон.ПолучитьОбласть("ОбластьПодвал");

	Возврат Ответ;
КонецФункции

Функция УзелСвойство(Узел, Свойство) Экспорт
	УзелСвойство = Неопределено;
	Узел.Свойство(Свойство, УзелСвойство);
	Возврат УзелСвойство;
КонецФункции // УзелСвойство(Узел)

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


Функция ПоказатьУзел(Данные, Запрос, КодУзла = Неопределено, Уровень = "", ПервыйВызов = Истина) Экспорт

	Если КодУзла = Неопределено Тогда
		КодУзла = Запрос.nodeid;
	КонецЕсли;

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
			Атрибут = Данные.ПолучитьУзел(Атрибут);
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
		Текст = Текст + ПоказатьУзел(Данные, Запрос, Узел.Дочерний, Уровень + Символы.Таб, Ложь);
	КонецЕсли;

	Если НЕ (Узел.Имя = "#text" ИЛИ Узел.Имя = "#comment") Тогда
		Если Узел.Свойство("Значение") Тогда
			Текст = Текст + Узел.Значение;
		КонецЕсли;
		Текст = Текст + Символы.ПС + Уровень + "</" + Узел.Имя + ">";
	КонецЕсли;

	Если НЕ ПервыйВызов Тогда
		Если НЕ УзелСвойство(Узел, "Соседний") = Неопределено Тогда
			Текст = Текст + ПоказатьУзел(Данные, Запрос, Узел.Соседний, Уровень, Ложь);
		КонецЕсли;
	КонецЕсли;

	Возврат Текст;

КонецФункции // ПоказатьУзел()


Функция ПоказатьСтруктуруУзла(Данные, Запрос, КодУзла = Неопределено, ПервыйВызов = Истина) Экспорт

	Представление = "";
	Атрибуты = "";

	Если КодУзла = Неопределено Тогда
		Если Запрос.Свойство("loadnodeid") Тогда
			КодУзла = Запрос.loadnodeid;
		Иначе
			КодУзла = Запрос.nodeid;
		КонецЕсли;
	КонецЕсли;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел " + КодУзла + " не найден!";
	КонецЕсли;

	Если НЕ Узел.Свойство("nodeopen") Тогда
		Узел.Вставить("nodeopen", Ложь);
	КонецЕсли;

	УзелИмя = Узел.Имя;

	УзелЗначение = "";
	Если Узел.Свойство("Значение") Тогда
		УзелЗначение = Узел.Значение;
	КонецЕсли;

	ГлУзелИзменить = УзелСвойство(Узел, "mainodedit");
	УзелИзменить = УзелСвойство(Узел, "nodedit");
	УзелРежим = УзелСвойство(Узел, "mode");
	этоАтрибут = УзелСвойство(Узел, "attr");

	Если этоАтрибут = Истина Тогда
		УзелИмя = СтрЗаменить(УзелИмя, "xml_lang", "xml:lang");
		УзелИмя = СтрЗаменить(УзелИмя, "_", "-");
	КонецЕсли;

	КнопкаУзел = "";

	Если НЕ УзелСвойство(Узел, "Дочерний") = Неопределено Тогда
		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", Запрос.procid);
		ПараметрыШаблона.Вставить("ПараметрРежим", Запрос.mode);
		ПараметрыШаблона.Вставить("ПараметрКоманда", ?(Узел.nodeopen, "nodeclose", "nodeopen"));
		ПараметрыШаблона.Вставить("ПараметрНадписьНаКнопке", ?(Узел.nodeopen, "⚪" , "⚫"));
		КнопкаУзел = Шаблон.ПолучитьОбласть("ОбластьКнопкаУзел", ПараметрыШаблона);
	КонецЕсли;

	КнопкиИнструменты = "";
	ПараметрМенюИнструменты = "";

	Если УзелИзменить = Истина Тогда

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрНеактивно", "");
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", Запрос.procid);
		ПараметрыШаблона.Вставить("ПараметрРежим", Запрос.mode);
		ПараметрыШаблона.Вставить("ПараметрВидимость", "");

		Если НЕ этоАтрибут = Истина Тогда
			ПараметрыШаблона.Вставить("ПараметрКоманда", ?(УзелРежим = "view", "modesource", "modeview"));
			ПараметрыШаблона.Вставить("ПараметрПодсказка", ?(УзелРежим = "view", "Скрыть", "Просмотр"));
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрКоманда", "attradd");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Добавить атрибут");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрКоманда", "childadd");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Добавить дочерний");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);
		КонецЕсли;

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Данные.Родитель(Узел).Код);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "nextadd");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Добавить соседний");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "nodecut");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вырезать узел");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		ПараметрыШаблона.Вставить("ПараметрКоманда", "nodecopy");
		ПараметрыШаблона.Вставить("ПараметрПодсказка", "Копировать узел");
		ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

		Если НЕ этоАтрибут = Истина Тогда
			ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Данные.Родитель(Узел).Код);
			ПараметрыШаблона.Вставить("ПараметрКоманда", "nodepasteattr");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вставить атрибут");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);

			ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Узел.Код);
			ПараметрыШаблона.Вставить("ПараметрКоманда", "nodepastechild");
			ПараметрыШаблона.Вставить("ПараметрПодсказка", "Вставить дочерний");
			ПараметрМенюИнструменты = ПараметрМенюИнструменты + Шаблон.ПолучитьОбласть("ОбластьМенюИнструменты", ПараметрыШаблона);
		КонецЕсли;

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Данные.Родитель(Узел).Код);
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

		ПараметрыШаблона.Вставить("ПараметрОбновитьУзел", Данные.Родитель(Узел).Код);
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
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", Запрос.procid);
		ПараметрыШаблона.Вставить("ПараметрРежим", Запрос.mode);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "submitname");
		ПараметрыШаблона.Вставить("ПараметрИмяЗначение", УзелИмя);
		ПараметрИмя = Шаблон.ПолучитьОбласть("ОбластьИзменитьИмяЗначение", ПараметрыШаблона);

	Иначе

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрНеактивно", "");
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", Запрос.procid);
		ПараметрыШаблона.Вставить("ПараметрРежим", Запрос.mode);
		ПараметрыШаблона.Вставить("ПараметрКоманда", ?(УзелИзменить = Истина, "namedit", "nodedit"));
		ПараметрыШаблона.Вставить("ПараметрНадписьНаКнопке", УзелИмя);
		ПараметрИмя = Шаблон.ПолучитьОбласть("ОбластьКнопкаИмяЗначение", ПараметрыШаблона);

	КонецЕсли;

	Если УзелСвойство(Узел, "valuedit") = Истина Тогда

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", Запрос.procid);
		ПараметрыШаблона.Вставить("ПараметрРежим", Запрос.mode);
		ПараметрыШаблона.Вставить("ПараметрКоманда", "submitvalue");
		ПараметрыШаблона.Вставить("ПараметрИмяЗначение", УзелЗначение);
		ПараметрЗначение = Шаблон.ПолучитьОбласть("ОбластьИзменитьИмяЗначение", ПараметрыШаблона);

	ИначеЕсли НЕ УзелЗначение = "" ИЛИ (УзелИзменить = Истина ИЛИ ГлУзелИзменить = Истина) Тогда

		ПараметрыШаблона = Новый Структура;
		ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
		ПараметрыШаблона.Вставить("ПараметрНеактивно", ?(УзелИзменить = Истина, "", "disabled"));
		ПараметрыШаблона.Вставить("ПараметрИдПроцесса", Запрос.procid);
		ПараметрыШаблона.Вставить("ПараметрРежим", Запрос.mode);
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
		УзелАтрибут.Вставить("mainodedit", УзелИзменить = Истина);
		Если УзелИзменить = Ложь Тогда
			УзелАтрибут.Вставить("nodedit", Ложь);
			УзелАтрибут.Вставить("valuedit", Ложь);
			УзелАтрибут.Вставить("namedit", Ложь);
		КонецЕсли;
		УзелАтрибут.Вставить("attr", Истина);
		Атрибуты = ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Атрибут, Ложь);
	КонецЕсли;

	Если этоАтрибут = Истина Тогда
		Если НЕ УзелСвойство(Узел, "Соседний") = Неопределено Тогда
			УзелАтрибут = Данные.Соседний(Узел);
			УзелАтрибут.Вставить("mainodedit", ГлУзелИзменить = Истина);
			Если ГлУзелИзменить = Ложь Тогда
				УзелАтрибут.Вставить("nodedit", Ложь);
				УзелАтрибут.Вставить("valuedit", Ложь);
				УзелАтрибут.Вставить("namedit", Ложь);
			КонецЕсли;
			УзелАтрибут.Вставить("attr", Истина);
			ПараметрИмяУзла = ПараметрИмяУзла + ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Соседний, Ложь);
		КонецЕсли;

		Возврат ПараметрИмяУзла;
	КонецЕсли;

	ПараметрЗаголовокУзла = ПараметрИмяУзла + Атрибуты;

	ДочернийУзел = "";
	Если Узел.nodeopen Тогда
		Если НЕ УзелСвойство(Узел, "Дочерний") = Неопределено Тогда
			ДочернийУзел = ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Дочерний, Ложь);
		КонецЕсли;
		Если УзелРежим = "view" Тогда
			ПараметрПредставление = ПоказатьУзел(Данные, Запрос, Узел.Код);
			ПараметрыШаблона = Новый Структура;
			ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
			ПараметрыШаблона.Вставить("ПараметрПредставление", ПараметрПредставление);
			ДочернийУзел = ДочернийУзел + Шаблон.ПолучитьОбласть("ОбластьПросмотр", ПараметрыШаблона);
		КонецЕсли;
	КонецЕсли;

	ПараметрыШаблона = Новый Структура;
	ПараметрыШаблона.Вставить("ПараметрИдУзла", Узел.Код);
	ПараметрыШаблона.Вставить("ПараметрЗаголовокУзла", ПараметрЗаголовокУзла);
	ПараметрыШаблона.Вставить("ПараметрДочернийУзел", ДочернийУзел);
	Представление = Шаблон.ПолучитьОбласть("ОбластьУзел", ПараметрыШаблона);

	Если НЕ ПервыйВызов Тогда
		Если НЕ УзелСвойство(Узел, "Соседний") = Неопределено Тогда
				Представление = Представление + ПоказатьСтруктуруУзла(Данные, Запрос, Узел.Соседний, Ложь);
		КонецЕсли;
	КонецЕсли;

	Возврат Представление;

КонецФункции

Функция ВыполнитьЗадачу(структЗадача)

	Запрос = структЗадача.Запрос;

	Ответ = Неопределено;

	Если Запрос.Свойство("data") Тогда
		data = Запрос.data;
	КонецЕсли;

	Если data = Неопределено Тогда
		Ответ = НачальнаяСтраница();
	Иначе
		Данные = ВсеДанные.Получить(data);
		Если Данные = Неопределено Тогда
			Данные = Новый pagedata("" + data + ".txt", Шаблон);
			ВсеДанные.Вставить("" + data, Данные);
		КонецЕсли;
		Если Запрос.Свойство("cmd") Тогда
			ОбработатьДанные(Данные, Запрос);
		КонецЕсли;
		Если Запрос.Свойство("mode") Тогда
			Если Запрос.mode = "design" Тогда
				Ответ = ПоказатьСтруктуруУзла(Данные, Запрос);
			КонецЕсли;
			Если Запрос.mode = "lisp" Тогда
				Ответ = ПоказатьСтруктуруУзла(Данные, Запрос);
			КонецЕсли;
		КонецЕсли;
		Если Ответ = Неопределено Тогда
			Ответ = ПоказатьУзел(Данные, Запрос);
		КонецЕсли;
	КонецЕсли;

	структЗадача.Результат = Ответ;

КонецФункции // ВыполнитьЗадачу()


Функция ОбработатьДанные(Данные, Запрос, КодУзла = Неопределено) Экспорт

	ПервыйВызов = (КодУзла = Неопределено);

	Если ПервыйВызов Тогда
		КодУзла = Запрос.nodeid;
	КонецЕсли;

	Узел = Данные.ПолучитьУзел(КодУзла);
	Если Узел = Неопределено Тогда
		Возврат "Узел не найден!";
	КонецЕсли;

	Если Запрос.cmd = "nodeopen" Тогда
		Узел.Вставить("nodeopen", Истина);
		Если Запрос.mode = "lisp" Тогда
			Попытка
				Значение = Данные.Интерпретировать(Данные.Окружение, Узел);
			Исключение
				Значение = ОписаниеОшибки();
			КонецПопытки;
			Узел.Вставить("Значение", Значение);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "nodeclose" Тогда
		Узел.Вставить("nodeopen", Ложь);
		Узел.Вставить("nodedit", Ложь);
		Узел.Вставить("valuedit", Ложь);
		Узел.Вставить("namedit", Ложь);
	ИначеЕсли Запрос.cmd = "nodedit" Тогда
		Узел.Вставить("nodedit", Истина);
	ИначеЕсли Запрос.cmd = "modeview" Тогда
		Узел.Вставить("mode", "view");
		Узел.Вставить("nodeopen", Истина);
	ИначеЕсли Запрос.cmd = "modesource" Тогда
		Узел.Вставить("mode", "source");
		Узел.Вставить("nodeopen", Истина);
	ИначеЕсли Запрос.cmd = "attradd" Тогда
		СтруктураУзла = Новый Структура("Имя, Значение, Старший, namedit, valuedit", "", "", Узел.Код, Истина, Истина);
		УзелСоседний = Данные.Атрибут(Узел);
		Если НЕ УзелСоседний = Неопределено Тогда
			СтруктураУзла.Вставить("Соседний", УзелСоседний.Код);
		КонецЕсли;
		НовыйУзел = Данные.ВставитьУзел(СтруктураУзла);
		НовыйУзел.Вставить("attr", Истина);
		НовыйУзел.Вставить("nodedit", Истина);
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
		НовыйУзел = Данные.ВставитьУзел(СтруктураУзла);
		НовыйУзел.Вставить("nodedit", Истина);
		НовыйУзел.Вставить("nodeopen", Истина);
		Узел.Вставить("nodeopen", Истина);
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
		НовыйУзел = Данные.ВставитьУзел(СтруктураУзла);
		НовыйУзел.Вставить("nodedit", Истина);
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
		Данные.КопироватьУзел(Узел, Буфер);
	ИначеЕсли Запрос.cmd = "nodepastenext" Тогда
		// Если НЕ Буфер = Неопределено Тогда
		// 	Если НЕ УзелСвойство(Узел, "Следующий") = Неопределено Тогда
		// 		Данные.ВставитьУзел(Узел, Буфер);
		// 	КонецЕсли;
		// КонецЕсли;
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
		Узел.Вставить("valuedit", Истина);
	ИначеЕсли Запрос.cmd = "submitvalue" Тогда
		Узел.Вставить("valuedit", Ложь);
		Если Запрос.Свойство("valuedit") Тогда
			Узел.Вставить("Значение", Запрос.valuedit);
		КонецЕсли;
	ИначеЕсли Запрос.cmd = "submitname" Тогда
		Узел.Вставить("namedit", Ложь);
		Если Запрос.Свойство("valuedit") Тогда
			Узел.Вставить("Имя", Запрос.valuedit);
		КонецЕсли;
	КонецЕсли;

КонецФункции // ОбработатьДанные()


Если АргументыКоманднойСтроки.Количество() Тогда
	procid = АргументыКоманднойСтроки[0];
Иначе
	procid = "1";
КонецЕсли;

Шаблон = ЗагрузитьСценарий(ОбъединитьПути(ТекущийКаталог(), "template.os"));
Шаблон.ЗагрузитьМакет("showdata");

//ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "dbaccess.os"), "dbaccess");
ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "pagedata.os"), "pagedata");

ВсеДанные = Новый Соответствие;
Буфер = Неопределено;

Таймаут = 10;
Хост = "127.0.0.1";
Порт = 8888;
Соединение = Неопределено;

Задачи = Новый Соответствие;

КоличествоПопыток = 100;

Попытка

	Пока Истина Цикл

		КоличествоПопыток = КоличествоПопыток - 1;
		Если КоличествоПопыток = 0 Тогда
			Сообщить("Хост недоступен");
			Прервать;
		КонецЕсли;

		Для каждого элЗадача Из Задачи Цикл
			структЗадача = ЭлЗадача.Значение;
			Если структЗадача.Результат = Неопределено Тогда
				ВыполнитьЗадачу(структЗадача);
			КонецЕсли;
			Если НЕ структЗадача.Результат = Неопределено Тогда
				структЗадача.Соединение.ОтправитьСтроку(структЗадача.Результат);
				структЗадача.Соединение.Закрыть();
				Задачи.Удалить(элЗадача.Ключ);
				Прервать;
			КонецЕсли;
		КонецЦикла;

		Если Соединение = Неопределено Тогда
			Попытка
				Соединение = Новый TCPСоединение(Хост, Порт);
				Соединение.ТаймаутОтправки = 100;
				СтруктЗапрос = Новый Структура("procid", procid);
				Соединение.ОтправитьСтроку(СтруктуруВСтроку(СтруктЗапрос));
				КоличествоПопыток = 100;
			Исключение
				Продолжить;
			КонецПопытки;
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
			Сообщить("Осталось задач: " + ЗадачиКоличество);
			Продолжить;
		КонецПопытки;

		Попытка
			Запрос = СтрокуВСтруктуру(Запрос);
			структЗадача = Новый Структура("Запрос, Соединение, Результат", Запрос, Соединение);
		Исключение
			структЗадача = Новый Структура("Запрос, Соединение, Результат", Неопределено, Соединение, "Неверный запрос");
		КонецПопытки;

		Задачи.Вставить(Запрос.taskid, структЗадача);

		Соединение = Неопределено;

	КонецЦикла;

Исключение

	Сообщить(ОписаниеОшибки());

КонецПопытки;
