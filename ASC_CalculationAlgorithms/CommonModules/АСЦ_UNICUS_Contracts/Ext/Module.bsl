﻿
// Данная процедура вызываются из обработчика "Процедура заполнения" 
// правила обработки отчета
//
Процедура ЗаполнитьОтчет(ДокОбъект) Экспорт
	
	ДокОбъект.ОчиститьВсе();
	
	// Итоги пересчитаем после загрузки
	ДокОбъект.НеПересчитыватьИтоги = Истина;
	
	// Аналитика
	// Номенклатура, Контрагент, Договор, Страховая
	
	ТекстЗапроса =
	"SELECT
	|	tab.FULL_PREMIUM as FULL_PREMIUM,
	|	tab.PREMIUM_SUM as PREMIUM_SUM,
	|	tab.KV_RUB as KV_RUB,
	|	tab.PAY_DATE as PAY_DATE,
	|	CASE WHEN tab.INSUR_TYPE = 'пролонгация' 
	|		THEN 1
	|		ELSE 0
	|	END as Пролонгация,
	|	tab.TS_NEW as TS_NEW,
	|	tab.STORONNIY_CLIENT as STORONNIY_CLIENT,
	// Номенклатура
	|	tab.PRODUCT_NAME as PRODUCT_NAME,
	// Контрагент
	|	tab.SUBJECT_NAME as SUBJECT_NAME,
	|	'ФизическоеЛицо' as ЮрФизЛицо,
	// Договор
	|	tab.POLICY_NUMBER as POLICY_NUMBER,
	|	tab.DATE_SIGN as DATE_SIGN,
	|	tab.ACTION_BEGIN_DATE as ACTION_BEGIN_DATE,
	|	tab.ACTION_END_DATE as ACTION_END_DATE,
	|	'СПокупателем' as ВидДоговора,
	|	'643' as ВалютаКод,
	// Страховая
	|	tab.SK_NAME as SK_NAME,
	|	'ЮридическоеЛицо' as СК_ЮрФизЛицо
	|FROM 
	|	V_ASC_CONTRACT tab
	|WHERE
	|	tab.DATE_SIGN >= &ДатаНач
	|	AND tab.DATE_SIGN <= &ДатаКон
	|	AND tab.AGENT IS NOT NULL 
	|	AND tab.AGENT IN (&Организация1, &Организация2)";
	
	//Доп отбор для тестирования
	// например AND rownum <= 10  - выбираем только первые 10 записей
	Если ДокОбъект.ДополнительныеСвойства.Свойство("Тест_КоличествоСтрок")
		И ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок <> 0 Тогда
		ТекстЗапроса = ТекстЗапроса + " AND rownum <= " + Формат(ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок, "ЧГ=0");
		ЗаписьЖурналаРегистрации("Заполнение отчета UNICUS_Contracts",
			УровеньЖурналаРегистрации.Предупреждение, Метаданные.Документы.НастраиваемыйОтчет, ДокОбъект.Ссылка, "Кол-во строк: " + ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок);
	КонецЕсли;	
	
	ТекстЗапроса = ТекстЗапроса + "
	|ORDER BY
	|	DATE_SIGN, SUBJECT_NAME";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДокОбъект.ПериодОтчета.ДатаНачала, "Oracle"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаКон", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(КонецДня(ДокОбъект.ПериодОтчета.ДатаОкончания), "Oracle"));
	
	Свойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "НаименованиеUNICUS");
	Организация1 = УправлениеСвойствами.ЗначениеСвойства(ДокОбъект.Организация, Свойство);
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Организация1", "'" + Организация1 + "'");
	
	Организация2 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокОбъект.Организация, "Наименование");
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Организация2", "'" + Организация2 + "'");
	
	СтруктураЗапроса      = ПолучитьСтруктуруЗапроса(ДокОбъект);
	ТипыКолонокРезультата = ПолучитьТипыКолонокРезультата();
	ДополнительныеСвойстваИмпорта = Неопределено;
	
	ТаблицаДанных = ИнтеграцияСВнешнимиСистемамиУХ.АСЦ_ADO_ПолучитьДанныеИзЗапроса(ТекстЗапроса, СтруктураЗапроса, ТипыКолонокРезультата, ДополнительныеСвойстваИмпорта);
	
	// Можно заполнять через внутренний механизм трансформации данных,
	// но в нем нельзя делать вариативность поиска
	//ПравилаИспользованияПолей = ПолучитьПравилаИспользованияПолей(ДокОбъект.ИспользуемаяИБ.ТипБД);
	//Результат = ИнтеграцияСВнешнимиСистемамиУХ.ТрансформироватьВнешниеДанные(ДокОбъект, ТаблицаДанных, ПравилаИспользованияПолей);
	Результат = ЗаполнитьАналитику(ТаблицаДанных, ДокОбъект.Организация);
	
	Колонки = Новый Массив;
	Колонки.Добавить("FULL_PREMIUM");
	Колонки.Добавить("PREMIUM_SUM");
	Колонки.Добавить("KV_RUB");
	//Колонки.Добавить("PAY_DATE");
	//Колонки.Добавить("Пролонгация");
	//Колонки.Добавить("TS_NEW");
	
	СоответствиеСтрок = Новый Соответствие;
	СоответствиеСтрок.Вставить("КАСКО", "КАСКО");
	СоответствиеСтрок.Вставить("ОСАГО", "ОСАГО");
	СоответствиеСтрок.Вставить(ВРег("Гражданская ответственность"), "ГрОтв");
	СоответствиеСтрок.Вставить(ВРег("Страхование жизни"),  "СтрахованиеЖизни");
	СоответствиеСтрок.Вставить(ВРег("Защита автокредита"), "СтрахованиеЖизни");
	СоответствиеСтрок.Вставить(ВРег("GAP страхование"),    "GAP");
	
	Для каждого СтрокаТЗ из Результат Цикл
		
		Строка = СоответствиеСтрок[ВРег(СтрокаТЗ.PRODUCT_NAME)];
		Если Строка = Неопределено Тогда
			Строка = "Прочие";
		КонецЕсли;	
			
		Если СтрокаТЗ.Пролонгация = 1 Тогда
			Строка = Строка + "_Пролонгация_";
			
		ИначеЕсли СтрокаТЗ.TS_NEW = 0 Тогда	
			Строка = Строка + "_БУ_";
			
		Иначе
			Строка = Строка + "_Розница_";
		КонецЕсли;	
				
		Для каждого Колонка из Колонки Цикл
			Результат = ДокОбъект.УстановитьЗначениеПоказателя(Строка + Колонка, СтрокаТЗ[Колонка], 
										СтрокаТЗ.Аналитика1, СтрокаТЗ.Аналитика2, СтрокаТЗ.Аналитика3, Неопределено);
		КонецЦикла;	
		
		Результат = ДокОбъект.УстановитьЗначениеПоказателя(Строка + "Колво", 1, 
									СтрокаТЗ.Аналитика1, СтрокаТЗ.Аналитика2, СтрокаТЗ.Аналитика3, Неопределено);
	КонецЦикла;	
	
	ДокОбъект.НеПересчитыватьИтоги = Ложь;
	ДокОбъект.УстановитьИтогиПоПоказателям();
	
КонецПроцедуры	


Функция ЗаполнитьАналитику(Таблица, Организация)
	
	Результат = Таблица.Скопировать();
	
	Результат.Колонки.Добавить("Аналитика1");
	Результат.Колонки.Добавить("Аналитика2");
	Результат.Колонки.Добавить("Аналитика3");
	
	Родитель = Справочники.Контрагенты.НайтиПоНаименованию("1 Физические лица");
	
	Для каждого СтрокаТЗ из Результат Цикл
		
		СтрокаТЗ.Аналитика1 = ПолучитьКонтрагента(СтрокаТЗ.SUBJECT_NAME, Родитель);
		СтрокаТЗ.Аналитика2 = ПолучитьДоговор(СтрокаТЗ.Аналитика1, Организация, СтрокаТЗ);
		СтрокаТЗ.Аналитика3 = ПолучитьНоменклатуру(СтрокаТЗ.PRODUCT_NAME);
		
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции	

Функция ПолучитьНоменклатуру(Наименование)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Спр
	|ГДЕ
	|	НЕ Спр.ЭтоГруппа
	|	И НЕ Спр.ПометкаУдаления
	|	И Спр.Наименование = &Наименование";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		
		СпрОбъект = Справочники.Номенклатура.СоздатьЭлемент();
		СпрОбъект.Наименование =  Наименование;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьКонтрагента(Наименование, Родитель)
	
	СпрСсылка = АСЦ_ОбщийМодуль.НайтиКонтрагента(Наименование, "", "");
	Если ЗначениеЗаполнено(СпрСсылка) Тогда
		
		Возврат СпрСсылка;
		
	Иначе	
		
		СпрОбъект = Справочники.Контрагенты.СоздатьЭлемент();
		СпрОбъект.Родитель     = Родитель;
		СпрОбъект.Наименование = Наименование;
		СпрОбъект.ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо;
		СпрОбъект.СтранаРегистрации         = Справочники.СтраныМира.Россия;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьДоговор(Контрагент, Организация, Параметры)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Параметры.POLICY_NUMBER);
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
		
		СпрОбъект = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
		СпрОбъект.Владелец      = Контрагент;
		СпрОбъект.Организация   = Организация;
		СпрОбъект.Наименование  = Параметры.POLICY_NUMBER;
		СпрОбъект.Номер         = СпрОбъект.Наименование;
		СпрОбъект.ВалютаВзаиморасчетов = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
		СпрОбъект.ВидДоговора   = Перечисления.ВидыДоговоровКонтрагентов.СПокупателем;
		СпрОбъект.ВидДоговораУХ = Перечисления.ВидыДоговоровКонтрагентов.СПокупателем;
		СпрОбъект.ВидСоглашения = Перечисления.ВидыСоглашений.ДоговорСУсловием;
		СпрОбъект.Дата          = Параметры.DATE_SIGN;
		СпрОбъект.ДатаНачала    = Параметры.ACTION_BEGIN_DATE;
		СпрОбъект.СрокДействия  = Параметры.ACTION_END_DATE;
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
	ТипыКолонокРезультата.Вставить("FULL_PREMIUM",      Тип("Число"));
	ТипыКолонокРезультата.Вставить("PREMIUM_SUM",       Тип("Число"));
	ТипыКолонокРезультата.Вставить("KV_RUB",            Тип("Число"));
	ТипыКолонокРезультата.Вставить("PAY_DATE",          Тип("Дата"));
	
	ТипыКолонокРезультата.Вставить("PRODUCT_NAME",      Тип("Строка"));
	
	ТипыКолонокРезультата.Вставить("SUBJECT_NAME",      Тип("Строка"));
	
	ТипыКолонокРезультата.Вставить("POLICY_NUMBER",     Тип("Строка"));
	ТипыКолонокРезультата.Вставить("DATE_SIGN",         Тип("Дата"));
	ТипыКолонокРезультата.Вставить("ACTION_BEGIN_DATE", Тип("Дата"));
	ТипыКолонокРезультата.Вставить("ACTION_END_DATE",   Тип("Дата"));
	
	Возврат ТипыКолонокРезультата;
	
КонецФункции	
	
Функция ПолучитьПравилаИспользованияПолей(ТипБД) Экспорт
	
	ПравилаИспользованияПолей = Новый ТаблицаЗначений;
	ПравилаИспользованияПолей.Колонки.Добавить("АналитикаОперанда");
	ПравилаИспользованияПолей.Колонки.Добавить("ИндексАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("КодАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("СоздаватьНовые");
	ПравилаИспользованияПолей.Колонки.Добавить("ТаблицаАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("РеквизитАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("НеИспользоватьДляСинхронизации", Новый ОписаниеТипов("Булево"));
	ПравилаИспользованияПолей.Колонки.Добавить("РазделятьПоОрганизациям",        Новый ОписаниеТипов("Булево"));
	ПравилаИспользованияПолей.Колонки.Добавить("УровеньВложенности");
	ПравилаИспользованияПолей.Колонки.Добавить("Синоним");
	ПравилаИспользованияПолей.Колонки.Добавить("НастройкаСоответствия");
	ПравилаИспользованияПолей.Колонки.Добавить("Поле");
	ПравилаИспользованияПолей.Колонки.Добавить("ТаблицаАналитикиВИБ");
	ПравилаИспользованияПолей.Колонки.Добавить("НастройкаСоответствияРеквизит");
	ПравилаИспользованияПолей.Колонки.Добавить("ИспользованиеКонсолидация");
	ПравилаИспользованияПолей.Колонки.Добавить("СпособЗаполнения");
	ПравилаИспользованияПолей.Колонки.Добавить("ФиксированноеЗначение");
	ПравилаИспользованияПолей.Колонки.Добавить("ОбновлятьРеквизитыПриИмпорте", Новый ОписаниеТипов("Булево"));
	
	НастройкаСоответствия = ПолучитьНастройкуСоотвествия(ТипБД);
	
	// Аналитика 1: Контрагенты
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникКонтрагенты;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 1;
	НоваяСтрока.КодАналитики       = "Аналитика1";
	НоваяСтрока.СоздаватьНовые     = Ложь;
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Контрагенты";
	НоваяСтрока.РеквизитАналитики  = "Наименование";
	НоваяСтрока.Синоним            = "SUBJECT_NAME";
	НоваяСтрока.УровеньВложенности = 1;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 1;
	НоваяСтрока.КодАналитики       = "Аналитика1vzvЮридическоеФизическоеЛицо";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ЮридическоеФизическоеЛицо";
	НоваяСтрока.Синоним            = "ЮрФизЛицо";
	НоваяСтрока.РеквизитАналитики  = "ЮридическоеФизическоеЛицо.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 1;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 1;
	НоваяСтрока.КодАналитики       = "Аналитика1vzvСтранаРегистрации";
	НоваяСтрока.ТаблицаАналитики   = "Справочник.СтраныМира";
	НоваяСтрока.Синоним            = "ВалютаКод";
	НоваяСтрока.РеквизитАналитики  = "СтранаРегистрации.Код";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 1;
	
	// Аналитика 2: Договоры
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникДоговораКонтрагентов;
	
	СоотвествиеПолей = Новый Соответствие;
	СоотвествиеПолей.Вставить("Наименование", "POLICY_NUMBER");
	СоотвествиеПолей.Вставить("Номер",        "POLICY_NUMBER");
	СоотвествиеПолей.Вставить("Дата",         "DATE_SIGN");
	СоотвествиеПолей.Вставить("ДатаНачала",   "ACTION_BEGIN_DATE");
	СоотвествиеПолей.Вставить("СрокДействия", "ACTION_END_DATE");
	
	Для каждого КлючИЗначение из СоотвествиеПолей Цикл
		
		НоваяСтрока = ПравилаИспользованияПолей.Добавить();
		НоваяСтрока.АналитикаОперанда  = Субконто;
		НоваяСтрока.ИндексАналитики    = 2;
		НоваяСтрока.КодАналитики       = "Аналитика2";
		НоваяСтрока.СоздаватьНовые     = Ложь;
		НоваяСтрока.ТаблицаАналитики   = "Справочник.ДоговорыКонтрагентов";
		НоваяСтрока.РеквизитАналитики  = КлючИЗначение.Ключ;
		НоваяСтрока.Синоним            = КлючИЗначение.Значение;
		НоваяСтрока.УровеньВложенности = 1;
		НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
		
		Если КлючИЗначение.Ключ = "Наименование" Тогда
			НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
		Иначе	
			НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
		КонецЕсли	
		
	КонецЦикла;	
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2vzvВидДоговора";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ВидыДоговоровКонтрагентов";
	НоваяСтрока.Синоним            = "ВидДоговора";
	НоваяСтрока.РеквизитАналитики  = "ВидДоговора.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2vzvВидДоговораУХ";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ВидыДоговоровКонтрагентовУХ";
	НоваяСтрока.Синоним            = "ВидДоговора";
	НоваяСтрока.РеквизитАналитики  = "ВидДоговораУХ.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2vzvВалютаВзаиморасчетов";
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Валюты";
	НоваяСтрока.Синоним            = "ВалютаКод";
	НоваяСтрока.РеквизитАналитики  = "ВалютаВзаиморасчетов.Код";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2vzvВладелец";
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Контрагенты";
	НоваяСтрока.Синоним            = "SUBJECT_NAME";
	НоваяСтрока.РеквизитАналитики  = "Владелец.Наименование";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	// Аналитика 3: Номенклатура
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникНоменклатура;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 3;
	НоваяСтрока.КодАналитики       = "Аналитика3";
	НоваяСтрока.СоздаватьНовые     = Ложь;
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Номенклатура";
	НоваяСтрока.РеквизитАналитики  = "Наименование";
	НоваяСтрока.Синоним            = "PRODUCT_NAME";
	НоваяСтрока.УровеньВложенности = 3;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	
	Возврат ПравилаИспользованияПолей;
	
КонецФункции

Функция ПолучитьНастройкуСоотвествия(ТипБД) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ТипБД",    ТипБД);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.СоответствиеВнешнимИБ КАК Спр
	|ГДЕ
	|	Спр.ОписаниеОбъектаВИБ.Владелец = &ТипБД";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Справочники.СоответствиеВнешнимИБ.ПустаяСсылка();
	Иначе	
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;
	
КонецФункции

