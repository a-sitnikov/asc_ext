﻿
&Вместо("ПередЗаписью")
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = СуммаКВ;
	НовыйАвто = (СтрНайти(ВРег(Статья), "БУ") <> 0);
	
	Если ЗначениеЗаполнено(Ссылка) Тогда
		СтараяБазаАстра = АСЦ_ПоискОбъектов.ПолучитьОсновнуюБазу(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ДЦ"));
		ДополнительныеСвойства.Вставить("СтараяБазаАстра", СтараяБазаАстра);
	КонецЕсли;	
	
	ДополнительныеСвойства.Вставить("ЭтоНовый", ЭтоНовый());
	ДополнительныеСвойства.Вставить("РежимЗаписи", РежимЗаписи);
	
КонецПроцедуры

&Вместо("ОбработкаЗаполнения")
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ВалютаДокумента = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.АСЦ_ПлановоеНачислениеКВ") Тогда
		
		Корректировка = Документы.АСЦ_ПлановоеНачислениеКВ.ПолучитьКорректировку(ДанныеЗаполнения.Ссылка);
		Если ЗначениеЗаполнено(Корректировка) Тогда
			ВызватьИсключение "Уже введен документ " + Строка(Корректировка);
		КонецЕсли;	
		
		// Заполнение шапки
		ВидОперации  = ДанныеЗаполнения.ВидОперации;
		Основание    = ДанныеЗаполнения.Ссылка;
		Организация  = ДанныеЗаполнения.Организация;
		ДЦ           = ДанныеЗаполнения.ДЦ;
		Контрагент   = ДанныеЗаполнения.Контрагент;
		ДоговорКонтрагента  = ДанныеЗаполнения.ДоговорКонтрагента;
		Комитент     = ДанныеЗаполнения.Комитент;
		Реализация   = ДанныеЗаполнения.Реализация;
		РеализацияОрганизация = ДанныеЗаполнения.РеализацияОрганизация;
		VIN          = ДанныеЗаполнения.VIN;
		Сумма        = ДанныеЗаполнения.Сумма;
		ПроцентКВ    = ДанныеЗаполнения.ПроцентКВ;
		СуммаКВ      = ДанныеЗаполнения.СуммаКВ;
		Статья       = ДанныеЗаполнения.Статья;
		ЦФО          = ДанныеЗаполнения.ЦФО;
		Номенклатура = ДанныеЗаполнения.Номенклатура;
		ДатаКредитнойСделки = ДанныеЗаполнения.ДатаКредитнойСделки;
		ЭтоКорректировка = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&Вместо("ПриЗаписи")
Процедура ПриЗаписи(Отказ)
	
	НастройкаСоответствия = ВидОперации.НастройкаСоотвествияВыгрузкаАстра;
	
	БазаАстра = АСЦ_ПоискОбъектов.ПолучитьОсновнуюБазу(ДЦ);
	Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
	Запись.ИспользуемаяИБ        = БазаАстра;
	Запись.НастройкаСоответствия = НастройкаСоответствия;
	Запись.Элемент               = Ссылка;
	Запись.Записать();
	
	СтараяБазаАстра = Неопределено;
	ДополнительныеСвойства.Свойство("СтараяБазаАстра", СтараяБазаАстра);
	
	Если СтараяБазаАстра <> Неопределено
		И БазаАстра <> СтараяБазаАстра Тогда
		
		Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
		Запись.ИспользуемаяИБ        = СтараяБазаАстра;
		Запись.НастройкаСоответствия = НастройкаСоответствия;
		Запись.Элемент               = Ссылка;
		Запись.Записать();
		
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(Основание) Тогда
		
		ОснованиеБазаАстра = АСЦ_ПоискОбъектов.ПолучитьОсновнуюБазу(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Основание, "ДЦ"));
		Если БазаАстра <> ОснованиеБазаАстра Тогда
			
			Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
			Запись.ИспользуемаяИБ        = СтараяБазаАстра;
			Запись.НастройкаСоответствия = НастройкаСоответствия;
			Запись.Элемент               = Ссылка;
			Запись.Записать();
			
		КонецЕсли;	
		
	КонецЕсли;	
	
КонецПроцедуры

&Вместо("ОбработкаПроведения")
Процедура АСЦ_ОбработкаПроведения(Отказ, РежимПроведения)
	
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ИнициализироватьДополнительныеСвойстваДляПроведения(Ссылка, ДополнительныеСвойства, РежимПроведения);
	ПараметрыПроведения = Документы[Метаданные().Имя].ПодготовитьПараметрыПроведения(Ссылка, Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ЭтотОбъект.ДополнительныеСвойства.Вставить("ПараметрыПроведения", ПараметрыПроведения);
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ПодготовитьНаборыЗаписейКРегистрацииДвижений(ЭтотОбъект);
	
	Для каждого ТаблицаДвижения Из ПараметрыПроведения.ТаблицыДляДвижений Цикл
		Движения[ТаблицаДвижения.Ключ].Загрузить(ТаблицаДвижения.Значение);
		Движения[ТаблицаДвижения.Ключ].Записывать = Истина;
	КонецЦикла;
		
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ЗаписатьНаборыЗаписей(ЭтотОбъект);
	//ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ВыполнитьКонтрольРезультатовПроведения(ЭтотОбъект, Отказ);	
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ОчиститьДополнительныеСвойстваДляПроведения(ДополнительныеСвойства);

КонецПроцедуры

&Вместо("ОбработкаУдаленияПроведения")
Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ИнициализироватьДополнительныеСвойстваДляПроведения(Ссылка, ДополнительныеСвойства);	
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ПодготовитьНаборыЗаписейКРегистрацииДвижений(ЭтотОбъект);	
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ЗаписатьНаборыЗаписей(ЭтотОбъект);
	ПолучениеДанныхУчетнойСистемыПереопределяемыйУХ.ОчиститьДополнительныеСвойстваДляПроведения(ДополнительныеСвойства);

КонецПроцедуры
