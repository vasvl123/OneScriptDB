
// Простой шаблонизатор 
Перем ТекстМакета Экспорт;

Функция Вывести() Экспорт
	Возврат ТекстМакета;
КонецФункции

Функция ПолучитьОбласть(ИмяОбласти, ЗначенияПараметров = Неопределено) Экспорт
	Область = "";
	СтрНачалоОбласти = "<!--" + ИмяОбласти + "-->";
	НачалоОбласти = Найти(ТекстМакета, СтрНачалоОбласти);
	Если НачалоОбласти Тогда
		НачалоОбласти = НачалоОбласти + СтрДлина(СтрНачалоОбласти);
		СтрКонецОбласти = "<!--/" + ИмяОбласти + "-->";
		КонецОбласти = СтрНайти(ТекстМакета, СтрКонецОбласти, , НачалоОбласти);
		Если КонецОбласти Тогда
			Область = Сред(ТекстМакета, НачалоОбласти, КонецОбласти - НачалоОбласти);
			Если СтрДлина(Область) Тогда
				Если Не ЗначенияПараметров = Неопределено Тогда
					Для Каждого КлючЗначение Из ЗначенияПараметров Цикл
						Область = СтрЗаменить(Область, "." + КлючЗначение.Ключ, КлючЗначение.Значение);
					КонецЦикла;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат Область;
КонецФункции

Процедура ЗаменитьОбластьВМакете(ПодстрокаПоиска, ПодстрокаЗамены) Экспорт
	ТекстМакета = СтрЗаменить(ТекстМакета, ПодстрокаПоиска, ПодстрокаЗамены);
КонецПроцедуры

Процедура ЗаменитьОбластьВЦикле(ПодстрокаПоиска, ПодстрокаЗамены) Экспорт
	П = Найти(ТекстМакета, ПодстрокаПоиска);
	Если П > 0 Тогда
		ЛеваяЧасть = Лев(ТекстМакета, П);
		ПраваяЧасть= Прав(ТекстМакета, СтрДлина(ТекстМакета) - П+СтрДлина(ПодстрокаПоиска));
		ТекстМакета = ЛеваяЧасть + Символы.ПС + ПодстрокаЗамены + Символы.ПС + ПодстрокаПоиска + Символы.ПС + ПраваяЧасть;
	КонецЕсли;
КонецПроцедуры

Процедура ЗагрузитьМакет(ИмяФайлаМакета) Экспорт
	ТекстМакета = Неопределено;
	ИмяФайла 	= ТекущийКаталог()+"\views\"+ИмяФайлаМакета+".html";
	Попытка
		Чтение 		= Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
		ТекстМакета = Чтение.Прочитать();
		Чтение.Закрыть();
	Исключение
	КонецПопытки;
КонецПроцедуры



