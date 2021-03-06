﻿
&НаКлиенте
Процедура Зарегистрировать(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗарегистрироватьОтвет", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Зарегистрировать документы к выгрузке?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗарегистрироватьОтвет(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ЗарегистрироватьСервер();
	
КонецПроцедуры

&НаСервере
Процедура ЗарегистрироватьСервер() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("База",  База);
	Запрос.Параметры.Вставить("Дата1", Период.ДатаНачала);
	Запрос.Параметры.Вставить("Дата2", Период.ДатаОкончания);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК Док
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.НастройкаОбработкиОтчетов КАК Рег
	|		ПО Док.ДоговорКонтрагента.ОсновнойЦФО = Рег.Организация
	|			И (Рег.ЭлементНастройкиОтчета = ЗНАЧЕНИЕ(Перечисление.ЭлементыНастройкиОтчета.ВнешняяИнформационнаяБаза))
	|			И (Рег.ШаблонДокументаБД = НЕОПРЕДЕЛЕНО)
	|			И Рег.ЗначениеЭлементаНастройкиОтчета = &База
	|ГДЕ
	|	Док.Дата МЕЖДУ &Дата1 И &Дата2
	|	И Док.Проведен
	|
	|УПОРЯДОЧИТЬ ПО
	|	Док.Дата";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
		Запись.ИспользуемаяИБ        = База;
		Запись.НастройкаСоответствия = "";
		Запись.Элемент               = Выборка.Ссылка;
		
		Запись.Записать();
		
	КонецЦикла;	
	
	Сообщить(Выборка.Количество());
	
КонецПроцедуры
