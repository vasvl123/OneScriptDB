﻿// /*----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------*/

using System;
using onesharp.Binary;

namespace onesharp
{
    class treedb : Onesharp
    {

        string ИмяФайлаДанных;
        ФайловыйПоток ПотокДанных;

        Массив МассивИзСтроки(string стр)
        {
            var м = Массив.Новый();
            var дстр = Стр.Длина(стр);
            for (int н = 1; н <= дстр; н++)
            {
                м.Добавить(КодСимвола(Сред(стр, н, 1)));
            }
            return м;
        } // МассивИзСтроки()


        // открыть контейнер для чтения или записи
        public bool ОткрытьПотокДанных(bool ДляЗаписи = false, object Позиция = null)
        {

            try
            {

                if (ДляЗаписи)
                {

                    if (!(ПотокДанных == Неопределено))
                    {
                        if (!(ПотокДанных.ДоступнаЗапись))
                        {
                            ПотокДанных.Закрыть();
                            ПотокДанных = null;
                        }
                    }

                    if (ПотокДанных == Неопределено)
                    {
                        ПотокДанных = МенеджерФайловыхПотоков.ОткрытьДляЗаписи(ИмяФайлаДанных);
                    }

                    if (Позиция == Неопределено)
                    {
                        ПотокДанных.Перейти(0, ПозицияВПотоке.Конец);
                    }
                    else
                    {
                        ПотокДанных.Перейти((int)Позиция, ПозицияВПотоке.Начало);
                    }

                    //ВремяИзменения = ТекущаяДата();

                }
                else
                {

                    if (!(ПотокДанных == Неопределено))
                    {
                        if (!(ПотокДанных.ДоступноЧтение))
                        {
                            ПотокДанных.Закрыть();
                            ПотокДанных = null;
                        }
                    }

                    if (ПотокДанных == Неопределено)
                    {
                        ПотокДанных = МенеджерФайловыхПотоков.ОткрытьДляЧтения(ИмяФайлаДанных);
                    }

                    if (!(Позиция == Неопределено))
                    {
                        ПотокДанных.Перейти((int)Позиция, ПозицияВПотоке.Начало);
                    }

                }

                return Истина;

            }
            catch (Exception e)
            {

                Сообщить(ОписаниеОшибки(e));
                return Ложь;

            }

        }

        public int ДобавитьЗначение(Массив гр, int н = 0)
        {

            // пройти по дереву
            ОткрытьПотокДанных();
            var буф = БуферДвоичныхДанных.Новый(16);

            // н = 0;
            var к = 1;
            var рн = 0;

            var сгр = гр.Количество();

            if (!(ПотокДанных.Размер() == 0))
            {

                while (Истина)
                {
                    var ф = (int)гр.Получить(к - 1);
                    int нн = 0;
                    while (Истина)
                    {
                        ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                        ПотокДанных.Прочитать(буф, 0, 16);
                        var ф1 = буф.ПрочитатьЦелое32(0);
                        нн = буф.ПрочитатьЦелое32(4); // позиция следующего
                        if (ф1 == ф || ф == 0)
                        { // найден элемент
                            рн = н;
                            к = к + 1;
                            if (!(к > сгр))
                            {
                                нн = буф.ПрочитатьЦелое32(8); // позиция вложенного
                                if (нн == 0)
                                { // создать ссылку на вложенный
                                    ОткрытьПотокДанных(Истина);
                                    var кн = (int)ПотокДанных.Размер();
                                    буф.ЗаписатьЦелое32(8, кн); // вложенный в конец
                                    ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                                    ПотокДанных.Записать(буф, 0, 14);
                                    //ПотокДанных.СброситьБуферы();
                                }
                            }
                            break;
                        }
                        нн = буф.ПрочитатьЦелое32(4); // позиция следующего
                        if (нн == 0)
                        { // это последний
                            ОткрытьПотокДанных(Истина);
                            var кн = (int)ПотокДанных.Размер();
                            буф.ЗаписатьЦелое32(4, кн); // соседний в конец
                            ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                            ПотокДанных.Записать(буф, 0, 16);
                            //ПотокДанных.СброситьБуферы();
                            break;
                        }
                        н = нн;
                    }
                    if (нн == 0 || к > сгр)
                    {
                        break;
                    }
                    н = нн;
                }

            }

            if (!(к > сгр))
            {

                // создать новые элементы
                ОткрытьПотокДанных(Истина);

                for (; к <= сгр; к++) {
                    var ф = (int)гр.Получить(к - 1);
                    int кн = 0;
                    ПотокДанных.Перейти(0, ПозицияВПотоке.Конец);
                    н = (int)ПотокДанных.ТекущаяПозиция();
                    if (!(к == сгр))
                    {
                        кн = н + 16;
                    }
                    else
                    {
                        кн = 0;
                    }
                    буф.ЗаписатьЦелое32(0, ф); // код символа
                    буф.ЗаписатьЦелое32(4, 0); // нет соседнего
                    буф.ЗаписатьЦелое32(8, кн); // вложенный в конец
                    буф.ЗаписатьЦелое32(12, рн); // родитель
                    ПотокДанных.Записать(буф, 0, 16);
                    рн = н;
                }

                ПотокДанных.СброситьБуферы();

            }

            return н;

        } // ДобавитьЗначение()


        public Структура ПолучитьЭлемент(int н)
        {
            var буф = БуферДвоичныхДанных.Новый(16);
            var эл = Структура.Новый();
            ОткрытьПотокДанных();
            ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
            ПотокДанных.Прочитать(буф, 0, 16);
            эл.Вставить("Значение", буф.ПрочитатьЦелое32(0));
            эл.Вставить("Соседний", буф.ПрочитатьЦелое32(4));
            эл.Вставить("Дочерний", буф.ПрочитатьЦелое32(8));
            эл.Вставить("Родитель", буф.ПрочитатьЦелое32(12));
            return эл;
        } // ПолучитьЭлемент()


        public Массив ПолучитьЗначения(int н)
        {
            var буф = БуферДвоичныхДанных.Новый(16);
            var мр = Массив.Новый();
            while (Истина)
            {
                if (н == 0)
                {
                    break;
                }
                ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                ПотокДанных.Прочитать(буф, 0, 16);
                var ф = буф.ПрочитатьЦелое32(0);
                var сн = буф.ПрочитатьЦелое32(4);
                var мф = Массив.Новый();
                мф.Добавить(ф);
                мф.Добавить(н);
                мр.Добавить(мф);
                н = сн;
            }
            return мр;
        }


        public Массив ПолучитьВложенныеЗначения(int н)
        {
            var буф = БуферДвоичныхДанных.Новый(16);
            ОткрытьПотокДанных();
            ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
            ПотокДанных.Прочитать(буф, 0, 16);
            var вн = буф.ПрочитатьЦелое32(8); // позиция вложенного
            return ПолучитьЗначения(вн);
        } // ПолучитьВложенныеЗначения()


        public string ПолучитьСтроку(int н)
        {

            var гр = "";
            var буф = БуферДвоичныхДанных.Новый(16);

            ОткрытьПотокДанных();

            while (Истина)
            {
                ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                ПотокДанных.Прочитать(буф, 0, 16);
                var ф = буф.ПрочитатьЦелое32(0);
                н = буф.ПрочитатьЦелое32(12); // позиция родителя
                if (н == 0)
                { // это первый
                    break;
                }
                гр = Символ(ф) + гр;
            }

            return гр;

        } // ПолучитьСтроку()


        public Массив ПолучитьМассив(int н)
        {

            var гр = Массив.Новый();
            var буф = БуферДвоичныхДанных.Новый(16);

            ОткрытьПотокДанных();

            while (Истина)
            {
                ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                ПотокДанных.Прочитать(буф, 0, 16);
                var ф = буф.ПрочитатьЦелое32(0);
                н = буф.ПрочитатьЦелое32(12); // позиция родителя
                гр.Вставить(0, ф);
                if (н == 0)
                { // это первый
                    break;
                }
            }

            return гр;

        } // ПолучитьМассив()


        public int НайтиЗначение(Массив нгр, int н = 0)
        {

            var буф = БуферДвоичныхДанных.Новый(16);

            ОткрытьПотокДанных();

            if (!(н == 0))
            { // искать внутри
                ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                ПотокДанных.Прочитать(буф, 0, 16);
                н = буф.ПрочитатьЦелое32(8); // позиция вложенного
                if (н == 0)
                {
                    return н;
                }
            }

            // Если НЕ ТипЗнч(нгр) = Тип("Массив") Тогда
            // 	зн = нгр;
            // 	нгр = Новый Массив;
            // 	нгр.Добавить(зн);
            // КонецЕсли;

            var сгр = нгр.Количество();

            // пройти по дереву

            var к = 1;

            while (Истина)
            {
                var ф = (int)нгр.Получить(к - 1);
                while (Истина)
                {
                    ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
                    ПотокДанных.Прочитать(буф, 0, 16);
                    var ф1 = буф.ПрочитатьЦелое32(0);
                    if (ф1 == ф || ф == 42)
                    { // найден элемент
                        if (ф == 42)
                        { // *
                            if (ф1 == (int)нгр.Получить(к + 1))
                            {
                                к = к + 1;
                            }
                        }
                        else
                        {
                            к = к + 1;
                        }
                        if (!(к > сгр))
                        {
                            н = буф.ПрочитатьЦелое32(8); // позиция вложенного
                        }
                        break;
                    }
                    н = буф.ПрочитатьЦелое32(4); // позиция следующего
                    if (н == 0 || к > сгр)
                    { // это последний
                        break;
                    }
                }
                if (н == 0 || к > сгр)
                {
                    break;
                }
            }

            return н;

        } // НайтиЗначение()


        public void УдалитьЗначение(int н)
        {

            var буф = БуферДвоичныхДанных.Новый(16);

            ОткрытьПотокДанных();
            ПотокДанных.Перейти(н, ПозицияВПотоке.Начало);
            ПотокДанных.Прочитать(буф, 0, 16);
            var сн = буф.ПрочитатьЦелое32(4); // позиция соседнего
            var рн = буф.ПрочитатьЦелое32(12); // позиция родителя

            ПотокДанных.Перейти(рн, ПозицияВПотоке.Начало);
            ПотокДанных.Прочитать(буф, 0, 16);
            var нн = буф.ПрочитатьЦелое32(8); // позиция дочернего

            if (нн == н)
            { // если это первый дочерний
                ОткрытьПотокДанных(Истина);
                буф.ЗаписатьЦелое32(8, сн);
                ПотокДанных.Перейти(рн, ПозицияВПотоке.Начало);
                ПотокДанных.Записать(буф, 0, 16);
                ПотокДанных.СброситьБуферы();

            }
            else
            { // перебрать остальные

                while (Истина)
                {
                    ПотокДанных.Перейти(нн, ПозицияВПотоке.Начало);
                    ПотокДанных.Прочитать(буф, 0, 16);
                    var пс = буф.ПрочитатьЦелое32(4); // позиция следующего
                    if (пс == н)
                    { // найден элемент
                        ОткрытьПотокДанных(Истина);
                        буф.ЗаписатьЦелое32(4, сн);
                        ПотокДанных.Перейти(нн, ПозицияВПотоке.Начало);
                        ПотокДанных.Записать(буф, 0, 16);
                        ПотокДанных.СброситьБуферы();
                        break;
                    }
                    if (пс == 0)
                    {
                        break;
                    }
                    нн = пс;
                }

            }

        } // УдалитьЗначение()


        public void Закрыть()
        {
            if (!(ПотокДанных == Неопределено))
            {
                ПотокДанных.Закрыть();
            }
        } // Закрыть()


        public treedb(string ЗначИмяФайлаДанных) : base ("treedb")
        {
            ИмяФайлаДанных = ЗначИмяФайлаДанных;
            var _Файл = Файл.Новый(ИмяФайлаДанных);
            if (!(_Файл.Существует()))
            {
                var дФайл = ПолучитьДвоичныеДанныеИзСтроки("");
                дФайл.Записать(ИмяФайлаДанных);
            }
        }

    }
}
