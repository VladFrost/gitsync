
Перем ВерсияПлагина;
Перем Лог;
Перем Обработчик;
Перем ПоследняяВерсияКонфигурации;
Перем ТекущаяВерсияКонфигурации;

Функция ОписаниеПлагина() Экспорт

	Возврат Новый Структура("Версия, Лог, ИмяПакета", ВерсияПлагина, Лог, ИмяПлагина())

КонецФункции // Информация() Экспорт

Процедура ПриАктивизацииПлагина(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;
	ПоследняяВерсияКонфигурации = "";
	ТекущаяВерсияКонфигурации = "";

КонецПроцедуры

Процедура ПриПолученииТаблицыВерсий(ТаблицаВерсий, ПутьКХранилищу, СтандартнаяОбработка);
	
	Если СтандартнаяОбработка Тогда
		
		ТаблицаВерсий.Очистить();

		СтандартнаяОбработка = Ложь;

		ФайлХранилища = ПолучитьПутьКБазеДанныхХранилища(ПутьКХранилищу);
		Лог.Отладка("Файл хранилища конфигурации: " + ФайлХранилища);

		ЧтениеБазыДанных = Новый ЧтениеТаблицФайловойБазыДанных;
		ЧтениеБазыДанных.ОткрытьФайл(ФайлХранилища);
		Попытка
			ТаблицаБД = ЧтениеБазыДанных.ПрочитатьТаблицу("VERSIONS");
		Исключение
			ЧтениеБазыДанных.ЗакрытьФайл();
			ВызватьИсключение;
		КонецПопытки;

		ЧтениеБазыДанных.ЗакрытьФайл();

		ТаблицаВерсий = КонвертироватьТаблицуВерсийИзФорматаБД(ТаблицаВерсий, ТаблицаБД);
		ТаблицаВерсий.Сортировать("НомерВерсии");
	
	КонецЕсли;

КонецПроцедуры

// Считывает таблицу USERS пользователей хранилища
//
Процедура ПриПолученииТаблицыПользователей(ТаблицаПользователей, ПутьКХранилищу, СтандартнаяОбработка) Экспорт


	Если СтандартнаяОбработка Тогда

		СтандартнаяОбработка = Ложь;
		ТаблицаПользователей.Очистить();

		ФайлХранилища = ПолучитьПутьКБазеДанныхХранилища(ПутьКХранилищу);
		Лог.Отладка("Файл хранилища конфигурации: " + ФайлХранилища);

		ЧтениеБазыДанных = Новый ЧтениеТаблицФайловойБазыДанных;
		ЧтениеБазыДанных.ОткрытьФайл(ФайлХранилища);
		Попытка
			ТаблицаБД = ЧтениеБазыДанных.ПрочитатьТаблицу("USERS");
		Исключение
			ЧтениеБазыДанных.ЗакрытьФайл();
			ВызватьИсключение;
		КонецПопытки;

		ЧтениеБазыДанных.ЗакрытьФайл();
		ТаблицаПользователей = КонвертироватьТаблицуПользователейИзФорматаБД(ТаблицаПользователей, ТаблицаБД);

	КонеЦесли;

КонецПроцедуры

Функция КонвертироватьТаблицуВерсийИзФорматаБД(Знач ТаблицаВерсий, Знач ТаблицаБД)

	Для Каждого СтрокаБД Из ТаблицаБД Цикл

		Если СтрокаБД.VERDATE = "0000-00-00T00:00:00" Тогда
			Продолжить;
		КонецЕсли;

		НоваяСтрока = ТаблицаВерсий.Добавить();
		НоваяСтрока.НомерВерсии = Число(СтрокаБД.VERNUM);
		НоваяСтрока.ГУИД_Автора = СтрокаБД.USERID;
		НоваяСтрока.Тэг = СтрокаБД.CODE;

		Дата = СтрЗаменить(СтрЗаменить(СтрокаБД.VERDATE, "-", ""), ":", "");
		Дата = СтрЗаменить(Дата, "T", "");
		Дата = Дата(Дата);
		НоваяСтрока.Дата = Дата;
		НоваяСтрока.Комментарий = СтрокаБД.COMMENT;

	КонецЦикла;

	Возврат ТаблицаВерсий;
КонецФункции

Функция КонвертироватьТаблицуПользователейИзФорматаБД(Знач ТаблицаПользователей, Знач ТаблицаБД)
	
	Для Каждого СтрокаБД Из ТаблицаБД Цикл

		НоваяСтрока = ТаблицаПользователей.Добавить();
		НоваяСтрока.Автор       = СтрокаБД.NAME;
		НоваяСтрока.ГУИД_Автора = СтрокаБД.USERID;

	КонецЦикла;

	Возврат ТаблицаПользователей;

КонецФункции

Функция ПолучитьПутьКБазеДанныхХранилища(Знач ПутьКХранилищу)
	
	ФайлПутиКХранилищу = Новый Файл(ПутьКХранилищу);
	Если ФайлПутиКХранилищу.Существует() и ФайлПутиКХранилищу.ЭтоКаталог() Тогда
		
		ФайлБазыДанныхХранилища = ОбъединитьПути(ФайлПутиКХранилищу.ПолноеИмя, "1cv8ddb.1CD");

	ИначеЕсли ФайлПутиКХранилищу.Существует() Тогда
	
		ФайлБазыДанныхХранилища = ФайлПутиКХранилищу.ПолноеИмя;

	Иначе
	
		ВызватьИсключение "Некорректный путь к хранилищу: " + ФайлПутиКХранилищу.ПолноеИмя;
	
	КонецЕсли;

	Возврат ФайлБазыДанныхХранилища;

КонецФункции // ПолучитьПутьКБазеДанныхХранилища

Процедура ПоНомеруВерсииСохранитьКонфигурациюСредствамиTool1CD(Знач ПутьКФайлуХранилища1С, Знач ВыходнойФайл, Знач НомерВерсииХранилища)

	Логирование.ПолучитьЛог("oscript.lib.tool1cd").УстановитьУровень(Лог.Уровень());
	Лог.Отладка("Получаем файл версии <"+НомерВерсииХранилища+"> из хранилища: " + ПутьКФайлуХранилища1С);
	ЧтениеХранилища = Новый ЧтениеХранилищаКонфигурации;
	ЧтениеХранилища.ВыгрузитьВерсиюКонфигурации(ПутьКФайлуХранилища1С, ВыходнойФайл, НомерВерсииХранилища);
	Лог.Отладка("Версия хранилища выгружена");

КонецПроцедуры

Процедура ПриЗагрузкеВерсииХранилищаВКонфигурацию(Конфигуратор, КаталогРабочейКопии, ПутьКХранилищу, НомерВерсии, СтандартнаяОбработка) Экспорт
		
	Если СтандартнаяОбработка Тогда
		
		СтандартнаяОбработка = Ложь;
		ФайлХранилища = Новый Файл(ПолучитьПутьКБазеДанныхХранилища(ПутьКХранилищу));

		Если ФайлХранилища.Существует() И ФайлХранилища.ЭтоФайл() И ВРег(ФайлХранилища.Расширение) = ".1CD" Тогда
			ВремКаталог = ВременныеФайлы.СоздатьКаталог();
			ФайлВерсии  = ИмяФайлаВыгрузкиВерсииХранилища(ВремКаталог, НомерВерсии);
			Лог.Отладка("Выгружаем версию хранилища в файл " + ФайлВерсии);
			
			// Получение cf
			ПоНомеруВерсииСохранитьКонфигурациюСредствамиTool1CD(ФайлХранилища.ПолноеИмя, ФайлВерсии, НомерВерсии);
			
			КоличествоЦикловОжиданияЛицензии = ПолучитьКоличествоЦикловОжиданияЛицензииПоУмолчанию();
			
			Пока КоличествоЦикловОжиданияЛицензии >= 0 Цикл
				Попытка
					
					Конфигуратор.ЗагрузитьКонфигурациюИзФайла(ФайлВерсии, Ложь);
					Прервать;
		
				Исключение
					
					// проверим текст ошибки, если текст содержит информацию о необходимости конвертировать
					// тогда выполним конвертацию и повторно попытаемся загрузить файл
					ТекстОшибки = ВРег(Конфигуратор.ВыводКоманды());
					Если Найти(ТекстОшибки, Врег("Структура конфигурации несовместима с текущей версией программы")) Тогда
						
						Конфигуратор.СконвертироватьФайлКонфигурации(ФайлВерсии);
						Конфигуратор.ЗагрузитьКонфигурациюИзФайла(ФайлВерсии, Ложь);
						Прервать;
						
					ИначеЕсли Найти(ТекстОшибки, Врег("Не обнаружено свободной лицензии!")) Тогда
						Лог.Ошибка(ТекстОшибки);
						Лог.Информация("Повторное подключение через 10сек. Осталось попыток: " + КоличествоЦикловОжиданияЛицензии);
						Приостановить(10000);
		
					Иначе
						
						ВызватьИсключение ТекстОшибки;
						
					КонецЕсли;
					
				КонецПопытки;
		
				Если ПолучитьКоличествоЦикловОжиданияЛицензииПоУмолчанию() <> 0 Тогда
					КоличествоЦикловОжиданияЛицензии = КоличествоЦикловОжиданияЛицензии - 1;
				КонецЕсли;
				
			КонецЦикла;

			УдалитьВременныеФайлыПриНеобходимости(ВремКаталог);
		Иначе
			ВызватьИсключение "Что-то пошло не так "
		КонецЕсли

	КонецЕсли;

	Плагины.ПослеЗагрузкиВерсииХранилищаВКонфигурацию(Конфигуратор, КаталогРабочейКопии, ПутьКХранилищу, НомерВерсии);

КонецПроцедуры

Функция ИмяПлагина()
	возврат "tool1CD";
КонецФункции // ИмяПлагина()

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync_plugins_"+ СтрЗаменить(ИмяПлагина(),"-", "_"));
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	КомандыПлагина.Добавить("export");
	КомандыПлагина.Добавить("clone");
	КомандыПлагина.Добавить("init");
	мАвторизацияВХранилищеСредствами1С = Новый Структура("ПользовательХранилища, ПарольХранилища");

КонецПроцедуры

Инициализация();