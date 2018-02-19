﻿#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Истина;
	ПараметрыРегистрации.Информация = Метаданные().Представление();
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление();
	НоваяКоманда.Идентификатор = Метаданные().Имя;
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	НоваяКоманда.ПоказыватьОповещение = Ложь;

	Возврат ПараметрыРегистрации;

КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды = Неопределено) Экспорт 
	
	ОтложенноеПроведениеДокументов();
	
КонецПроцедуры	

#КонецОбласти

Функция ОтложенноеПроведениеДокументов() Экспорт
	
	// Для предотвращения повторного запуска процедуры
	СпрОбъект = Справочники.ВидыВычетовНДФЛ.Код103.ПолучитьОбъект();
	
	Если СпрОбъект.Заблокирован() Тогда
		Возврат Ложь;
	Иначе
		СпрОбъект.Заблокировать();
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Рег.УзелОбмена КАК УзелОбмена,
	|	Рег.Документ КАК Документ,
	|	Рег.ДатаДокумента КАК ДатаДокумента,
	|	Рег.КоличествоНеудачныхПроведений КАК КоличествоНеудачныхПроведений
	|ИЗ
	|	РегистрСведений.ОтложенныеДвиженияДокументов КАК Рег
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаДокумента, Документ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		ТекстОшибки = "";
		
		Попытка
			ДокументОбъект = Выборка.Документ.ПолучитьОбъект();
			ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
		Исключение
			ТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;	
		
		Запись = РегистрыСведений.ОтложенныеДвиженияДокументов.СоздатьМенеджерЗаписи();
		Запись.УзелОбмена = Выборка.УзелОбмена;
		Запись.Документ   = Выборка.Документ;
		
		Если НЕ ЗначениеЗаполнено(ТекстОшибки) Тогда
			Запись.Удалить();	
		Иначе	
			Запись.КоличествоНеудачныхПроведений = Выборка.КоличествоНеудачныхПроведений + 1;
			Запись.СообщениеОбОшибкеПроведения   = ТекстОшибки;
			Запись.Записать();	
		КонецЕсли;	
		
	КонецЦикла;	
	
	СпрОбъект.Разблокировать();
	Возврат Истина;
	
КонецФункции	