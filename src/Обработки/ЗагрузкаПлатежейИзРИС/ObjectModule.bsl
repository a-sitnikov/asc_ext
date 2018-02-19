﻿#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	
	// Запуск через фоновое не работает в режиме разрешений
	// Каталог не обнаружен 'e1cib\tempstorage\dee284a6-d234-4482-b97c-3ab694a1d1dd'
	//ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.2.2.1");
	//
	//Разрешение = РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса("http://hlsapp3.ascgroup.local");
	//ПараметрыРегистрации.Разрешения.Добавить(Разрешение);
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Истина;
	ПараметрыРегистрации.Информация = "Загрузка платежей из РИС";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление() + " - Открыть форму";
	НоваяКоманда.Идентификатор = Метаданные().Имя + "Форма";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = "Загрузить платежи из РИС";
	НоваяКоманда.Идентификатор = "ЗагрузитПлатежи";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	НоваяКоманда.ПоказыватьОповещение = Ложь;

	Возврат ПараметрыРегистрации;

КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды = Неопределено) Экспорт 
	
	Параметры = Новый Структура;
	
	Параметры.Вставить("ДатаКон",     ТекущаяДата());
	Параметры.Вставить("ДатаНач",     НачалоДня(ТекущаяДата() - 86400));
	Параметры.Вставить("Организация", Неопределено);
	Параметры.Вставить("ПерезаполнятьДокументы",   Ложь);
	Параметры.Вставить("ПерезаполнятьДоговоры",    Ложь);
	Параметры.Вставить("ВыводитьСообщения",        Ложь);
	Параметры.Вставить("ЗагружатьДокументыОплаты", Истина);
	//ЗаписьЖурналаРегистрации("Загрузка отчета UNICUS",
	//	УровеньЖурналаРегистрации.Предупреждение,,, "Параметры: " + вСтроку(ПараметрыКоманды));
	
	Если ИдентификаторКоманды = "ЗагрузитПлатежи" Тогда
		ПолучитьДокументы(Параметры);
		
	КонецЕсли;	
	
КонецПроцедуры	

#КонецОбласти

Процедура ПолучитьДокументы(Параметры, АдресРезультата = Неопределено) Экспорт
	
	База        = Параметры.База;
	ДатаНач     = Параметры.ДатаНач;
	ДатаКон     = Параметры.ДатаКон;
	Организация = Параметры.Организация;
	
	WSПрокси = УправлениеСоединениямиВИБУХ.ПолучитьСоединение(База, "");
	Если WSПрокси = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	ПакетXDTO = WSПрокси.ФабрикаXDTO.Пакеты.Получить(СокрЛП(База.URIПространстваИмен));               
	
	ИмяБазы = "АСЦ";
	ПолученныеВыписки = Неопределено;
	ТаблицаДокументов = Неопределено;
	ТекстОшибки = "";
	
	Ответ = WSПрокси.InvoiceGet(" ",
		ИмяБазы,
		ДатаНач,
		ДатаКон,
		Истина,
		Неопределено,
		Неопределено,
		ТаблицаДокументов,
		ТекстОшибки,
		ПолученныеВыписки);
		
	ТаблицаДанных = СозданныеДокументы.ВыгрузитьКолонки();
	
	Если ТаблицаДокументов = Неопределено Тогда
		ПоместитьВоВременноеХранилище(ТаблицаДанных, АдресРезультата);
		Возврат;
	КонецЕсли;		
		
	Тест_КоличествоСтрок = 0;
	Параметры.Свойство("Тест_КоличествоСтрок", Тест_КоличествоСтрок);

	Тест_КодСтатьиДДС = "";
	Параметры.Свойство("Тест_КодСтатьиДДС", Тест_КодСтатьиДДС);
	
	Тест_ВидДокумента = "";
	Параметры.Свойство("Тест_ВидДокумента", Тест_ВидДокумента);
	
	Счетчик = 0;
	СчетчикДокументов = 0;
	Всего = ТаблицаДокументов.Платеж.Количество();
	
	КэшДанных = Новый Структура;
	КэшДанных.Вставить("Организация", Новый Соответствие);
	
	Для каждого СтрПлатеж Из ТаблицаДокументов.Платеж Цикл
		
		// Платежи без договора не относятся к ОФУ
		Если НЕ ЗначениеЗаполнено(СтрПлатеж.Договор) Тогда
			Продолжить;
		КонецЕсли;	
		
		СтруктураСсылок = Новый Структура;
		СтруктураСсылок.Вставить("Организация", АСЦ_ПоискОбъектов.ПолучитьОрганизациюПоИНН(СтрПлатеж.ИННОрганизации, СтрПлатеж.КППОрганизации, КэшДанных.Организация));
		Если ЗначениеЗаполнено(Организация) Тогда
			Если Организация <> СтруктураСсылок.Организация Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Тест_КодСтатьиДДС) Тогда
			Если Тест_КодСтатьиДДС <> СтрПлатеж.КодСтатьиДДС Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Тест_ВидДокумента) Тогда
			
			Если СтрПлатеж.ВидПлатежногоДокумента = "ПКО" 
				И СтрПлатеж.СпособПлатежа <> "Банковская карта" Тогда
				
				Если Тест_ВидДокумента <> "ПКО" Тогда
					Продолжить;
				КонецЕсли;	
				
			ИначеЕсли СтрПлатеж.ВидПлатежногоДокумента = "ППВ" Тогда 
				
				Если Тест_ВидДокумента <> "Поступление ДС" Тогда
					Продолжить;
				КонецЕсли;	
				
			ИначеЕсли СтрПлатеж.ВидПлатежногоДокумента = "ПКО" 
				И СтрПлатеж.СпособПлатежа = "Банковская карта" Тогда
				
				Если Тест_ВидДокумента <> "Оплата картой" Тогда
					Продолжить;
				КонецЕсли;	
				
			КонецЕсли;
			
		КонецЕсли;	
		
		СтрокаТЧ = ТаблицаДанных.Добавить();
		
		ИД = ПолучитьГУИД(СтрПлатеж.ИДДокумента);
		Если ЗначениеЗаполнено(ИД) Тогда
			ДокументСсылка = Документы.АСЦ_Платеж.ПолучитьСсылку(ИД);
		Иначе	
			ДокументСсылка = Неопределено;
		КонецЕсли;	
		
		СтрокаТЧ.Платеж = ЗаполнитьДокументПлатеж(ДокументСсылка, СтрПлатеж, WSПрокси, СтруктураСсылок, Параметры);
		
		Счетчик = Счетчик + 1;
		ПроцентВыполнения = Окр(100 * Счетчик / Всего, 2);
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, "Загружено " + Счетчик + " из " + Всего);
		
		СчетчикДокументов = СчетчикДокументов + 1;
		Если ЗначениеЗаполнено(Тест_КоличествоСтрок)
			И СчетчикДокументов >= Тест_КоличествоСтрок Тогда
			Прервать;
		КонецЕсли;	
		
	КонецЦикла; 
	
	ПоместитьВоВременноеХранилище(ТаблицаДанных, АдресРезультата);
	
КонецПроцедуры

Функция ПолучитьГУИД(Парам)
	
	Если НЕ ЗначениеЗаполнено(Парам) Тогда
		Возврат Неопределено;
	КонецЕсли;	
	
	// "{"#",54b442b6-253a-4c8b-b790-6236a2ab5425,176:a1250cc47a57b16f11e70a0b2b2a6af1}"
	Парам = СтрЗаменить(Парам,"#","");
	Парам = СтрЗаменить(Парам,"{","");
	Парам = СтрЗаменить(Парам,"}","");
	Парам = СтрЗаменить(Парам,",","");
	Парам = СтрЗаменить(Парам,"""","");
		
	Возврат Новый УникальныйИдентификатор(Парам);
	
КонецФункции	

Функция ПолучитьБанковскийСчет(Данные, Организация)
	
	Если Данные = Неопределено Тогда
		Возврат Справочники.БанковскиеСчета.ПустаяСсылка();
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Организация", Организация);
	Запрос.Параметры.Вставить("НомерСчета",  Данные.НомерСчета);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.БанковскиеСчета КАК Спр
	|ГДЕ
	|	Спр.НомерСчета = &НомерСчета
	|	И Спр.Владелец = &Организация
	|	И НЕ Спр.ПометкаУдаления";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		
		СпрОбъект = Справочники.БанковскиеСчета.СоздатьЭлемент();
		СпрОбъект.Владелец   = Организация;
		СпрОбъект.НомерСчета = Данные.НомерСчета;
		СпрОбъект.Банк       = АСЦ_ПоискОбъектов.НайтиБанк(Данные.БИК);
		СпрОбъект.ВалютаДенежныхСредств = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
		СпрОбъект.Наименование = СпрОбъект.НомерСчета;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции	

Функция ЗаполнитьДокументПлатеж(ДокументСсылка, СтрПлатеж, WSПрокси, СтруктураСсылок, Параметры)
	
	Если ОбщегоНазначения.СсылкаСуществует(ДокументСсылка) Тогда
		
		Если Параметры.ПерезаполнятьДокументы Тогда
			ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
		Иначе	
			Возврат ДокументСсылка;
		КонецЕсли;	
		
	Иначе
		
		// Новый документ
		ДокументОбъект = Документы.АСЦ_Платеж.СоздатьДокумент();
		ДокументОбъект.УстановитьСсылкуНового(ДокументСсылка);
		
	КонецЕсли;
	
	ДокументОбъект.РасшифровкаПлатежа.Очистить();
	
	ЗаписьXML = Новый ЗаписьXML; 
	ЗаписьXML.УстановитьСтроку();
	WSПрокси.ФабрикаXDTO.ЗаписатьXML(ЗаписьXML, СтрПлатеж); 
	СтрокаXML = ЗаписьXML.Закрыть();
		
	ДокументОбъект.Дата  = СтрПлатеж.Дата;
	ДокументОбъект.НомерВЦентральнойБазе = СтрПлатеж.Номер;
	
	ДокументОбъект.Организация = СтруктураСсылок.Организация;
	ДокументОбъект.ИННОрганизации = СтрПлатеж.ИННОрганизации;
	ДокументОбъект.КППОрганизации = СтрПлатеж.КППОрганизации;
	ДокументОбъект.ОрганизацияСсылка = СтрПлатеж.ОрганизацияСсылка;
	
	ДокументОбъект.СтрокаXML   = СтрокаXML; 
	ДокументОбъект.ИДДокумента = СтрПлатеж.ИДДокумента;
	ДокументОбъект.ДатаВходящегоДокумента  = СтрПлатеж.ДатаВходящегоДокумента;
	ДокументОбъект.НомерВходящегоДокумента = СтрПлатеж.НомерВходящегоДокумента;
	ДокументОбъект.БанковскийСчет          = ПолучитьБанковскийСчет(СтрПлатеж.БанковскийСчет, ДокументОбъект.Организация);
	ДокументОбъект.ВидБанковскогоДокумента = СтрПлатеж.ВидБанковскогоДокумента;
	
	ДокументОбъект.КонтрагентГУИД = СтрПлатеж.Контрагент;
	ДокументОбъект.НаименованиеКонтрагента = СтрПлатеж.НаименованиеКонтрагента;
	ДокументОбъект.ИННКонтрагента = СтрПлатеж.ИННКонтрагента;
	ДокументОбъект.КППКонтрагента = СтрПлатеж.КППКонтрагента;
	
	ДокументОбъект.ДоговорНомер  = СтрПлатеж.Договор;
	
	ДокументОбъект.СпособПлатежа = СтрПлатеж.СпособПлатежа;
	ДокументОбъект.ВидКассы      = СтрПлатеж.ВидКассы;
	ДокументОбъект.pay_tool      = СтрПлатеж.pay_tool;
	ДокументОбъект.ТочкаОплаты   = СтрПлатеж.ТочкаОплаты;
	ДокументОбъект.ВидПлатежногоДокумента = СтрПлатеж.ВидПлатежногоДокумента;
	
	Если ЗначениеЗаполнено(ДокументОбъект.pay_tool) Тогда
		 ДокументОбъект.ВидПлатежаЭквайринга = Перечисления.АСЦ_ВидыПлатежаЭквайринга.Терминал;
	Иначе
		 ДокументОбъект.ВидПлатежаЭквайринга = Перечисления.АСЦ_ВидыПлатежаЭквайринга.Касса;
	КонецЕсли;
	
	ДокументОбъект.КодВалюты    = СтрПлатеж.КодВалюты;
	ДокументОбъект.КодСтатьиДДС = СтрПлатеж.КодСтатьиДДС;
	ДокументОбъект.КодЦФО       = СтрПлатеж.КодЦФО;
	ДокументОбъект.СсылкаСч     = СтрПлатеж.СсылкаСч;
	ДокументОбъект.СчетВзаиморасчетов = СтрПлатеж.СчетВзаиморасчетов;
	ДокументОбъект.ДокументОснование  = СтрПлатеж.ДокументОснование;
	
	ДокументОбъект.СуммаДокумента    = СтрПлатеж.СуммаДокумента;
	ДокументОбъект.НазначениеПлатежа = СтрПлатеж.НазначениеПлатежа;
	ДокументОбъект.Комментарий       = СтрПлатеж.Комментарий;
	
	Для каждого СтрокаТЧ из СтрПлатеж.РасшифровкаПлатежа Цикл
		
		НоваяСтрока = ДокументОбъект.РасшифровкаПлатежа.Добавить();
		НоваяСтрока.ДокументСсылка = СтрокаТЧ.ДокументСсылка;
		НоваяСтрока.СсылкаСч       = СтрокаТЧ.СсылкаСч;
		НоваяСтрока.Сумма          = СтрокаТЧ.Сумма;
		НоваяСтрока.СтавкаНДС      = СтрокаТЧ.СтавкаНДС;
		НоваяСтрока.СуммаНДС       = СтрокаТЧ.СуммаНДС;
		НоваяСтрока.Договор        = СтрокаТЧ.Договор;
		НоваяСтрока.СчетВзаиморасчетов = СтрокаТЧ.СчетВзаиморасчетов;
		
	КонецЦикла;
	
	ДокументОбъект.Записать();
	
	Возврат ДокументОбъект.Ссылка;
		
КонецФункции	

