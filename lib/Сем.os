// MIT License
// Copyright (c) 2020 vasvl123
// https://github.com/vasvl123/useyourmind

Перем пДанные;
Перем Правила;
Перем Формы;


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


Процедура ФормыСлов(Данные, Свойства, Результат) Экспорт
	Если НЕ Результат = Неопределено Тогда
		Для каждого Вариант Из Результат Цикл
			ф = Формы.с.Получить(Вариант.Значение.Слово);
			мРез = СтрРазделить(Вариант.Значение.Результат, Символы.ПС);
			Для каждого Рез Из мРез Цикл
				Если НЕ Рез = "" Тогда
					мФорм = СтрРазделить(Рез, Символы.Таб);
					ф0 = мФорм[0];
					ф1 = мФорм[1];
					Если ф1 = "PREP" ИЛИ ф1 = "PRCL" ИЛИ ф1 = "PNCT" ИЛИ ф1 = "CONJ" Тогда
						ф1 = ф1 + " " + ф0;
					КонецЕсли;
					Запись = ИмяЗначение(ф0, ф1);
					у = Данные.НовыйДочерний(ф, Запись, , Истина); // Добавить форму
					Если мФорм.Количество() > 2 Тогда
						Данные.НовыйАтрибут(у, ИмяЗначение(мФорм[2], мФорм[3]));
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	Свойства.д.Разбор.Значение = "Токены";
	Данные.ОбъектыОбновитьДобавить(Свойства.Родитель);
КонецПроцедуры


Процедура ПостроитьИндекс(пУзел, Рекурс = Ложь)
	пУзел.Вставить("с", Новый Соответствие);
	дУзел = пУзел.Дочерний;
	Пока НЕ дУзел = Неопределено Цикл
		Если Рекурс Тогда
			ПостроитьИндекс(дУзел);
		КонецЕсли;
		ин = 0;
		Пока НЕ пУзел.с.Получить(дУзел.Имя + "_" + ин) = Неопределено Цикл
			ин = ин + 1;
		КонецЦикла;
		пУзел.с.Вставить(дУзел.Имя + "_" + ин, дУзел);
		дУзел = дУзел.Соседний;
	КонецЦикла;
КонецПроцедуры

Функция Корень_Свойства(Данные, оУзел) Экспорт

	Если пДанные = Неопределено Тогда // Загрузить правила анализа
		Запрос = Новый Структура("sdata, data", Данные.Процесс.Субъект, "semdata");
		пДанные = Данные.Процесс.ПолучитьДанные(Новый Структура("Запрос", Запрос));
		Если пДанные = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	Если НЕ пДанные.Корень.Свойство("Свойства") Тогда
		пДанные.ОбъектыОбновить.Добавить(пДанные.Корень);
		Возврат Ложь;
	КонецЕсли;
	Если Правила = Неопределено Тогда // построить индекс
		Правила = пДанные.Корень.Свойства.д.Правила;
		ПостроитьИндекс(Правила, Истина);
	КонецЕсли;
	Если НЕ оУзел.Свойство("Свойства") Тогда // новый объект
		Свойства = Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
		оУзел.Вставить("Свойства", Свойства);
	КонецЕсли;
	Если оУзел.Свойства.Дочерний = Неопределено Тогда
		шСвойства = "
		|*Формы
		|*Вид
		|	div	class=card mb-3 col-lg-7	style=background-color:rgba(255,255,255,0.4); min-height:20rem
		|		div	class=card-body
		|			h4: OpenCorpora datasets
		|			П: Содержимое
		|";
		Данные.СоздатьСвойства(оУзел.Свойства, шСвойства, "Только");
	КонецЕсли;
	Если Формы = Неопределено Тогда // формы слов
		Формы = оУзел.Свойства.д.Формы;
		Формы.Вставить("с", Новый Соответствие);
		фУзел = Формы.Дочерний;
		Пока НЕ фУзел = Неопределено Цикл
			Формы.с.Вставить(фУзел.Имя, фУзел);
			фУзел = фУзел.Соседний;
		КонецЦикла;
	КонецЕсли;
КонецФункции // Корень_Свойства()


Функция Страница_Свойства(Данные, оУзел) Экспорт

	//Если НЕ оУзел.Свойство("Свойства") Тогда // новый объект
		Свойства = оУзел.Дочерний; //Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
		шСвойства = "
		|*События
		|*Показать: Нет
		|*Кнопка
		|*Вид
		|	З: Кнопка
		|	: Если
		|		З: Показать
		|		П: Содержимое
		|";
		Данные.СоздатьСвойства(Свойства, шСвойства);
		оУзел.Вставить("Свойства", Свойства);
	//КонецЕсли;

КонецФункции


Функция Страница_Модель(Данные, Свойства, Изменения) Экспорт

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

	// сформировать представление
	ш = "<button id='_" + оУзел.Код + "' type='button' class='text-left btn1 btn-primary' onclick='addcmd(this,event); return false' role='sent'>.текст</button>";
	см = ?(Свойства.д.Показать.Значение = "Нет", "&#9655;", "&#9661;");
	Вид = СтрЗаменить(ш, ".текст", см);
	Вид = "<div class='btn-group' role='group'>" + Вид + СтрЗаменить(ш, ".текст", Свойства.д.Номер.Значение) + "</div>";

	Свойства.д.Кнопка.Значение = Вид;

КонецФункции


Функция Предложение_Свойства(Данные, оУзел) Экспорт

	Если НЕ оУзел.Свойство("Свойства") Тогда // новый объект
		Свойства = Данные.НовыйДочерний(оУзел, ИмяЗначение("Свойства.", ""), Данные.Служебный(оУзел));
		шСвойства = "
		|Токены
		|Разбор: Нет
		|*Открыть: Нет
		|*вТокен
		|*вПравило
		|*вСвязь
		|*События
		|*Вид";
		Данные.СоздатьСвойства(Свойства, шСвойства);
		оУзел.Вставить("Свойства", Свойства);
	КонецЕсли;

КонецФункции

Функция НайтиПравило(ток1Форма, ток2Форма, вСвязь, п1 = Неопределено)

	и1 = 0;
	Пока Истина Цикл
		п1 = Правила.с.Получить(ток1Форма + "_" + и1); // поиск правил
		Если п1 = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		и2 = 0;
		Пока Истина Цикл
			п2 = п1.с.Получить(ток2Форма + "_" + и2);
			Если п2 = Неопределено Тогда
				Возврат Неопределено;
			КонецЕсли;
			Если п2.Значение = вСвязь Тогда // найдено правило
				Возврат п2;
			КонецЕсли;
			и2 = и2 + 1;
		КонецЦикла;
		и1 = и1 + 1;
	КонецЦикла;

КонецФункции // НайтиПравило()

Функция ДобавитьПравило(Данные, вТокен, сУзел, вСвязь)

	ток1Форма = вТокен.Значение;
	ток2Форма = сУзел.Значение;

	п1 = Неопределено;
	п2 = НайтиПравило(ток1Форма, ток2Форма, вСвязь, п1);

	// Добавить правило
	Если п2 = Неопределено Тогда
		Если п1 = Неопределено Тогда
			п1 = пДанные.НовыйДочерний(Правила, ИмяЗначение(ток1Форма), , Истина);
			ПостроитьИндекс(Правила);
		КонецЕсли;
		п2 = пДанные.НовыйДочерний(п1, ИмяЗначение(ток2Форма, вСвязь), , Истина);
		ПостроитьИндекс(п1);
	КонецЕсли;

	Возврат п2;

КонецФункции // ()

Функция Предложение_Модель(Данные, Свойства, Изменения) Экспорт
	Перем Обновить, пр;

	оУзел = Свойства.Родитель;

	вТокен = Свойства.д.вТокен.Значение;
	вСвязь = Свойства.д.вСвязь.Значение;

	// обработать события
	Если Изменения.Получить(Свойства.д.События) = Истина Тогда
		дУзел = Свойства.д.События.Дочерний;
		Если НЕ дУзел = Неопределено Тогда
			мСобытие = СтрРазделить(дУзел.Значение, Символы.Таб);
			тСобытие = мСобытие[0];
			Если тСобытие = "ПриНажатии" Тогда
				сУзел = Данные.ПолучитьУзел(мСобытие[1]);

				ЗначениеКнопка = УзелСвойство(дУзел, "Параметры");
				Если НЕ ЗначениеКнопка = Неопределено Тогда

					Если ЗначениеКнопка = "sent" Тогда
						см = Свойства.д.Открыть.Значение;
						см = ?(см = "Да", "Нет", "Да");
						Свойства.д.Открыть.Значение = см;

					ИначеЕсли ЗначениеКнопка = "token" ИЛИ ЗначениеКнопка = "optoken" Тогда

						Если НЕ вТокен = сУзел Тогда
							Если НЕ вСвязь = "" Тогда
								// добавить связь
								нУзел = Данные.НовыйДочерний(вТокен, ИмяЗначение(вСвязь, сУзел.Имя));
								Данные.НовыйАтрибут(нУзел, ИмяЗначение(вТокен.Значение, сУзел.Значение));
								// добавить правило
								п2 = ДобавитьПравило(Данные, вТокен, сУзел, вСвязь);
								пДанные.НовыйДочерний(п2, ИмяЗначение(вТокен.Имя, сУзел.Имя));
								Свойства.д.вСвязь.Значение = "";
								вСвязь = Свойства.д.вСвязь.Значение;
							Иначе
								Свойства.д.вТокен.Значение = сУзел;
								вТокен = Свойства.д.вТокен.Значение;
							КонецЕсли;

						ИначеЕсли ЗначениеКнопка = "optoken" Тогда

							Параметры = Новый Структура;
							Параметры.Вставить("nodeid", сУзел.Код);
							Параметры.Вставить("data", Данные.ИмяДанных);
							Параметры.Вставить("type", "win");
							Параметры.Вставить("mode", "struct");
							Параметры.Вставить("cmd", "newtab");
							Данные.Процесс.НоваяЗадача(Параметры, "Служебный");

						Иначе
							Свойства.д.вСвязь.Значение = "";
							вСвязь = Свойства.д.вСвязь.Значение;
							Свойства.д.вТокен.Значение = "";
							вТокен = Свойства.д.вТокен.Значение;
						КонецЕсли;

					ИначеЕсли ЗначениеКнопка = "link" Тогда

						Если НЕ Свойства.д.вПравило.Значение = сУзел Тогда
							Свойства.д.вПравило.Значение = сУзел;
						Иначе
							Свойства.д.вПравило.Значение = Неопределено;
						КонецЕсли;

					ИначеЕсли Лев(ЗначениеКнопка, 5) = "link_" Тогда

						св = Сред(ЗначениеКнопка, 6);
						Если НЕ вСвязь = св Тогда
							Свойства.д.вСвязь.Значение = св;
							вСвязь = Свойства.д.вСвязь.Значение;
						Иначе
							Свойства.д.вСвязь.Значение = "";
							вСвязь = Свойства.д.вСвязь.Значение;
						КонецЕсли;

					ИначеЕсли Лев(ЗначениеКнопка, 5) = "rule_" Тогда

						Параметры = Новый Структура;
						Параметры.Вставить("nodeid", Сред(ЗначениеКнопка, 6));
						Параметры.Вставить("data", "semdata");
						Параметры.Вставить("type", "win");
						Параметры.Вставить("mode", "struct");
						Параметры.Вставить("cmd", "newtab");
						Данные.Процесс.НоваяЗадача(Параметры, "Служебный");

					КонецЕсли;

				КонецЕсли;

			Иначе // изменение полей
				сУзел = Данные.ПолучитьУзел(мСобытие[1]);
				Свойства.д.вСвязь.Значение = дУзел.Параметры;
				вСвязь = Свойства.д.вСвязь.Значение;
			КонецЕсли;

		КонецЕсли;
		Данные.УдалитьУзел(дУзел);
		Изменения.Вставить(Свойства.д.События, Истина);
		оУзел.Вставить("Обновить", Истина);
	КонецЕсли;

	Если НЕ УзелСвойство(оУзел, "Обновить") = Ложь Тогда

		// найти формы
		Если Свойства.д.Разбор.Значение = "Нет" И Свойства.д.Открыть.Значение = "Да" Тогда
			Если Свойства.д.Свойство("Текст", пр) Тогда
				сСимв = ".,!?:;()«»""'-–…";
				Для н = 1 По стрДлина(сСимв) Цикл
					сс = Сред(сСимв, н, 1);
					пр = СтрЗаменить(пр, сс, " " + сс + " ");
				КонецЦикла;
				м = СтрРазделить(пр, " ");
				мсл = "";
				Для каждого сл Из м Цикл
					Если НЕ сл = "" Тогда
						// взять готовую форму
						Если НЕ оУзел.Атрибут.Соседний = Неопределено Тогда
							токФорма = "";
							тУзел = оУзел.Атрибут.Соседний.Дочерний;
							Пока НЕ тУзел = Неопределено Цикл
								Если тУзел.Имя = сл Тогда
									токФорма = тУзел.Значение;
									Прервать;
								КонецЕсли;
								тУзел = тУзел.Соседний;
							КонецЦикла;
						КонецЕсли;
						Если токФорма = "PREP" ИЛИ токФорма = "PRCL" ИЛИ токФорма = "PNCT" ИЛИ токФорма = "CONJ" Тогда
							токФорма = токФорма + " " + Врег(сл);
						КонецЕсли;
						т = Данные.НовыйДочерний(Свойства.д.Токены, ИмяЗначение(сл, токФорма), , Истина);
						Если стрНайти(сСимв, сл) = 0 Тогда
							всл = ВРег(сл);
							Если Формы.с.Получить(всл) = Неопределено Тогда
								ф = Данные.НовыйДочерний(Формы, ИмяЗначение(всл), , Истина);
								Формы.с.Вставить(всл, ф);
								мсл = мсл + Символы.ПС + всл;
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
				Запрос = Новый Структура("Библиотека, Данные, Слова, Свойства, cmd", ЭтотОбъект, Данные, Сред(мсл, 2), Свойства, "ФормыСлов");
				Данные.Процесс.НоваяЗадача(Запрос, "Служебный");
				Свойства.д.Разбор.Значение = "Формы";
			Иначе // нечего разбирать
				оУзел.Вставить("Обновить", Ложь);
			КонецЕсли;
		КонецЕсли;

		// найти правила
		Если Свойства.д.Разбор.Значение = "Токены" Тогда
			ток1 = Свойства.д.Токены.Дочерний;
			Пока НЕ ток1 = Неопределено Цикл
				ток1Формы = Формы.с.Получить(ВРег(ток1.Имя));
				Если НЕ ток1Формы = Неопределено Тогда
					фУзел1 = ток1Формы.Дочерний;
					Пока НЕ фУзел1 = Неопределено Цикл // варианты форм
						Если НЕ "" + ток1.Значение = "" Тогда
							Если НЕ фУзел1.Значение = ток1.Значение Тогда // если форма известна
								фУзел1 = фУзел1.Соседний;
								Продолжить;
							КонецЕсли;
						КонецЕсли;
						и1 = 0;
						Пока Истина Цикл
							п1 = Правила.с.Получить(фУзел1.Значение + "_" + и1); // поиск правил
							Если п1 = Неопределено Тогда
								Прервать;
							КонецЕсли;
							ток2 = Свойства.д.Токены.Дочерний;
							Пока НЕ ток2 = Неопределено Цикл
								Если НЕ ток1 = ток2 Тогда
									ток2Формы = Формы.с.Получить(ВРег(ток2.Имя)); // формы токена
									Если НЕ ток2Формы = Неопределено Тогда
										фУзел2 = ток2Формы.Дочерний;
										Пока НЕ фУзел2 = Неопределено Цикл
											Если НЕ "" + ток2.Значение = "" Тогда // если форма известна
												Если НЕ фУзел2.Значение = ток2.Значение Тогда
													фУзел2 = фУзел2.Соседний;
													Продолжить;
												КонецЕсли;
											КонецЕсли;
											и2 = 0;
											Пока Истина Цикл
												п2 = п1.с.Получить(фУзел2.Значение + "_" + и2); // форма соответствует правилу
												Если п2 = Неопределено Тогда
													Прервать;
												КонецЕсли;
												// найдено подходящее правило
												Верно = Истина;
												Если п2.Имя = "ADVB" Тогда // с наречиями ищем полное соответствие
													Верно = Ложь;
													фУзел3 = п2.Дочерний;
													Пока НЕ фУзел3 = Неопределено Цикл
														Если ВРег(фУзел3.Значение) = ВРег(ток2.Имя) Тогда
															Верно = Истина;
															Прервать;
														КонецЕсли;
														фУзел3 = фУзел3.Соседний;
													КонецЦикла;
												КонецЕсли;
												Если Верно Тогда
													нп = Данные.НовыйДочерний(ток1, ИмяЗначение(п2.Значение, ток2.Имя), , Истина);
													Данные.НовыйАтрибут(нп, ИмяЗначение(ток2.код));
													Данные.НовыйАтрибут(нп, ИмяЗначение(п1.Имя, п2.Имя));
													//пДанные.НовыйДочерний(п2, ИмяЗначение(ток1.Имя, ток2.Имя), Истина, Истина); // для отладки
												КонецЕсли;
												и2 = и2 + 1;
											КонецЦикла;
											фУзел2 = фУзел2.Соседний;
										КонецЦикла;
									КонецЕсли;
								КонецЕсли;
								ток2 = ток2.Соседний;
							КонецЦикла;
							и1 = и1 + 1;
						КонецЦикла;
						фУзел1 = фУзел1.Соседний;
					КонецЦикла;
				КонецЕсли;
				ток1 = ток1.Соседний;
			КонецЦикла;

			Свойства.д.Разбор.Значение = "Выполнен";
			оУзел.Вставить("Обновить", Ложь);

		КонецЕсли;

		//Привязать токены
		ток1 = Свойства.д.Токены.Дочерний;
		т1 = 1;
		Пока НЕ ток1 = Неопределено Цикл
			а = Ток1.Атрибут;
			пр = Данные.УзелСвойство(Ток1, "пр");
			т2 = 1;
			ток2 = Свойства.д.Токены.Дочерний;
			Пока НЕ ток2 = Неопределено Цикл
				Если НЕ ток1 = ток2 Тогда
					св = ток2.Дочерний;
					Пока НЕ св = Неопределено Цикл
						Если св.Атрибут.Соседний.Имя = ток1.Код Тогда
							р = т2 - т1;
							Если р < 0 Тогда
								р = -р;
							КонецЕсли;
							Если а = Неопределено Тогда
								а = Данные.НовыйАтрибут(ток1, ИмяЗначение(ток2.Код, ток2.Имя));
								пр = р;
							ИначеЕсли р < пр Тогда
								а.Имя = ток2.Код;
								а.Значение = ток2.Имя;
								пр = р;
							КонецЕсли;
						КонецЕсли;
						св = св.Соседний;
					КонецЦикла;
				КонецЕсли;
				ток2 = ток2.Соседний;
				т2 = т2 + 1;
			КонецЦикла;
			ток1.Вставить("пр", пр);
			ток1 = ток1.Соседний;
			т1 = т1 + 1;
		КонецЦикла;

		// сформировать представление
		Вид = "";
		Если Свойства.д.Свойство("Текст", пр) Тогда // Предложение
			ш = "<button id='_" + оУзел.Код + "' type='button' class='text-left btn1 btn-light' onclick='addcmd(this,event); return false' role='sent'>.текст</button>";
			см = ?(Свойства.д.Открыть.Значение = "Нет", "&#9655;", "&#9661;");
			Вид = СтрЗаменить(ш, ".текст", см);
			Если Свойства.д.Открыть.Значение = "Нет" Тогда
				Вид = "<div class='btn-group' role='group'>" + Вид + СтрЗаменить(ш, ".текст", пр) + "</div>";
			Иначе
				тУзел = Свойства.д.Токены.Дочерний;
				Пока НЕ тУзел = Неопределено Цикл
					Вид = Вид + "<button id='_" + тУзел.Код + "' type='button' class='text-left btn1 btn-" + ?(вТокен = тУзел, "info", "light") + "' onclick='addcmd(this,event); return false' role='token'>" + тУзел.Имя + "</button>";
					Вид = Вид + "<!--t_" + тУзел.Код + "-->";
					тУзел = тУзел.Соседний;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;

		Если НЕ Свойства.д.Разбор.Значение = "Нет" И Свойства.д.Открыть.Значение = "Да" Тогда // Токены
			тУзел = Свойства.д.Токены.Дочерний;
			Вид = Вид + "<p>" + ТокенВид(Свойства, тУзел) + "</p>";
		КонецЕсли;

		Если НЕ вТокен = "" Тогда // выбрать связь
			// показать виды связей
			нСв = "";
			Связи = Новый Массив;
			Если НЕ вСвязь = "" Тогда
				Связи.Добавить(вСвязь);
			Иначе
				ток1Формы = Формы.с.Получить(ВРег(вТокен.Имя));
				Если НЕ ток1Формы = Неопределено Тогда
					фУзел1 = ток1Формы.Дочерний;
					Пока НЕ фУзел1 = Неопределено Цикл // варианты форм
						и1 = 0;
						Пока Истина Цикл
							п1 = Правила.с.Получить(фУзел1.Значение + "_" + и1); // поиск правил
							Если п1 = Неопределено Тогда
								Прервать;
							КонецЕсли;
							Для каждого п2 Из п1.с Цикл // все связи
								Если Связи.Найти(п2.Значение.Значение) = Неопределено Тогда
									Связи.Добавить(п2.Значение.Значение);
								КонецЕсли;
							КонецЦикла;
							и1 = и1 + 1;
						КонецЦикла;
						фУзел1 = фУзел1.Соседний;
					КонецЦикла;
				КонецЕсли;
				Связи.Добавить("+");
			КонецЕсли;
			Если вСвязь = "+" Тогда
				нСв = нСв + "<input id='" + вТокен.Код + "' type='text' class='form-control-sm' onchange='addcmd(this,event); return false' role='link'></input>";
				нСв = нСв + "<script>$('#" + вТокен.Код + "')[0].focus();</script>";
			Иначе
				Для каждого св Из Связи Цикл
					Если вСвязь = "" ИЛИ св = вСвязь Тогда
						нСв = нСв + "<button id='_" + вТокен.Код + "' type='button' class='text-left btn1 btn-" + ?(вСвязь = "", "secondary", "warning") + "' onclick='addcmd(this,event); return false' role='link_" + св + "'>" + св + "</button>";
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
			Вид = СтрЗаменить(Вид, "<!--t_" + вТокен.Код + "-->", нСв);
		КонецЕсли;

		Свойства.д.Вид.Значение = "<p>" + Вид + "</p>";

	КонецЕсли;

	Возврат Обновить;

КонецФункции

Функция ТокенВид(Свойства, Знач дУзел, мУзел = Неопределено, рУзел = Неопределено)
	Связи = "";
	вТокен = Свойства.д.вТокен.Значение;
	Пока НЕ дУзел = Неопределено Цикл
		Связь = "";
		Если дУзел.Родитель = Свойства.д.Токены Тогда
			мУзел = Новый Массив;
			мУзел.Добавить(дУзел);
			Если вТокен = "" ИЛИ вТокен = дУзел Тогда
				Связь = "<button id='_" + дУзел.Код + "' type='button' class='text-left btn1 btn-" + ?(вТокен = дУзел, "info", "light") + "' onclick='addcmd(this,event); return false' role='optoken'>" + дУзел.Имя + "</button>";
				Если НЕ дУзел.Дочерний = Неопределено Тогда
					Связь = Связь + ТокенВид(Свойства, дУзел.Дочерний, мУзел);
				КонецЕсли;
			КонецЕсли;
		Иначе
			// фильтр некоректных связей
			Верно = Истина;
			Если НЕ рУзел = Неопределено Тогда
				Если НЕ (ВРег(рУзел.Имя + " " + рУзел.Значение) = ВРег(дУзел.Имя) ИЛИ ВРег(рУзел.Имя) = ВРег(дУзел.Имя)) Тогда
					Верно = Ложь;
				КонецЕсли;
			КонецЕсли;
			Если Верно Тогда
				тУзел = Свойства.д.Токены.Дочерний;
				Пока НЕ тУзел = Неопределено Цикл // Проверить привязки
					Если тУзел.Код = дУзел.Атрибут.Соседний.Имя Тогда // связанный токен
						Если НЕ тУзел.Атрибут = Неопределено Тогда
							Если тУзел.Атрибут.Имя = дУзел.Родитель.Код Тогда // привязка соответствует
								Прервать;
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
					тУзел = тУзел.Соседний;
				КонецЦикла;
				Если НЕ тУзел = Неопределено Тогда
					Если мУзел.Найти(тУзел) = Неопределено Тогда
						мУзел.Добавить(тУзел);
						Связь = "<button id='_" + дУзел.Код + "' type='button' class='text-left btn1 btn-secondary' onclick='addcmd(this,event); return false' role='link'>" + дУзел.Имя + "</button>";
						// если нужно показать правило
						Если дУзел = Свойства.д.вПравило.Значение Тогда
							п1 = Неопределено;
							ток1Форма = дУзел.Атрибут.Имя;
							ток2Форма = дУзел.Атрибут.Значение;
							п2 = НайтиПравило(ток1Форма, ток2Форма, дУзел.Имя, п1);
							Связь = Связь + "<button id='_" + дУзел.Код + "' type='button' class='text-left btn1 btn-secondary' onclick='addcmd(this,event); return false' role='rule_" + п1.Код + "'>" + ток1Форма + "</button>";
							Связь = Связь + "<button id='_" + дУзел.Код + "' type='button' class='text-left btn1 btn-secondary' onclick='addcmd(this,event); return false' role='rule_" + п2.Код + "'>" + ток2Форма + "</button>";
						КонецЕсли;
						Связь = Связь + "<button id='_" + тУзел.Код + "' type='button' class='text-left btn1 btn-light' onclick='addcmd(this,event); return false' role='token'>" + дУзел.Значение + "</button>";
						Если НЕ тУзел.Дочерний = Неопределено Тогда
							Если Лев(дУзел.Атрибут.Значение, 4) = "PREP" Тогда
								зСвязь = ТокенВид(Свойства, тУзел.Дочерний, мУзел, дУзел);
								Если зСвязь = "" Тогда
									Связь = "";
								КонецЕсли;
								Связь = Связь + зСвязь;
							Иначе
								Связь = Связь + ТокенВид(Свойства, тУзел.Дочерний, мУзел);
							КонецЕсли;
						КонецЕсли;
						мУзел.Удалить(мУзел.Найти(тУзел));
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если НЕ Связь = "" Тогда
			Связь = "<ul>" + Связь + "</ul>";
			Связи = Связи + Связь;
		КонецЕсли;
		дУзел = дУзел.Соседний;
	КонецЦикла;
	Возврат Связи;
КонецФункции // ТокенВид()
