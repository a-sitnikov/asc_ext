﻿Перем КонтекстЯдра;
Перем Ожидаем;
Перем Утверждения;
Перем ГенераторТестовыхДанных;
Перем ЗапросыИзБД;
Перем УтвержденияПроверкаТаблиц;

Перем ОбработкаОбъект;
Перем Параметры;
Перем СвойствоID;

#Область ЮнитТестирование

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
	Ожидаем = КонтекстЯдра.Плагин("УтвержденияBDD");
	Утверждения = КонтекстЯдра.Плагин("БазовыеУтверждения");
	ГенераторТестовыхДанных = КонтекстЯдра.Плагин("СериализаторMXL");
	ЗапросыИзБД = КонтекстЯдра.Плагин("ЗапросыИзБД");
	УтвержденияПроверкаТаблиц = КонтекстЯдра.Плагин("УтвержденияПроверкаТаблиц");
КонецПроцедуры

Процедура ЗаполнитьНаборТестов(НаборТестов) Экспорт
	
	НаборТестов.Добавить("Реализация");
	НаборТестов.Добавить("Реализация_ОплатаВБанке");
	НаборТестов.Добавить("РТУ_ИзменениеЦентра");
	НаборТестов.Добавить("РТУ_ИзменениеНоменклатуры");
	НаборТестов.Добавить("РТУ_ИзменениеЦентра_ДатаЗапрета");
	НаборТестов.Добавить("РТУ_ИзменениеДоговора_ДатаЗапрета");
	НаборТестов.Добавить("РТУ_ОтвязкаПлатежа");
	НаборТестов.Добавить("РТУ_ОтвязкаПлатежа_ДатаЗапрета");
	
КонецПроцедуры

Процедура ПередЗапускомТеста() Экспорт
	
	Каталог = "C:\Users\avsitnikov\Desktop\Данные\asc_ext\Обработки\";
	ОбработкаОбъект = ВнешниеОбработки.Создать(Каталог + "ЗагрузкаДокументовРеализацияИзUnicus.epf", Ложь);
	
	Параметры = Новый Структура;
	Параметры.Вставить("ДатаНач", '2018-01-01');
	Параметры.Вставить("ДатаКон", '2018-12-31');
	Параметры.Вставить("База",    Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус"));
	
	Параметры.Вставить("ПерезаполнятьДокументы",   Ложь);
	Параметры.Вставить("ПерезаполнятьДоговоры",    Ложь);
	Параметры.Вставить("ВыводитьСообщения",        Ложь);
	Параметры.Вставить("ОтложенноеПроведение",     Истина);
	Параметры.Вставить("ЗагружатьДокументыОплаты", Ложь);
	
	УстановитьДатуЗапрета('2017-12-31');
	
	СвойствоID = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "ID_Unicus");
	УдалитьДанные();
	
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	
	ОбработкаОбъект = Неопределено;
	
КонецПроцедуры

Функция РазрешенСлучайныйПорядокВыполненияТестов() Экспорт
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти

#Область Общие

Процедура УдалитьДанные()
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Свойство", СвойствоID);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК Рег 
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КорректировкаРеализации КАК Док 
	|		ПО Док.ДокументРеализации = Рег.Объект
	|ГДЕ
	|	Рег.Свойство = &Свойство
	|	И ВЫРАЗИТЬ(Рег.Значение КАК ЧИСЛО) > 999999999000
	|
	|УПОРЯДОЧИТЬ ПО
	|	Док.Дата УБЫВ";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаТЗ из Таблица Цикл
		
		ДокументОбъект = СтрокаТЗ.Ссылка.ПолучитьОбъект();
		ДокументОбъект.Удалить();
		
	КонецЦикла;	
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Рег.Объект КАК Ссылка
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК Рег 
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК Док 
	|		ПО Док.Ссылка = Рег.Объект
	|ГДЕ
	|	Рег.Свойство = &Свойство
	|	И ВЫРАЗИТЬ(Рег.Значение КАК ЧИСЛО) > 999999999000
	|
	|УПОРЯДОЧИТЬ ПО
	|	Док.Дата УБЫВ";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаТЗ из Таблица Цикл
		
		ДокументОбъект = СтрокаТЗ.Ссылка.ПолучитьОбъект();
		ДокументОбъект.Удалить();
		
	КонецЦикла;	
	
	Запрос.Параметры.Вставить("Наименование", "TEST%");
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Наименование ПОДОБНО &Наименование";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаТЗ из Таблица Цикл
		
		ДокументОбъект = СтрокаТЗ.Ссылка.ПолучитьОбъект();
		ДокументОбъект.Удалить();
		
	КонецЦикла;	
	
КонецПроцедуры	

Процедура УстановитьДатуЗапрета(Дата)
	
	НаборЗаписей = РегистрыСведений.ДатыЗапретаИзменения.СоздатьНаборЗаписей();
	
	Запись = НаборЗаписей.Добавить();
	Запись.ДатаЗапрета  = Дата;
	Запись.Пользователь = Перечисления.ВидыНазначенияДатЗапрета.ДляВсехПользователей;
	Запись.Объект       = ПланыВидовХарактеристик.РазделыДатЗапретаИзменения.ПустаяСсылка();
	
	НаборЗаписей.Записать();
	
	ПараметрыСеанса.ДействующиеДатыЗапретаИзменения = ДатыЗапретаИзмененияСлужебный.тестЗначениеПараметраСеансаДействующиеДатыЗапретаИзменения();
	
КонецПроцедуры	

#КонецОбласти

Процедура Реализация() Экспорт
	
	Макет = ПолучитьМакет("Реализации");
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет);
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	СвойствоID = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "ID_Unicus");
	ДокументСсылка = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументСсылка, "Документ РТУ не создан");
	
КонецПроцедуры

Процедура Реализация_ОплатаВБанке() Экспорт
	
	Макет = ПолучитьМакет("Реализация_ОплатаВБанке");
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет);
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", "TEST-00001");
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК Док
	|ГДЕ
	|	Док.ДоговорКонтрагента.Наименование = &Наименование";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		ДокументСсылка = Результат.Выгрузить()[0][0];
	Иначе
		ДокументСсылка = Неопределено;
	КонецЕсли;
	
	Утверждения.ПроверитьЗаполненность(ДокументСсылка, "Документ РТУ не создан");
	
	Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДокументСсылка, "Комментарий, РучнаяКорректировка");
	Утверждения.ПроверитьРавенство(Реквизиты.Комментарий, "Оплата в Банке",  "Не указан комментарий");
	Утверждения.ПроверитьИстину(Реквизиты.РучнаяКорректировка, "Не указан ручная корректировка");
	
КонецПроцедуры

Процедура РТУ_ИзменениеЦентра() Экспорт
	
	Макет = ПолучитьМакет("РТУ_ИзменениеЦентра");
	
	//Киа Север 02.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область1"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументСсылка = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументСсылка, "Документ РТУ не создан");
	
	ДЦ = УправлениеСвойствами.ЗначениеСвойства(ДокументСсылка, "ДЦ");
	Утверждения.ПроверитьРавенство(Строка(ДЦ), "КИА-Север",  "Не верный ДЦ");
	
	
	//Инфинити Химки  02.03
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область2"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДЦ = УправлениеСвойствами.ЗначениеСвойства(ДокументСсылка, "ДЦ");
	Утверждения.ПроверитьРавенство(Строка(ДЦ), "Инфинити-Химки",  "Не верный ДЦ");
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Элемент", ДокументСсылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КОЛИЧЕСТВО(*) КАК Колво
	|ИЗ
	|	РегистрСведений.ИзмененныеОбъектыДляВыгрузки КАК Рег
	|ГДЕ
	|	Рег.Элемент = &Элемент";
	
	Колво = Запрос.Выполнить().Выгрузить()[0][0];
	Утверждения.ПроверитьРавенство(Колво, 2,  "Должно быть 2 записи к выгрузке");
	
КонецПроцедуры

Процедура РТУ_ИзменениеНоменклатуры() Экспорт
	
	Макет = ПолучитьМакет("РТУ_ИзменениеНоменклатуры");
	
	//ОСАГО
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область1"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументСсылка = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументСсылка, "Документ РТУ не создан");
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Ссылка", ДокументСсылка);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ДокАгентскиеУслуги.Номенклатура.Наименование КАК Номенклатура,
	|	ДокАгентскиеУслуги.Ссылка.ДоговорКонтрагента.ОсновнаяСтатьяИсполнение КАК Статья
	|ИЗ
	|	Документ.РеализацияТоваровУслуг.АгентскиеУслуги КАК ДокАгентскиеУслуги
	|ГДЕ
	|	ДокАгентскиеУслуги.Ссылка = &Ссылка";
	
	Реквизиты = Запрос.Выполнить().Выгрузить()[0];
	
	Утверждения.ПроверитьРавенство(Реквизиты.Номенклатура, "ОСАГО, АМ бу.",  "Не верная номенклатура");
	Утверждения.ПроверитьРавенство(Строка(Реквизиты.Статья), "ОСАГО  а/м с пробегом",  "Не верная статья");
	
	
	//КАСКО
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область2"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	Реквизиты = Запрос.Выполнить().Выгрузить()[0];
	
	Утверждения.ПроверитьРавенство(Реквизиты.Номенклатура, "КАСКО, АМ бу.",  "Не верная номенклатура");
	Утверждения.ПроверитьРавенство(Строка(Реквизиты.Статья), "КАСКО а/м с пробегом",  "Не верная статья");
	
КонецПроцедуры

Процедура РТУ_ИзменениеЦентра_ДатаЗапрета() Экспорт
	
	Макет = ПолучитьМакет("РТУ_ИзменениеЦентра");
	
	//Киа Север 02.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область1"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументРТУ1 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументРТУ1, "Документ РТУ не создан");
	
	ДЦ = УправлениеСвойствами.ЗначениеСвойства(ДокументРТУ1, "ДЦ");
	Утверждения.ПроверитьРавенство(Строка(ДЦ), "КИА-Север",  "Не верный ДЦ");
	
	// Закрываем период
	УстановитьДатуЗапрета('2018-02-28');
	
	
	//Инфинити Химки  02.03
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область2"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументСторно = ОбработкаОбъект.НайтиДокументСторно(ДокументРТУ1);
	Утверждения.ПроверитьЗаполненность(ДокументСторно, "Документ сторно не создан");
	
	ДокументРТУ2 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	Утверждения.ПроверитьНеРавенство(ДокументРТУ1, ДокументРТУ2, "Новый документ РТУ не создан");
	
	ДЦ = УправлениеСвойствами.ЗначениеСвойства(ДокументРТУ2, "ДЦ");
	Утверждения.ПроверитьРавенство(Строка(ДЦ), "Инфинити-Химки",  "Не верный ДЦ");
	
КонецПроцедуры

Процедура РТУ_ИзменениеДоговора_ДатаЗапрета() Экспорт
	
	Макет = ПолучитьМакет("РТУ_ИзменениеДоговора");
	
	//Киа Север 02.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область1"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументРТУ1 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументРТУ1, "Документ РТУ не создан");
	
	Договор = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументРТУ1, "ДоговорКонтрагента");
	Утверждения.ПроверитьРавенство(Строка(Договор), "TEST-00001",  "Не верный договор");
	
	// Закрываем период
	УстановитьДатуЗапрета('2018-02-28');
	
	
	//Инфинити Химки  02.03
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Область2"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументСторно = ОбработкаОбъект.НайтиДокументСторно(ДокументРТУ1);
	Утверждения.ПроверитьЗаполненность(ДокументСторно, "Документ сторно не создан");
	
	ДокументРТУ2 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	Утверждения.ПроверитьНеРавенство(ДокументРТУ1, ДокументРТУ2, "Новый документ РТУ не создан");
	
	Договор = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументРТУ2, "ДоговорКонтрагента");
	Утверждения.ПроверитьРавенство(Строка(Договор), "TEST-00002",  "Не верный договор");
	
КонецПроцедуры

Процедура РТУ_ОтвязкаПлатежа() Экспорт
	
	Макет = ПолучитьМакет("Реализация_ОтвязкаПлатежа");
	
	//РТУ 02.01
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Реализация1"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументРТУ1 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументРТУ1, "Документ РТУ не создан");
	
	//// Закрываем период
	//УстановитьДатуЗапрета('2018-01-31');
	//
	
	//Отвязка платежа 02.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Отвязка"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	СуммаДокумента = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументРТУ1, "СуммаДокумента");
	Утверждения.ПроверитьРавенство(СуммаДокумента, 0, "Сумма документа не равно 0");
	
	//новый договор 10.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Реализация2"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДокументРТУ1, "ДоговорКонтрагента, СуммаДокумента");
	Утверждения.ПроверитьРавенство(Строка(Реквизиты.ДоговорКонтрагента), "TEST-00002", "Не верный договор");
	Утверждения.ПроверитьРавенство(Реквизиты.СуммаДокумента, 11200.96, "Не верная сумма");
	
КонецПроцедуры

Процедура РТУ_ОтвязкаПлатежа_ДатаЗапрета() Экспорт
	
	Макет = ПолучитьМакет("Реализация_ОтвязкаПлатежа");
	
	//РТУ 02.01
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Реализация1"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументРТУ1 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	
	Утверждения.ПроверитьЗаполненность(ДокументРТУ1, "Документ РТУ не создан");
	
	// Закрываем период
	УстановитьДатуЗапрета('2018-01-31');
	
	
	//Отвязка платежа 02.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Отвязка"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументСторно = ОбработкаОбъект.НайтиДокументСторно(ДокументРТУ1);
	Утверждения.ПроверитьЗаполненность(ДокументСторно, "Документ сторно не создан");
	
	
	//новый договор 10.02
	ТаблицаДанных = ОбработкаОбъект.ПолучитьТаблицуДанныхРеализацииТест(Макет.ПолучитьОбласть("Реализация2"));
	
	АдресРезультата = Неопределено;
	ОбработкаОбъект.ЗагрузитьРеализации(Параметры, АдресРезультата, ТаблицаДанных);

	ДокументРТУ2 = АСЦ_ПоискОбъектов.НайтиДокументПоСвойству(999999999999, СвойствоID, "РеализацияТоваровУслуг");
	Утверждения.ПроверитьНеРавенство(ДокументРТУ1, ДокументРТУ2, "Новый документ РТУ не создан");
	
	Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДокументРТУ2, "ДоговорКонтрагента, СуммаДокумента");
	Утверждения.ПроверитьРавенство(Строка(Реквизиты.ДоговорКонтрагента), "TEST-00002", "Не верный договор");
	Утверждения.ПроверитьРавенство(Реквизиты.СуммаДокумента, 11200.96, "Не верная сумма");
	
КонецПроцедуры

