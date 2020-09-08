кор = Новый ТекстовыйДокумент;
кор.Прочитать("annot.opcorpora.no_ambig.xml");
ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "pagedata.os"), "pagedata");

Данные = Новый pagedata(ЭтотОбъект, "");

д = Данные.ПолучитьУзел("1");
д = Данные.НовыйДочерний(д, Новый Структура("Имя, Значение", "Свойства.", ""));

н = 1;
Для н = 1 По 500 Цикл //кор.КоличествоСтрок() Цикл

	стр = кор.ПолучитьСтроку(н);

	к = СтрНайти(стр, "<source>");
	Если к > 0 Тогда

		стр = Сред(стр, к + 8, СтрДлина(стр) - 16 - к);
		д = Данные.НовыйСоседний(д, Новый Структура("Имя, Значение", "О", "Сем.Предложение"));
		а = Данные.НовыйАтрибут(д, Новый Структура("Имя, Значение", "Текст", стр));
		т = Данные.НовыйСоседний(а, Новый Структура("Имя, Значение", "Грам", ""));
		н1 = 1;
		Пока Истина Цикл
			стр = кор.ПолучитьСтроку(н + н1);
			Если СтрНайти(стр, "</sentence>") Тогда
				Прервать;
			КонецЕсли;
			к = СтрНайти(стр, "<token ");
			Если к Тогда
				мк = СтрРазделить(стр, """");
				г = "";
				Для н2 = 12 По мк.Количество() - 1 Цикл
					Если Прав(мк[н2], 1) = "=" Тогда
						г = г + мк[н2 + 1] + " ";
					КонецЕсли;
				КонецЦикла;
				Данные.НовыйДочерний(т, Новый Структура("Имя, Значение", мк[3], СокрЛП(г)), , Истина);
			КонецЕсли;
			н1 = н1 + 1;
		КонецЦикла;

		//Прервать;

	КонецЕсли;

КонецЦикла;

ф = Новый ТекстовыйДокумент;
ф.УстановитьТекст(Данные.СохранитьДанные());
ф.Записать("sem.sd");
