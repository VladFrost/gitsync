Перем ВерсияПлагина;
Перем Лог;
Перем Обработчик;

Перем ДополнительнаяТаблицаПереименования;
Перем ВыполнятьПереименование;
Перем КорневойКаталог;
Функция ОписаниеПлагина() Экспорт

	Возврат Новый Структура("Версия, Лог, ИмяПакета", ВерсияПлагина, Лог, ИмяПлагина())

КонецФункции // Информация() Экспорт

Процедура ПриАктивизацииПлагина(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;
	ДополнительнаяТаблицаПереименования.Очистить();
	ВыполнятьПереименование = Ложь;
	КорневойКаталог = "";
КонецПроцедуры


Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации, Парсер) Экспорт

	Лог.Отладка("Ищю команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);
	
	КлассРеализации.Опция("R rename-module", Ложь, "[*unpackForm] переименование module -> module.bsl").Флаг().ВОкружении("GITSYNC_RENAME_MODULE");
	

КонецПроцедуры

Процедура ПослеПеремещенияФайлаВКаталогРабочейКопии(Файл, НовыйФайл, СписокФайлов) Экспорт
	
	Если Нрег(Файл.Имя) = "form.bin" Тогда

		НовыйКаталог = Новый Файл(НовыйФайл.Путь);
		
		КаталогФормы = ОбъединитьПути(НовыйКаталог.ПолноеИмя, НовыйФайл.ИмяБезРасширения);
		СоздатьКаталог(КаталогФормы);
		РаспаковатьКонтейнерМетаданных(НовыйФайл.ПолноеИмя, КаталогФормы);
	КонецЕсли;

КонецПроцедуры



// хитрость: надо выносить в отдельную процедуру, 
// а сборку мусора делать в другом кадре стека вызовов.
// иначе сборка ничего не соберет
//
Процедура dllРаспаковать(Знач ФайлРаспаковки, Знач КаталогРаспаковки)
		
	Распаковщик = Новый ЧтениеФайла8(ФайлРаспаковки);
	Распаковщик.ИзвлечьВсе(КаталогРаспаковки, Истина);
	ОсвободитьОбъект(Распаковщик); // почему-то этого недостаточно. Вопрос к реализации компоненты.
	Распаковщик = Неопределено;
	
КонецПроцедуры

Процедура РаспаковатьКонтейнерМетаданных(Знач ФайлРаспаковки, Знач КаталогРаспаковки, Знач Переименования = "", Знач КорневойКаталог = "")

	СтандартнаяОбработка = Истина;

	Если СтандартнаяОбработка Тогда
		dllРаспаковать(ФайлРаспаковки, КаталогРаспаковки);
		ВыполнитьСборкуМусора(); // см. камент к процедуре dllРаспаковать
	КонецЕсли;

	Если ВыполнятьПереименование Тогда
		ПереименованиеModule(ФайлРаспаковки, КаталогРаспаковки)
	КонецЕсли;

КонецПроцедуры

Процедура ПриПеремещенииВКаталогРабочейКопии(КаталогРабочейКопии, КаталогВыгрузки, ТаблицаПереименования, ПутьКФайлуПереименования, СтандартнаяОбработка) Экспорт

	КорневойКаталог = КаталогРабочейКопии + ПолучитьРазделительПути();
	Лог.Отладка("Корневой каталог: %1", КорневойКаталог);
	
КонецПроцедуры

Процедура ПереименованиеModule(ФайлРаспаковки, КаталогРаспаковки) Экспорт

	Для Каждого ФайлМодуля Из НайтиФайлы(КаталогРаспаковки, "module", Истина) Цикл

		СтароеИмяФайла = ФайлМодуля.ПолноеИмя;
		НовоеИмяФайла = ОбъединитьПути(ФайлМодуля.Путь, "Module.bsl");
		
		Лог.Отладка("Конвертирую наименование файла <%1> --> <%2>", СтароеИмяФайла, НовоеИмяФайла);
		КопироватьФайл(СтароеИмяФайла, НовоеИмяФайла);
		УдалитьФайлы(СтароеИмяФайла);
		
		ДобавитьПереименование(
			СтрЗаменить(СтароеИмяФайла, КорневойКаталог, ""),
			СтрЗаменить(НовоеИмяФайла, КорневойКаталог, ""));

	КонецЦикла;

КонецПроцедуры

Процедура ПослеПеремещенияВКаталогРабочейКопии(КаталогРабочейКопии, КаталогВыгрузки, ТаблицаПереименования, ПутьКФайлуПереименования) Экспорт

	Для Каждого ЭлементСтроки Из ДополнительнаяТаблицаПереименования Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаПереименования.Добавить(),ЭлементСтроки)
	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьПереименование(Знач Источник, Знач Приемник)

	Приемник = СтрЗаменить(Приемник, "/", "\");
	Источник = СтрЗаменить(Источник, "/", "\");

	Если Не Источник = Приемник Тогда

		СтрокаПереименования = ДополнительнаяТаблицаПереименования.Добавить();
		СтрокаПереименования.Источник = Источник;
		СтрокаПереименования.Приемник = Приемник;
	
	КонецЕсли;

КонецПроцедуры

Функция ИмяПлагина()
	возврат "unpackForm";
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