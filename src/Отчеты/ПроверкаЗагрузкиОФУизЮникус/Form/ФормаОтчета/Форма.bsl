﻿
&НаКлиенте
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ИмяФайлаНачалоЗавершение", ЭтотОбъект);
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Фильтр = "*.xlsx|*.xlsx";
	Диалог.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаНачалоЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда 
		Возврат;
	КонецЕсли;	
	
	ИмяФайла = ВыбранныеФайлы[0];
	
КонецПроцедуры


&НаКлиенте
Процедура Сформировать(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьЗавершение", ЭтотОбъект);
	НачатьПомещениеФайла(ОписаниеОповещения, , ИмяФайла , Ложь, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьЗавершение(Результат, АдресХранилища, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	
	Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.Вставить("АдресХранилища", АдресХранилища);
	СкомпоноватьРезультат(РежимКомпоновкиРезультата.Непосредственно);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЗапуститьПриложение(ИмяФайла);
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатОбработкаДополнительнойРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка, ДополнительныеПараметры)
	
	СтандартнаяОбработка = Ложь;
	Список = Новый СписокЗначений;
	Список.Добавить("Показать данные в Юникус");
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("Расшифровка", Расшифровка);
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыборИзМенюЗавершение", ЭтотОбъект, ДопПараметры);
	
	ПоказатьВыборИзМеню(ОписаниеОповещения, Список);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборИзМенюЗавершение(ВыбранныйЭлемент, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыбранныйЭлемент.Значение = "Показать данные в Юникус" Тогда
		
		СтруктураПараметров = Новый Структура;
		СтруктураПараметров.Вставить("Договор", Строка(ПолучитьПоле(ДополнительныеПараметры.Расшифровка, "ДоговорЗначение")));
		
		Если ЗначениеЗаполнено(СтруктураПараметров.Договор) Тогда
			ОткрытьФорму("ВнешнийОтчет.ПроверкаЗагрузкиОФУизЮникус.Форма.ФормаДанныеЮникус", СтруктураПараметров, ЭтаФорма, Строка(СтруктураПараметров.Договор));
		КонецЕсли;	
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьПоле(Расшифровка, Имя)
	
	ДанныеРасшифровкиОбъект = ПолучитьИзВременногоХранилища(ДанныеРасшифровки);
	Поля = ДанныеРасшифровкиОбъект.Элементы[Расшифровка].ПолучитьПоля();
	Для каждого Поле из  Поля Цикл
		
		Если Поле.Поле = Имя Тогда
			Возврат Поле.Значение;
		КонецЕсли;	
			
	КонецЦикла;	
	
	МассивРодителей = ДанныеРасшифровкиОбъект.Элементы[Расшифровка].ПолучитьРодителей();
	Для каждого Родитель из МассивРодителей Цикл
		
		Поля = Родитель.ПолучитьПоля();
		Для каждого Поле из  Поля Цикл
			
			Если Поле.Поле = Имя Тогда
				Возврат Поле.Значение;
			КонецЕсли;	
				
		КонецЦикла;	
		
	КонецЦикла;	
	
	Возврат Неопределено;
	
КонецФункции	
