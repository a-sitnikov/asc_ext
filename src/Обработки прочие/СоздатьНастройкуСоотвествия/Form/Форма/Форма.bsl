﻿
&НаКлиенте
Процедура Создать(Команда)
	СоздатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура СоздатьНаСервере()
	
	СпрСсылка = Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию(Наименование,,, ТипБазы);
	Если НЕ ЗначениеЗаполнено(СпрСсылка) Тогда
		
		СпрОбъект = Справочники.СоответствиеВнешнимИБ.СоздатьЭлемент();
		СпрОбъект.Наименование = Наименование;
		СпрОбъект.Владелец     = ТипБазы;
		СпрОбъект.ОбменДанными.Загрузка = Истина;
		СпрОбъект.Записать();
		
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура Заменить(Команда)
	ЗаменитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаменитьНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Настройка", НастройкаДо);
	Запрос.Параметры.Вставить("База",      База);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Рег.ОбъектТекущейИБ КАК ОбъектТекущейИБ,
	|	Рег.ОбъектВнешнейИБ КАК ОбъектВнешнейИБ,
	|	Рег.НастройкаСоответствия КАК НастройкаСоответствия,
	|	Рег.ИспользуемаяИБ КАК ИспользуемаяИБ
	|ИЗ
	|	РегистрСведений.СоответствиеОбъектовТекущейИВнешнихИБ КАК Рег
	|ГДЕ
	|	Рег.ИспользуемаяИБ = &База
	|	И Рег.НастройкаСоответствия = &Настройка";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаТЗ из Таблица Цикл
		
		Запись = РегистрыСведений.СоответствиеОбъектовТекущейИВнешнихИБ.СоздатьМенеджерЗаписи();
		Запись.ОбъектТекущейИБ = СтрокаТЗ.ОбъектТекущейИБ;
		Запись.ОбъектВнешнейИБ = СтрокаТЗ.ОбъектВнешнейИБ;
		Запись.НастройкаСоответствия = СтрокаТЗ.НастройкаСоответствия;
		Запись.ИспользуемаяИБ = СтрокаТЗ.ИспользуемаяИБ;
		Запись.Прочитать();
		
		Запись.НастройкаСоответствия = НастройкаПосле;
		Запись.Записать(Истина);
		
	КонецЦикла;	
	
КонецПроцедуры
