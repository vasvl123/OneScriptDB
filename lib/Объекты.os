// MIT License
// Copyright (c) 2019 Vladimir Vasiliev
// https://github.com/vasvl123/OneScriptDB

Функция СтруктуруВСвойства(Данные, Узел, стрСвойства)
	св = Неопределено;
	Свойства = Новый Структура;
	Для каждого эл Из стрСвойства Цикл
		Если св = Неопределено Тогда
			св = Данные.НовыйДочерний(Узел, Новый Структура("Имя, Значение", эл.Ключ, эл.Значение));
		Иначе
			св = Данные.НовыйСоседний(св, Новый Структура("Имя, Значение", эл.Ключ, эл.Значение));
		КонецЕсли;
		Свойства.Вставить(эл.Ключ, св);
	КонецЦикла;
	Возврат Свойства;
КонецФункции // СтруктуруВСвойства(стрСвойства)

Функция Кубик(Данные, Параметры) Экспорт
	Перем парСвойства, Свойства;

	ЭтотУзел = Параметры.ЭтотУзел;

	Если НЕ Параметры.Свойство("Свойства", парСвойства) Тогда
		парСвойства = Данные.НовыйСоседний(Данные.Атрибут(ЭтотУзел), Новый Структура("Имя, Значение", "Свойства", ""));
		стрСвойства = Новый Структура;
		стрСвойства.Вставить("type", "'box'");
		стрСвойства.Вставить("color", "0x555555");
		стрСвойства.Вставить("transparent", "true");
		стрСвойства.Вставить("opacity", "0.3");
		стрСвойства.Вставить("position_x", "0");
		стрСвойства.Вставить("position_y", "0");
		стрСвойства.Вставить("position_z", "0");
		стрСвойства.Вставить("scale_x", "20");
		стрСвойства.Вставить("scale_y", "10");
		стрСвойства.Вставить("scale_z", "20");
		Свойства = СтруктуруВСвойства(Данные, парСвойства, стрСвойства);
		Данные.УзелСостояниеЗначение(парСвойства, "Свойства", Свойства); // оптимизация
	Иначе
		Свойства = Данные.УзелСостояние(парСвойства, "Свойства");
	КонецЕсли;

	Если Свойства = Неопределено Тогда
		Свойства = Новый Структура;
		св = Данные.Дочерний(парСвойства);
		Пока не св = Неопределено Цикл
			Свойства.Вставить(св.Имя, св);
			св = Данные.Соседний(св);
		КонецЦикла;
		Данные.УзелСостояниеЗначение(парСвойства, "Свойства", Свойства); // оптимизация
	КонецЕсли;

	Результат = "<script>var p = {id: '" + парСвойства.Код + "'";
	Для каждого эл Из Свойства Цикл
		Результат = Результат + "," + эл.Ключ + ": " + эл.Значение.Значение;
	КонецЦикла;

	Результат = Результат + "}; var id=""_" + ЭтотУзел.Код + """; updifrm(id,p);</script>";

	Возврат Результат;
КонецФункции
