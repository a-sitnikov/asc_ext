﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ДополнительнаяОбработкаСсылка", ДополнительнаяОбработкаСсылка);
	
	ВыполнятьвФоне = Истина;
	База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("РИС");
	
	// Регистрация
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	СхемаСКД = ОбработкаОбъект.ПолучитьМакет("СхемаСКД");
	
	АдресХранилища = ПоместитьВоВременноеХранилище(СхемаСКД, УникальныйИдентификатор);
	
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресХранилища));
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаСКД.НастройкиПоУмолчанию);
	
	ОбработкаМетаданные = ОбработкаОбъект.Метаданные();
	
	АвтоЗаголовок = Ложь;
	Заголовок     = ОбработкаМетаданные.Представление() + ", версия: " + ОбработкаМетаданные.Комментарий;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	Элементы.Индикатор.Видимость = ВыполнятьвФоне;
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьТекстГруппыОтлдадки(ЭтаФорма)
	
	МассивСтрок = Новый Массив;
	Если ЗначениеЗаполнено(ЭтаФорма.Тест_КоличествоСтрок) Тогда
		МассивСтрок.Добавить("колво строк: " + ЭтаФорма.Тест_КоличествоСтрок);
	КонецЕсли;	
	
	ЭтаФорма.ТекстГруппыОтладки = СтрСоединить(МассивСтрок, ", ");
	
КонецПроцедуры	

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура КолвоСтрокПриИзменении(Элемент)
	УстановитьТекстГруппыОтлдадки(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнятьвФонеПриИзменении(Элемент)
	
	Элементы.Индикатор.Видимость = ВыполнятьвФоне;
	
КонецПроцедуры

#КонецОбласти

#Область ФоновоеВыполнение

&НаКлиенте
Процедура ПрогрессВыполнения(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат.Статус = "Выполняется" 
		ИЛИ Результат.Статус = "Выполнено" Тогда
		
		РезультатЗадания = ПрочитатьПрогрессИСообщения(Результат.ИдентификаторЗадания);
		Если РезультатЗадания.Прогресс <> Неопределено Тогда
			Индикатор = РезультатЗадания.Прогресс.Процент;
			Текст     = РезультатЗадания.Прогресс.Текст;
		КонецЕсли;
		
		Если РезультатЗадания.Сообщения <> Неопределено Тогда
			Для Каждого Сообщение Из РезультатЗадания.Сообщения Цикл
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение.Текст, Сообщение.КлючДанных, Сообщение.Поле, Сообщение.ПутьКДанным);
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПрочитатьПрогрессИСообщения(ИдентификаторЗадания)
	Возврат ДлительныеОперации.ОперацияВыполнена(ИдентификаторЗадания, Истина, Истина, Истина);
КонецФункции

&НаКлиенте
Процедура ПослеФоновойОбработкиДанных(Задание, ДополнительныеПараметры) Экспорт
	
	Если Задание = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	Если Задание.Статус = "Ошибка" Тогда
		
		ТекстОшибки = Задание.КраткоеПредставлениеОшибки;
		
		ОчиститьСообщения();
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
		
	ИначеЕсли Задание.Статус = "Выполнено" Тогда
		
		РезультатЗадания = ПрочитатьПрогрессИСообщения(ИдентификаторЗадания);
		Если РезультатЗадания.Сообщения <> Неопределено Тогда
			
			Для Каждого Сообщение Из РезультатЗадания.Сообщения Цикл
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение.Текст, Сообщение.КлючДанных, Сообщение.Поле, Сообщение.ПутьКДанным);
			КонецЦикла;
			
		КонецЕсли;
		
		Состояние("Обработка завершена");
		ЗавершениеЗагрузки(Задание.АдресРезультата);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗавершениеЗагрузки(АдресРезультата)
	
	Текст = "Обработка завершена";
	
КонецПроцедуры

#КонецОбласти

#Область ВыгрузитьДокументы

&НаКлиенте
Процедура ВыгрузитьДокументы(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыгрузитьДокументыОтвет", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Выгрузить документы?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьДокументыОтвет(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ПрогрессВыполнения", ЭтотОбъект);
	Задание = ВыгрузитьДокументыСервер();
	
	Если Задание <> Неопределено Тогда
		
		НастройкиОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		НастройкиОжидания.ВыводитьОкноОжидания = Ложь;
		НастройкиОжидания.ПолучатьРезультат    = Истина;
		НастройкиОжидания.ВыводитьСообщения    = Ложь;
		НастройкиОжидания.Интервал = 1;
		НастройкиОжидания.ОповещениеОПрогрессеВыполнения  = ОповещениеОПрогрессеВыполнения;
		НастройкиОжидания.ОповещениеПользователя.Показать = Ложь;
		
		Обработчик = Новый ОписаниеОповещения("ПослеФоновойОбработкиДанных", ЭтотОбъект);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(Задание, Обработчик, НастройкиОжидания);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ВыгрузитьДокументыСервер()
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ДатаНач",            Период.ДатаНачала);
	СтруктураПараметров.Вставить("ДатаКон",            Период.ДатаОкончания);
	СтруктураПараметров.Вставить("База",               База);
	СтруктураПараметров.Вставить("ПерезаполнятьДокументы", ПерезаполнятьДокументы);
	СтруктураПараметров.Вставить("ВыводитьСообщения",      ВыводитьСообщения);
	
	СтруктураПараметров.Вставить("Тест_КоличествоСтрок",      Тест_КоличествоСтрок);
	СтруктураПараметров.Вставить("Тест_НеУдалятьРегистрацию", Тест_НеУдалятьРегистрацию);
	
	Если ОтборДокументИспользование Тогда
		СтруктураПараметров.Вставить("ОтборДокумент", ОтборДокумент);
	КонецЕсли;	
	
	СтруктураПараметров.Вставить("ИдентификаторФормы", ЭтаФорма.УникальныйИдентификатор);
	СтруктураПараметров.Вставить("ИмяФормы",           ЭтаФорма.ИмяФормы);
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Индикатор = 0;
	Текст     = "";
	
	Если ВыполнятьвФоне Тогда
		
		Если ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
			Попытка
				ЗаданиеВыполнено = ДлительныеОперации.ЗаданиеВыполнено(ИдентификаторЗадания);
			Исключение
				ЗаданиеВыполнено = Истина;
			КонецПопытки;
		Иначе
			ЗаданиеВыполнено = Истина;
		КонецЕсли;
		Если ЗаданиеВыполнено = Ложь Тогда
			// Надо ждать
			Возврат Неопределено;
		КонецЕсли;
		
		ВыполняемыйМетод = "ДлительныеОперации.ВыполнитьПроцедуруМодуляОбъектаОбработки";
		
		ЭтоВнешняяОбработка = Не Метаданные.Обработки.Содержит(ОбработкаОбъект.Метаданные());
		НаименованиеЗадания = ОбработкаОбъект.Метаданные().Представление();
	
		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("ИмяОбработки",                  ОбработкаОбъект.ИспользуемоеИмяФайла);
		ПараметрыЗадания.Вставить("ИмяМетода",                     "ВыгрузитьДокументы");
		ПараметрыЗадания.Вставить("ПараметрыВыполнения",           СтруктураПараметров);
		ПараметрыЗадания.Вставить("ЭтоВнешняяОбработка",           ЭтоВнешняяОбработка);
		ПараметрыЗадания.Вставить("ДополнительнаяОбработкаСсылка", ДополнительнаяОбработкаСсылка);
		
		ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(ЭтаФорма.УникальныйИдентификатор);
		ПараметрыВыполнения.НаименованиеФоновогоЗадания = НаименованиеЗадания;
		ПараметрыВыполнения.ЗапуститьВФоне = Истина;
		
		РезультатФоновогоЗадания = ДлительныеОперации.ВыполнитьВФоне(ВыполняемыйМетод, ПараметрыЗадания, ПараметрыВыполнения);
		ИдентификаторЗадания = РезультатФоновогоЗадания.ИдентификаторЗадания;
		Возврат РезультатФоновогоЗадания;
		
	Иначе
		
		АдресРезультата = ПоместитьВоВременноеХранилище(Неопределено, ЭтаФорма.УникальныйИдентификатор);
		ОбработкаОбъект.ВыгрузитьДокументы(СтруктураПараметров, АдресРезультата);
		ЗавершениеЗагрузки(АдресРезультата);
		
	КонецЕсли;
	
КонецФункции

#КонецОбласти

&НаКлиенте
Процедура ОткрытьСписок(Команда)
	
	ОткрытьФорму("РегистрСведений.ИзмененныеОбъектыДляВыгрузки.ФормаСписка");
	
КонецПроцедуры


&НаСервере
Процедура ОтобратьДляРегистрацииНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	СхемаСКД = ОбработкаОбъект.ПолучитьМакет("СхемаСКД");
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаСКД, КомпоновщикНастроек.ПолучитьНастройки(),,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
		
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки);
		
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		
	ТЗ = ПроцессорВывода.Вывести(ПроцессорКомпоновки, Истина);
	ТаблицаРегистрации.Загрузить(ТЗ);
	
	Для каждого СтрокаТЗ из ТаблицаРегистрации Цикл
		СтрокаТЗ.Пометка = Истина;
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ОтобратьДляРегистрации(Команда)
	ОтобратьДляРегистрацииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Зарегистрировать(Команда)
	
	ЗарегистрироватьНаСервере();
	Состояние("Регистрация завершена");
	
КонецПроцедуры

&НаСервере
Процедура ЗарегистрироватьНаСервере()
	
	Для каждого СтрокаТЗ из ТаблицаРегистрации Цикл
		
		Если НЕ СтрокаТЗ.Пометка Тогда
			Продолжить;
		КонецЕсли;
		
		Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
		Запись.ИспользуемаяИБ        = СтрокаТЗ.База;
		Запись.НастройкаСоответствия = Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию("Реализация ОФУ");
		Запись.Элемент               = СтрокаТЗ.Документ;
		
		Запись.Записать();
		
		СтрокаТЗ.Пометка = Ложь;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаРегистрацииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекущиеДанные = ТаблицаРегистрации.НайтиПоИдентификатору(ВыбраннаяСтрока);
	ПоказатьЗначение(, ТекущиеДанные.Документ);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьЗапрос(Команда)
	
	Если НЕ ЗначениеЗаполнено(ОтборДокумент) Тогда
		Сообщить("Не выбран документ");
		Возврат;
	КонецЕсли;	
	
	ТекстЗапроса = ПоказатьЗапросНаСервере();
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(ТекстЗапроса);
	ТекстовыйДокумент.Показать("Текст запроса ASTRA");
	
КонецПроцедуры

&НаСервере
Функция ПоказатьЗапросНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Кэш = Новый Структура;
	Кэш.Вставить("Соединения", Новый Соответствие);
	Кэш.Вставить("Базы",       Новый Соответствие);
	
	Данные = АСЦ_ВыгрузкаВАстра.ПолучитьДанныеДокумента_РеализацияОФУ(ОтборДокумент);
	ТекстЗапроса = АСЦ_ВыгрузкаВАстра.ПолучитьТекстЗапроса_РеализацияОФУ(Данные, База, Кэш);
	
	Возврат ТекстЗапроса;
	
КонецФункции

&НаСервере
Процедура ЗарегистрироватьДокументНаСервере()
	
	Если НЕ ЗначениеЗаполнено(ОтборДокумент) Тогда
		Возврат;
	КонецЕсли;	
	
	Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
	Запись.ИспользуемаяИБ        = База;
	Запись.НастройкаСоответствия = Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию("Реализация ОФУ");
	Запись.Элемент               = ОтборДокумент;
	
	Запись.Записать();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗарегистрироватьДокумент(Команда)
	ЗарегистрироватьДокументНаСервере();
КонецПроцедуры

