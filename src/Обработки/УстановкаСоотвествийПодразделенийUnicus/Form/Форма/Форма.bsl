﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус");
	ТолькоУправлениескиеОрганизации = Истина;
	
	ДатаНачала = '2016-01-01';
	
КонецПроцедуры

&НаКлиенте
Процедура Прочитать(Команда)
	ПрочитатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПрочитатьНаСервере()
	
	СтрокаСоединения = УправлениеСоединениямиВИБУХ.ПолучитьСтрокуСоединенияADO(База);
	
	ТекстЗапроса = 
	"SELECT DISTINCT
	|	DEPARTMENT_NAME
	|FROM
	|	V_ASC_CONTRACT
	|WHERE
	|	DATE_SIGN >= &ДатаНач
	|ORDER BY
	|	1";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДатаНачала, "Oracle"));
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.Open(СтрокаСоединения);
	
	мНаборЗаписей = Соединение.Execute(ТекстЗапроса);
	
	ТаблицаДанных.Очистить();
	
	Пока НЕ мНаборЗаписей.EOF Цикл
			
		НоваяСтрока = ТаблицаДанных.Добавить();
		НоваяСтрока.Наименование = мНаборЗаписей.Fields("DEPARTMENT_NAME").Value;
		
		мНаборЗаписей.MoveNext();
		
	КонецЦикла;	
	
	мНаборЗаписей.Close();
	
	Свойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "НаименованиеUNICUS");
	Для каждого СтрокаТЗ из ТаблицаДанных Цикл
		СтрокаТЗ.Организация = ПолучитьОрганизацию(СтрокаТЗ.Наименование, Свойство);
	КонецЦикла;	
	
	Элементы.ТаблицаДанныхЗаписать.КнопкаПоУмолчанию = Истина;
	
КонецПроцедуры

Функция ПолучитьОрганизацию(Наименование, Свойство)
	
	СпрСсылка = РегистрыСведений.АСЦ_СоответствиеПодразделенийUnicus.ПолучитьОрганизацию(Наименование);
	Возврат СпрСсылка;
	
КонецФункции

&НаКлиенте
Процедура ТаблицаОрганизацияПриИзменении(Элемент)
	
	Элементы.ТаблицаДанных.ТекущиеДанные.Изменен = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	ЗаписатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНаСервере()
	
	Свойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "НаименованиеUNICUS");
	
	Для каждого СтрокаТЗ из ТаблицаДанных Цикл
		
		Если НЕ СтрокаТЗ.Изменен Тогда
			Продолжить;
		КонецЕсли;	
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЗ.Организация) Тогда
			Продолжить;
		КонецЕсли;	
		
		РегистрыСведений.АСЦ_СоответствиеПодразделенийUnicus.ЗаписатьСоответствие(СтрокаТЗ.Наименование, СтрокаТЗ.Организация);
		//Запись = РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
		//Запись.Объект   = СтрокаТЗ.Организация;
		//Запись.Свойство = Свойство;
		//Запись.Значение = СтрокаТЗ.Наименование;
		//Запись.Записать();
		
		СтрокаТЗ.Изменен = Ложь;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаОрганизацияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если ТолькоУправлениескиеОрганизации Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Форма = ПолучитьФорму("Справочник.Организации.ФормаВыбора",, Элемент);
		ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Форма.Список, "Ссылка", ПолучитьСписокОрганизаций(), ВидСравненияКомпоновкиДанных.ВСпискеПоИерархии);
		
		Форма.Элементы.Список.НачальноеОтображениеДерева = НачальноеОтображениеДерева.РаскрыватьВерхнийУровень;
		Форма.Элементы.Список.ТекущаяСтрока = Элементы.ТаблицаДанных.ТекущиеДанные.Организация;
		
		Форма.Открыть();
	
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСписокОрганизаций()
	
	Список = Новый СписокЗначений;
	Список.Добавить(Справочники.Организации.НайтиПоНаименованию("Центры из АСТРЫ"));
	
	Возврат Список;
	
КонецФункции
