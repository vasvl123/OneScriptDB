// MIT License
// Copyright (c) 2019 Vladimir Vasiliev
// https://github.com/vasvl123/OneScriptDB

Функция стрУзел(Имя, Значение)
	Возврат Новый Структура("Имя, Значение", Имя, Значение);
КонецФункции // стрУзел(Имя, Значение)

Функция Кубик(Данные, Параметры) Экспорт
	Перем парСвойства;

	Если НЕ Параметры.Свойство("Свойства", парСвойства) Тогда
		ЭтотУзел = Параметры.ЭтотУзел;
		парСвойства = Данные.НовыйСоседний(Данные.Атрибут(ЭтотУзел), стрУзел("А", "Свойства"));
		св = Данные.НовыйДочерний(парСвойства, стрУзел("color", "0xffffff"));
		св = Данные.НовыйСоседний(св, стрУзел("transparent", "true"));
		св = Данные.НовыйСоседний(св, стрУзел("position_x", "0"));
		св = Данные.НовыйСоседний(св, стрУзел("position_y", "0"));
		св = Данные.НовыйСоседний(св, стрУзел("position_z", "0"));
		св = Данные.НовыйСоседний(св, стрУзел("scale_x", "20"));
		св = Данные.НовыйСоседний(св, стрУзел("scale_y", "10"));
		св = Данные.НовыйСоседний(св, стрУзел("scale_z", "20"));
	КонецЕсли;

	св = Данные.Дочерний(парСвойства);

	Свойства = Новый Соответствие;

	Пока не св = Неопределено Цикл
		Свойства.Вставить(св.Имя, св);
		св = Данные.Соседний(св);
	КонецЦикла;

	Результат = "";

	Возврат Результат;
КонецФункции
