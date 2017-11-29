﻿// При расчете по формулам показатели прошлых отчетов не 
// подтягиваются. Только после формирования расшифровки
Процедура РассчитатьСкладТрейдИн(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// ТрейдИн
	СкладТрейдИн_План      = ДокументОбъект.ЗначениеПоказателя("СкладТрейдИн_План",,,,, ПредПериод);
	ПриемТрейдИн_План      = ДокументОбъект.ЗначениеПоказателя("ПриемТрейдИн_План",,,,, ПредПериод);
	РеализацияТрейдИн_План = ДокументОбъект.ЗначениеПоказателя("РеализацияТрейдИн_План",,,,, ПредПериод);
	
	ДокументОбъект.Показатели.СкладТрейдИн_План = СкладТрейдИн_План + ПриемТрейдИн_План - РеализацияТрейдИн_План; 
	
КонецПроцедуры	

Процедура РассчитатьСкладКомиссия(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// Комиссия
	СкладКомиссия_План      = ДокументОбъект.ЗначениеПоказателя("СкладКомиссия_План",,,,, ПредПериод);
	ПриемКомиссия_План      = ДокументОбъект.ЗначениеПоказателя("ПриемКомиссия_План",,,,, ПредПериод);
	РеализацияКомиссия_План = ДокументОбъект.ЗначениеПоказателя("РеализацияКомиссия_План",,,,, ПредПериод);

	ДокументОбъект.Показатели.СкладКомиссия_План = СкладКомиссия_План + ПриемКомиссия_План - РеализацияКомиссия_План; 
	
КонецПроцедуры	

Процедура РассчитатьСкладБУнаБУ(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// БУнаБУ
	СкладБУнаБУ_План      = ДокументОбъект.ЗначениеПоказателя("СкладБУнаБУ_План",,,,, ПредПериод);
	ПриемБУнаБУ_План      = ДокументОбъект.ЗначениеПоказателя("ПриемБУнаБУ_План",,,,, ПредПериод);
	РеализацияБУнаБУ_План = ДокументОбъект.ЗначениеПоказателя("РеализацияБУнаБУ_План",,,,, ПредПериод);

	ДокументОбъект.Показатели.СкладБУнаБУ_План = СкладБУнаБУ_План + ПриемБУнаБУ_План - РеализацияБУнаБУ_План; 
	
КонецПроцедуры	

Процедура РассчитатьСкладВыкупФизЛица(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// ВыкупФизЛица
	СкладВыкупФизЛица_План      = ДокументОбъект.ЗначениеПоказателя("СкладВыкупФизЛица_План",,,,, ПредПериод);
	ПриемВыкупФизЛица_План      = ДокументОбъект.ЗначениеПоказателя("ПриемВыкупФизЛица_План",,,,, ПредПериод);
	РеализацияВыкупФизЛица_План = ДокументОбъект.ЗначениеПоказателя("РеализацияВыкупФизЛица_План",,,,, ПредПериод);

	ДокументОбъект.Показатели.СкладВыкупФизЛица_План = СкладВыкупФизЛица_План + ПриемВыкупФизЛица_План - РеализацияВыкупФизЛица_План; 
	
КонецПроцедуры	

Процедура РассчитатьСкладВыкупЮрЛица(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// ВыкупЮрЛица
	СкладВыкупЮрЛица_План      = ДокументОбъект.ЗначениеПоказателя("СкладВыкупЮрЛица_План",,,,, ПредПериод);
	ПриемВыкупЮрЛица_План      = ДокументОбъект.ЗначениеПоказателя("ПриемВыкупЮрЛица_План",,,,, ПредПериод);
	РеализацияВыкупЮрЛица_План = ДокументОбъект.ЗначениеПоказателя("РеализацияВыкупЮрЛица_План",,,,, ПредПериод);

	ДокументОбъект.Показатели.СкладВыкупЮрЛица_План = СкладВыкупЮрЛица_План + ПриемВыкупЮрЛица_План - РеализацияВыкупЮрЛица_План; 
	
КонецПроцедуры	

Процедура РассчитатьСкладВыкупИмпортер(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// ВыкупИмпортер
	СкладВыкупИмпортер_План      = ДокументОбъект.ЗначениеПоказателя("СкладВыкупИмпортер_План",,,,, ПредПериод);
	ПриемВыкупИмпортер_План      = ДокументОбъект.ЗначениеПоказателя("ПриемВыкупИмпортер_План",,,,, ПредПериод);
	РеализацияВыкупИмпортер_План = ДокументОбъект.ЗначениеПоказателя("РеализацияВыкупИмпортер_План",,,,, ПредПериод);

	ДокументОбъект.Показатели.СкладВыкупИмпортер_План = СкладВыкупИмпортер_План + ПриемВыкупИмпортер_План - РеализацияВыкупИмпортер_План; 
	
КонецПроцедуры	

Процедура РассчитатьСкладПодмИТестовые(ДокументОбъект) Экспорт
	
	Если Ложь Тогда
		ДокументОбъект = Документы.НастраиваемыйОтчет.СоздатьДокумент();
	КонецЕсли;	
	
	Если Месяц(ДокументОбъект.ПериодОтчета.ДатаНачала) = 1 Тогда
		Возврат;
	КонецЕсли;
	
	ПредПериод = ДокументОбъект.ОтносительныйПериод(ДокументОбъект.ПериодОтчета, -1);

	// ПодмИТестовые
	СкладПодмИТестовые_План      = ДокументОбъект.ЗначениеПоказателя("СкладПодмИТестовые_План",,,,, ПредПериод);
	ПриемПодмИТестовые_План      = ДокументОбъект.ЗначениеПоказателя("ПриемПодмИТестовые_План",,,,, ПредПериод);
	РеализацияПодмИТестовые_План = ДокументОбъект.ЗначениеПоказателя("РеализацияПодмИТестовые_План",,,,, ПредПериод);

	ДокументОбъект.Показатели.СкладПодмИТестовые_План = СкладПодмИТестовые_План + ПриемПодмИТестовые_План - РеализацияПодмИТестовые_План; 
	
КонецПроцедуры	

