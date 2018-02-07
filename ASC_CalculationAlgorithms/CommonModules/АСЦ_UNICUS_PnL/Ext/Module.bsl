﻿// Данная процедура вызываются из обработчика "Процедура заполнения" 
// правила обработки отчета
//
Процедура ЗаполнитьОтчет(ДокОбъект) Экспорт
	
	ДокОбъект.ОчиститьВсе();
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Дата1",        ДокОбъект.ПериодОтчета.ДатаНачала);
	Запрос.Параметры.Вставить("Дата2",        КонецДня(ДокОбъект.ПериодОтчета.ДатаОкончания));
	Запрос.Параметры.Вставить("Номенклатура", Справочники.Номенклатура.НайтиПоНаименованию("Страховки"));
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СУММА(Выборка.Количество) КАК Количество,
	|	СУММА(Выборка.СуммаВыручка) КАК СуммаВыручка,
	|	СУММА(Выборка.СуммаАгентские) КАК СуммаАгентские,
	|	Выборка.Номенклатура КАК Номенклатура,
	|	Выборка.Номенклатура.Наименование КАК НоменклатураНаименование,
	|	Выборка.Номенклатура.НоменклатурнаяГруппа.Наименование КАК НоменклатурнаяГруппа
	|ИЗ
	|	(ВЫБРАТЬ
	|		1 КАК Количество,
	|		Док.Сумма КАК СуммаВыручка,
	|		0 КАК СуммаАгентские,
	|		Док.Номенклатура КАК Номенклатура
	|	ИЗ
	|		Документ.РеализацияТоваровУслуг.Услуги КАК Док
	|	ГДЕ
	|		Док.Ссылка.Проведен
	|		И Док.Ссылка.Дата МЕЖДУ &Дата1 И &Дата2
	|		И Док.Номенклатура В ИЕРАРХИИ(&Номенклатура)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		0,
	|		0,
	|		Док.Сумма,
	|		Док.Номенклатура
	|	ИЗ
	|		Документ.РеализацияТоваровУслуг.АгентскиеУслуги КАК Док
	|	ГДЕ
	|		Док.Ссылка.Проведен
	|		И Док.Ссылка.Дата МЕЖДУ &Дата1 И &Дата2
	|		И Док.Номенклатура В ИЕРАРХИИ(&Номенклатура)) КАК Выборка
	|
	|СГРУППИРОВАТЬ ПО
	|	Выборка.Номенклатура";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Колонка = ПолучитьКодСтатьи(Выборка.НоменклатураНаименование, Выборка.НоменклатурнаяГруппа);
		
		ДокОбъект.УстановитьЗначениеПоказателя("Выручка" + Колонка + "_Колво", Выборка.Количество, Выборка.Номенклатура);
		ДокОбъект.УстановитьЗначениеПоказателя("Выручка" + Колонка + "_Сумма", Выборка.СуммаВыручка + Выборка.СуммаАгентские, Выборка.Номенклатура);
		ДокОбъект.УстановитьЗначениеПоказателя("Себ"     + Колонка + "_Сумма", -Выборка.СуммаАгентские, Выборка.Номенклатура);
		ДокОбъект.УстановитьЗначениеПоказателя("Прибыль" + Колонка + "_Сумма", Выборка.СуммаВыручка, Выборка.Номенклатура);
		
	КонецЦикла;	
	
КонецПроцедуры

Функция ПолучитьКодСтатьи(НоменклатураНаименование, НоменклатурнаяГруппа) Экспорт
	
	Если НоменклатураНаименование = "КАСКО"
		ИЛИ НоменклатураНаименование = "КАСКО, АМ розница"
		ИЛИ НоменклатураНаименование = "КАСКО, Сторонний"
		Тогда
		Колонка = "РозницаКАСКО";
		
	ИначеЕсли НоменклатураНаименование = "КАСКО, АМ корпор." Тогда
		Колонка = "КорпКАСКО";
		
	ИначеЕсли НоменклатураНаименование = "КАСКО, АМ коммерч." Тогда
		Колонка = "КомКАСКО";
		
	ИначеЕсли НоменклатураНаименование = "КАСКО, АМ бу." Тогда
		Колонка = "БУ_КАСКО";
		
	ИначеЕсли Лев(НоменклатураНаименование, 18) = "КАСКО, пролонгация" Тогда
		Колонка = "ПролКАСКО";
		
	ИначеЕсли НоменклатураНаименование = "ОСАГО"
		ИЛИ НоменклатураНаименование = "ОСАГО, АМ розница"
		ИЛИ НоменклатураНаименование = "ОСАГО, Сторонний"
		Тогда
		
		Колонка = "РозницаОСАГО";
		
	ИначеЕсли НоменклатураНаименование = "ОСАГО, АМ корпор." Тогда
		Колонка = "КорпОСАГО";
		
	ИначеЕсли НоменклатураНаименование = "ОСАГО, АМ коммерч." Тогда
		Колонка = "КомОСАГО";
		
	ИначеЕсли НоменклатураНаименование = "ОСАГО, АМ бу." Тогда
		Колонка = "БУ_ОСАГО";
		
	ИначеЕсли Лев(НоменклатураНаименование, 18) = "ОСАГО, пролонгация" Тогда
		Колонка = "ПролОСАГО";
		
	ИначеЕсли НоменклатурнаяГруппа = "Страхование жизни"
		ИЛИ НоменклатурнаяГруппа = "Защита автокредита" Тогда
		
		Колонка = "СтрахЖизни";
		
	ИначеЕсли Найти(НоменклатураНаименование, ", пролонгация") > 0 Тогда
		Колонка = "ПролФинУслуги";
		
	ИначеЕсли НоменклатурнаяГруппа = "GAP страхование" Тогда
		Колонка = "ПрочееСтрах";
		
	Иначе
		Колонка = "ПрочФинУслуги";
		
	КонецЕсли;
	
	Возврат Колонка;
	
КонецФункции
