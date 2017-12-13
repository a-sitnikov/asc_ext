﻿
// Данная процедура вызываются из обработчика "Процедура заполнения" 
// правила обработки отчета
//
Процедура ЗаполнитьОтчет(ДокОбъект) Экспорт
	
	//Изначально таблица в виде
	// Строка шапка
	// строка ТЧ 1
	// строка ТЧ 2
	// Преобразуем таблицу в нормальный вид: реквизиты шапки - отдельные колонки
	
	//Аналитика: Контрагент, Договор, Страховая
	
	ТекстЗапроса =
	"SELECT 
	|    head.act_id,    
	|    head.НомерДок,    
	|    head.ДатаДок,    
	|    head.СК,  
	|    head.СК_Договор,  
	|    tab.SK_INN as СК_ИНН,
	|    tab.SK_KPP as СК_КПП,
	|    TO_NUMBER(tab.COL2) as НомерСтроки,
	|    tab.COL3 as Контрагент,
	|    tab.COL10 as КонтрагентИНН,
	|    tab.COL11 as КонтрагентКПП,
	|    tab.COL4 as Серия,
	|    tab.COL5 as Номер,
	|    TO_NUMBER(tab.COL6, '999999999999.99') as СтраховаяПремия,
	|    tab.COL7 as КВ_руб,
	|    tab.COL8 as КВ,
	|    tab.COL9 as СуммаКПеречислению
	|FROM
	|	(SELECT 
	|   	ACT_ID, 
	|	    COL2 as НомерДок, 
	|   	TO_DATE(COL3, 'DD.MM.YYYY') as  ДатаДок,
	|	    COL4 as СК,
	|	    COL6 as СК_Договор
	|	FROM v_asc_act
	|	WHERE
	|		COL1 is NOT NULL
	|		AND TO_DATE(COL3, 'DD.MM.YYYY') BETWEEN &ДатаНач AND &ДатаКон) head
	|	LEFT JOIN v_asc_act tab 
	|		ON tab.act_id = head.act_id
	|WHERE
	|	tab.COL1 IS NULL
	|	AND tab.AGENT_INN = &ИНН";
	
	//Доп отбор для тестирования
	// например AND rownum <= 10  - выбираем только первые 10 записей
	Если ДокОбъект.ДополнительныеСвойства.Свойство("Тест_КоличествоСтрок")
		И ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок <> 0 Тогда
		ТекстЗапроса = ТекстЗапроса + " AND rownum <= " + Формат(ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок, "ЧГ=0");
		ЗаписьЖурналаРегистрации("Заполнение отчета UNICUS_Acts",
			УровеньЖурналаРегистрации.Предупреждение, Метаданные.Документы.НастраиваемыйОтчет, ДокОбъект.Ссылка, "Кол-во строк: " + ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок);
	КонецЕсли;	
	
	ТекстЗапроса = ТекстЗапроса + "
	|ORDER BY 
	|	ДатаДок, act_id, НомерСтроки";
	                                                     
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДокОбъект.ПериодОтчета.ДатаНачала, "Oracle"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаКон", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(КонецДня(ДокОбъект.ПериодОтчета.ДатаОкончания), "Oracle"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИНН",     "'" + ДокОбъект.Организация.ИНН + "'");
	
	СтруктураЗапроса      = ПолучитьСтруктуруЗапроса(ДокОбъект);
	ТипыКолонокРезультата = ПолучитьТипыКолонокРезультата();
	ДополнительныеСвойстваИмпорта = Неопределено;
	
	ТаблицаДанных = ИнтеграцияСВнешнимиСистемамиУХ.АСЦ_ADO_ПолучитьДанныеИзЗапроса(ТекстЗапроса, СтруктураЗапроса, ТипыКолонокРезультата, ДополнительныеСвойстваИмпорта);
	Результат = ЗаполнитьАналитику(ТаблицаДанных, ДокОбъект.Организация);
	
	Колонки = Новый Массив;
	Колонки.Добавить("СтраховаяПремия");
	Колонки.Добавить("КВ_руб");
	Колонки.Добавить("СуммаКПеречислению");
	Колонки.Добавить("ДатаДок");
	
	Для каждого СтрокаТЗ из Результат Цикл
		
		Для каждого Колонка из Колонки Цикл
			
			Значение = СтрокаТЗ[Колонка];
			Код = "Данные_" + Колонка;
			
			ДокОбъект.УстановитьЗначениеПоказателя(Код, Значение, 
										СтрокаТЗ.Аналитика1, СтрокаТЗ.Аналитика2, СтрокаТЗ.Аналитика3, СтрокаТЗ.Аналитика4);
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры	


Функция ЗаполнитьАналитику(Таблица, Организация)
	
	Результат = Таблица.Скопировать();
	
	Результат.Колонки.Добавить("Аналитика1");
	Результат.Колонки.Добавить("Аналитика2");
	Результат.Колонки.Добавить("Аналитика3");
	Результат.Колонки.Добавить("Аналитика4");
	
	МассивОшибок = Новый Массив;
	СубконтоАкт = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.НайтиПоНаименованию("UNICUS Акты");
	
	СКДоговор = Неопределено;
	Для каждого СтрокаТЗ из Результат Цикл
		
		ТекстОшибки = "";
		СтрокаТЗ.Аналитика1 = ПолучитьКонтрагента(СтрокаТЗ.Контрагент, СтрокаТЗ.КонтрагентИНН, СтрокаТЗ.КонтрагентКПП, ТекстОшибки);
		Если ЗначениеЗаполнено(ТекстОшибки)
			И МассивОшибок.Найти(ТекстОшибки) = Неопределено Тогда
			МассивОшибок.Добавить(ТекстОшибки);
		КонецЕсли;	
		
		СтрокаТЗ.Аналитика2 = ПолучитьДоговор(СтрокаТЗ.Аналитика1, Организация, СтрокаТЗ.Серия + СтрокаТЗ.Номер);
		
		ТекстОшибки = "";
		СтрокаТЗ.Аналитика3 = ПолучитьКонтрагента(СтрокаТЗ.СК, СтрокаТЗ.СК_ИНН, СтрокаТЗ.СК_КПП, ТекстОшибки);
		Если ЗначениеЗаполнено(ТекстОшибки)
			И МассивОшибок.Найти(ТекстОшибки) = Неопределено Тогда
			МассивОшибок.Добавить(ТекстОшибки);
		КонецЕсли;	
		
		Если ЗначениеЗаполнено(СтрокаТЗ.Аналитика3) Тогда
			
			Если НЕ ЗначениеЗаполнено(СКДоговор) Тогда
				СКДоговор = ПолучитьДоговор(СтрокаТЗ.Аналитика3, Организация, СтрокаТЗ.НомерДок, Перечисления.ВидыДоговоровКонтрагентовУХ.СКомитентом);
			КонецЕсли;
			
			СтрокаТЗ.Аналитика4 = СКДоговор;
			
		КонецЕсли;
		
	КонецЦикла;	
	
	Для каждого ТекстОшибки из МассивОшибок Цикл
		Сообщить(ТекстОшибки);
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции	

Функция ПолучитьКонтрагента(Наименование, ИНН, КПП, ТекстОшибки)
	
	СпрСсылка = АСЦ_ОбщийМодуль.НайтиКонтрагента(Наименование, ИНН, КПП, ТекстОшибки);
	Возврат СпрСсылка;
	
КонецФункции

Функция ПолучитьДоговор(Контрагент, Организация, Наименование, ВидДоговораУХ = Неопределено)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	Запрос.Параметры.Вставить("Контрагент",   Контрагент);
	Запрос.Параметры.Вставить("Организация",  Организация);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Наименование = &Наименование
	|	И Спр.Владелец = &Контрагент
	|	И Спр.Организация = &Организация";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		
		Если ВидДоговораУХ = Неопределено Тогда
			ВидДоговораУХ = Перечисления.ВидыДоговоровКонтрагентовУХ.СПокупателем;
		КонецЕсли;	
		
		СпрОбъект = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
		СпрОбъект.Владелец      = Контрагент;
		СпрОбъект.Организация   = Организация;
		СпрОбъект.Наименование  = Наименование;
		СпрОбъект.Номер         = СпрОбъект.Наименование;
		СпрОбъект.ВалютаВзаиморасчетов = Константы.ВалютаРегламентированногоУчета.Получить();
		СпрОбъект.ВидДоговораУХ = ВидДоговораУХ;
		СпрОбъект.ВидДоговора   = УправлениеДоговорамиУХКлиентСерверПовтИсп.ВидДоговораБП(СпрОбъект.ВидДоговораУХ);
		СпрОбъект.ВидСоглашения = Перечисления.ВидыСоглашений.ДоговорСУсловием;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьАкт(Субконто, ИД, Номер, Комментарий)
	
	Код = Формат(ИД, "ЧГ=0");
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Субконто", Субконто);
	Запрос.Параметры.Вставить("Код",      Код);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ПроизвольныйКлассификаторУХ КАК Спр
	|ГДЕ
	|	Спр.Владелец = &Субконто
	|	И Спр.КодДляСинхронизации = &Код";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		
		СпрОбъект = Справочники.ПроизвольныйКлассификаторУХ.СоздатьЭлемент();
		СпрОбъект.Владелец      = Субконто;
		СпрОбъект.Наименование  = Номер;
		СпрОбъект.Комментарий   = Комментарий;
		СпрОбъект.КодДляСинхронизации = Код;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;
	
КонецФункции	


Функция ПолучитьСтруктуруЗапроса(ДокОбъект) Экспорт
	
	СтрЗапрос = Новый Структура;
	СтрЗапрос.Вставить("СпособПолучения",  Перечисления.СпособыПолученияОперандов.ВнешниеДанныеADO);
	СтрЗапрос.Вставить("СтруктураЗапроса", Новый Структура);
	СтрЗапрос.Вставить("ТекстЗапроса",     "");
	СтрЗапрос.Вставить("ПравилаВычисленияПараметров", Новый ТаблицаЗначений);
	СтрЗапрос.Вставить("ПланСчетов",       Неопределено);
	
	СтруктураЗапроса = ИнтеграцияСВнешнимиСистемамиУХ.ПодготовитьСтруктуруЗапроса(ДокОбъект, СтрЗапрос);
	
	СтруктураРесурсов = Новый Структура;
	СтруктураЗапроса.Вставить("СтруктураРесурсов", СтруктураРесурсов);
	
	Возврат СтруктураЗапроса;
	
КонецФункции	

Функция ПолучитьТипыКолонокРезультата() Экспорт
	
	ТипыКолонокРезультата = Новый Соответствие;
	ТипыКолонокРезультата.Вставить("ДАТАДОК", Тип("Дата"));
	
	Возврат ТипыКолонокРезультата;
	
КонецФункции	
	
