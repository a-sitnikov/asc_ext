﻿
Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Информация = "Загрузка данных из UNICUS в экземпляр отчета за текущий месяц по всем организациям";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление() + " - Открыть форму";
	НоваяКоманда.Идентификатор = Метаданные().Имя + "Форма";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление();
	НоваяКоманда.Идентификатор = Метаданные().Имя;
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	НоваяКоманда.ПоказыватьОповещение = Ложь;

	Возврат ПараметрыРегистрации;

КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды = Неопределено) Экспорт 
	
	ВИБ    = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус");
	Период = ПолучитьТекущийПериод();
	
	//ЗаписьЖурналаРегистрации("Загрузка отчета UNICUS",
	//	УровеньЖурналаРегистрации.Предупреждение,,, "Параметры: " + вСтроку(ПараметрыКоманды));
		
	Загрузить();
	
КонецПроцедуры	

Функция вСтроку(ПараметрыКоманды)
	
	Если ПараметрыКоманды = Неопределено Тогда
		Возврат "";
	ИначеЕсли ТипЗнч(ПараметрыКоманды) = Тип("Структура")
		ИЛИ ТипЗнч(ПараметрыКоманды) = Тип("Соответствие") Тогда
		
		Рез = "";
		Для каждого КлючИЗначение из ПараметрыКоманды Цикл
			Рез = Рез + Символы.ПС + Строка(КлючИЗначение.Ключ) + ": " + вСтроку(КлючИЗначение.Значение);
		КонецЦикла;	
		
		Возврат Рез;
		
	Иначе
		Возврат Строка(ПараметрыКоманды);
	КонецЕсли;	
	
КонецФункции	

Процедура Загрузить() Экспорт
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	ПараметрыПодключения = Новый Структура;
	Соединение = УправлениеСоединениямиВИБУХ.ПолучитьСоединениеADO(ВИБ,ПараметрыПодключения);
	
	ТекстЗапроса =
	"SELECT DISTINCT
	|	V_ASC_CONTRACT.AGENT
	|FROM 
	|	V_ASC_CONTRACT
	|WHERE
	|	V_ASC_CONTRACT.PAY_DATE >= TO_DATE(&ДатаНач, 'DD-MM-YYYY HH24:MI:SS')
	|	AND V_ASC_CONTRACT.PAY_DATE <= TO_DATE(&ДатаКон, 'DD-MM-YYYY HH24:MI:SS')";
	
	Если ЗначениеЗаполнено(Организация) Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|	AND V_ASC_CONTRACT.AGENT = &Организация";
	КонецЕсли;	
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", "'" + Формат(Период.ДатаНачала,    "ДФ='dd.MM.yyyy HH:mm:ss'") + "'");
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаКон", "'" + Формат(Период.ДатаОкончания, "ДФ='dd.MM.yyyy HH:mm:ss'") + "'");
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Организация", "'" + Организация.Наименование + "'");
	
	ВидОтчета = Справочники.ВидыОтчетов.НайтиПоКоду("UNICUS");
	Сценарий  = Справочники.Сценарии.Факт;
	
	Таблица = ВыполнитьЗапросADO(Соединение, ТекстЗапроса);
	
	Для каждого СтрокаТЗ из Таблица Цикл
		
		Если Не ЗначениеЗаполнено(СтрокаТЗ.AGENT) Тогда
			Продолжить;
		КонецЕсли;	
		
		текОрганизация = ПолучитьОрганизацию(СтрокаТЗ.AGENT);
		Если Не ЗначениеЗаполнено(текОрганизация) Тогда
			Сообщить("Не найдена организация: " + СтрокаТЗ.AGENT);
			ЗаписьЖурналаРегистрации("Загрузка отчета UNICUS",
				УровеньЖурналаРегистрации.Предупреждение,,, "Не найдена организация: " + СтрокаТЗ.AGENT);
			Продолжить;
		КонецЕсли;	
		
		ДокументСсылка = ПолучитьЭкземплярОтчета(текОрганизация, ВидОтчета, Сценарий);
		Если ЗначениеЗаполнено(ДокументСсылка) Тогда
			ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
			ДокументОбъект.ПометкаУдаления = Ложь;
		Иначе
			ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
			ДокументОбъект.ПериодОтчета = Период;
			ДокументОбъект.Организация  = текОрганизация;
			ДокументОбъект.ВидОтчета    = ВидОтчета;
			ДокументОбъект.Сценарий     = Сценарий;
			ДокументОбъект.ОсновнаяВалюта = Константы.ВалютаРегламентированногоУчета.Получить();
			ДокументОбъект.СпособФормированияОтчета = Перечисления.СпособыФормированияОтчетов.АвтоматическиПоПравилуОбработки;
		КонецЕсли;	
		
		БланкОтчета = УправлениеОтчетамиУХ.НайтиПараметрОтчета(Перечисления.ЭлементыНастройкиОтчета.БланкДляОтображения, ВидОтчета, Сценарий, Организация, Период);
		ДокументОбъект.ПравилоОбработки = УправлениеОтчетамиУХ.НайтиПараметрОтчета(Перечисления.ЭлементыНастройкиОтчета.ПравилоОбработки, ВидОтчета, Сценарий, Организация, Период);
		ДокументОбъект.ПравилоПроверки  = УправлениеОтчетамиУХ.НайтиПараметрОтчета(Перечисления.ЭлементыНастройкиОтчета.ПравилоПроверки, ВидОтчета, Сценарий, Организация, Период);
		ДокументОбъект.ИспользуемаяИБ   = ВИБ;
		ДокументОбъект.СпособВывода     = "Бланк";
		ДокументОбъект.ШаблонОтчета     = БланкОтчета;
		ДокументОбъект.УровеньТочности  = 2;
		
		ДокументОбъект.ИнициализироватьКонтекст();
		
		Если ЗначениеЗаполнено(ДокументСсылка) Тогда
			ДокументОбъект.ОчиститьРегистры();
		КонецЕсли;	
		
		ДокументОбъект.ДополнительныеСвойства.Вставить("Тест_ДопПараметр", "AND rownum <= 12");
		ДокументОбъект.ЗаполнитьОтчетПоУмолчанию();
		ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
		
	КонецЦикла;	
	
КонецПроцедуры	

Функция ВыполнитьЗапросADO(Соединение, ТекстЗапроса)
	
	НаборЗаписей = Соединение.Execute(ТекстЗапроса);
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	Для Счетчик = 0 По НаборЗаписей.Fields.Count - 1 Цикл
		ТаблицаДанных.Колонки.Добавить(НаборЗаписей.Fields(Счетчик).Name);
	КонецЦикла;	
	
	Если НЕ НаборЗаписей.EOF Тогда		

		НаборЗаписей.MoveFirst();
		Пока НЕ НаборЗаписей.EOF Цикл
			
			НоваяЗапись = ТаблицаДанных.Добавить();
			Для каждого Колонка из ТаблицаДанных.Колонки Цикл
				НоваяЗапись[Колонка.Имя] = НаборЗаписей.Fields(Колонка.Имя).Value;
			КонецЦикла;	

			НаборЗаписей.MoveNext();
			
		КонецЦикла;
		
	КонецЕсли;
	
	НаборЗаписей.Close();
	
	Возврат ТаблицаДанных;
	
КонецФункции

Функция ПолучитьОрганизацию(Наименование)
	
	Возврат Справочники.Организации.НайтиПоНаименованию(Наименование);
	
КонецФункции	

Функция ПолучитьЭкземплярОтчета(текОрганизация, ВидОтчета, Сценарий)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Организация",  текОрганизация);
	Запрос.Параметры.Вставить("ПериодОтчета", Период);
	Запрос.Параметры.Вставить("ВидОтчета",    ВидОтчета);
	Запрос.Параметры.Вставить("Сценарий",     Сценарий);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.НастраиваемыйОтчет КАК Док
	|ГДЕ
	|	Док.ПериодОтчета = &ПериодОтчета
	|	И Док.Организация = &Организация
	|	И Док.ВидОтчета = &ВидОтчета
	|	И Док.Сценарий = &Сценарий";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;	
	
КонецФункции	

Функция ПолучитьТекущийПериод()
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Периодичность", Перечисления.Периодичность.Месяц);
	Запрос.Параметры.Вставить("ДатаНачала",    НачалоМесяца(ТекущаяДата()));
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Периоды КАК Спр
	|ГДЕ
	|	Спр.Периодичность = &Периодичность
	|	И Спр.ДатаНачала = &ДатаНачала";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		Возврат Справочники.Периоды.ПустаяСсылка();
	КонецЕсли;	
	
КонецФункции	