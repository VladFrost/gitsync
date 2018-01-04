
#Использовать logos
#Использовать gitrunner

Перем ВерсияПлагина;
Перем Лог;
Перем КомандыПлагина;

Перем Обработчик;
Перем СчетчикКоммитов;
Перем URLРепозитория;
Перем КоличествоКоммитовДоPush;
Перем ИмяВетки;
Перем ОтправлятьТеги;
Перем ГитРепозиторийСохр;
Перем РабочийКаталогСохр;

Перем КоличествоКоммитовДоPushКласс;
Перем ОтправлятьТегиКласс;

Функция ОписаниеПлагина() Экспорт

	Возврат Новый Структура("Версия, Лог, ИмяПакета", ВерсияПлагина, Лог, ИмяПлагина());

КонецФункции // Информация() Экспорт

Процедура ПриАктивизацииПлагина(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации, Парсер) Экспорт

	Лог.Отладка("Ищю команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);
	
	КлассРеализации.Опция("b branch", "master", "<имя ветки git>").ВОкружении("GITSYNC_BRANCH");
	КлассРеализации.Опция("P push", Ложь, "[*push] Флаг отправки установленных меток").Флаг().ВОкружении("GITSYNC_PUSH");
	КлассРеализации.Опция("G pull", Ложь, "[*push] Флаг отправки установленных меток").Флаг().ВОкружении("GITSYNC_PULL");
	КлассРеализации.Опция("T smart-tags", Ложь, "[*push] Флаг отправки установленных меток").Флаг().ВОкружении("GITSYNC_SMART_TAGS");
	КлассРеализации.Опция("n push-n-commits", 0, "[*push] <число> количество коммитов до промежуточной отправки на удаленный сервер").ТЧисло();
	
	КлассРеализации.Аргумент("URL", "", "Адрес удаленного репозитория GIT.").ВОкружении("GITSYNC_REPO_URL").Обязательный(Ложь);


КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды, ДополнительныеПараметры) Экспорт

	КоличествоКоммитовДоPush = КоличествоКоммитовДоPushКласс.Значение;
	ОтправлятьТеги = ОтправлятьТегиКласс.Значение;
	
	СчетчикКоммитов = 0;

	Если КоличествоКоммитовДоPush = Неопределено Тогда
		КоличествоКоммитовДоPush = 0;
	КонецЕсли;

	Если ОтправлятьТеги = Неопределено Тогда
		ОтправлятьТеги = Ложь;
	КонецЕсли;

	КоличествоКоммитовДоPush = Число(КоличествоКоммитовДоPush);

	Лог.Отладка("Установлено количество коммитов <%1> после, которых осущевствляется отправка", КоличествоКоммитовДоPush);
	Лог.Отладка("Установлен флаг оправки меток в значение <%1> выгрузки версий", ОтправлятьТеги);

КонецПроцедуры

Процедура ПередНачаломВыполнения(ПутьКХранилищу, КаталогРабочейКопии, URLРепозитория, ИмяВетки) Экспорт

	URLРепозитория = URLРепозитория;
	ИмяВетки = ИмяВетки;

КонецПроцедуры

Процедура ПередНачаломВыполнения(ПутьКХранилищу, КаталогРабочейКопии, URLРепозитория, ИмяВетки) Экспорт

	Лог.Информация("Получение изменений с удаленного узла (pull)");

	ГитРепозиторий = ПолучитьГитРепозиторий(КаталогРабочейКопии);
	ГитРепозиторий.Получить(URLРепозитория, ИмяВетки);

КонецПроцедуры

Процедура ПослеОкончанияВыполнения(ПутьКХранилищу, КаталогРабочейКопии, URLРепозитория, ИмяВетки) Экспорт

	Если СчетчикКоммитов = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ГитРепозиторий = ПолучитьГитРепозиторий(КаталогРабочейКопии);
	ВыполнитьGitPush(ГитРепозиторий, КаталогРабочейКопии, URLРепозитория, ИмяВетки);

КонецПроцедуры


Процедура ПослеКоммита(ГитРепозиторий, КаталогРабочейКопии) Экспорт

	СчетчикКоммитов = СчетчикКоммитов + 1;

	Если СчетчикКоммитов = КоличествоКоммитовДоPush Тогда

		ВыполнитьGitPush(ГитРепозиторий, КаталогРабочейКопии, URLРепозитория, ИмяВетки);
		СчетчикКоммитов = 0;

	КонецЕсли;

КонецПроцедуры


// Cтандартная процедура git push
//
Функция ВыполнитьGitPush(Знач ГитРепозиторий,Знач ЛокальныйРепозиторий, Знач УдаленныйРепозиторий, Знач ИмяВетки = Неопределено, Знач ОтправитьМетки = Ложь) Экспорт


	Лог.Информация("Отправляю изменения на удаленный url (push)");

	ГитРепозиторий.ВыполнитьКоманду(СтрРазделить("gc --auto", " "));
	Лог.Отладка(СтрШаблон("Вывод команды gc: %1", СокрЛП(ГитРепозиторий.ПолучитьВыводКоманды())));

	ПараметрыКомандыPush = Новый Массив;
	ПараметрыКомандыPush.Добавить("push -u");
	ПараметрыКомандыPush.Добавить(СтрЗаменить(УдаленныйРепозиторий, "%", "%%"));
	ПараметрыКомандыPush.Добавить("--all -v");

	ГитРепозиторий.ВыполнитьКоманду(ПараметрыКомандыPush);

	Если ОтправлятьТеги Тогда

		ПараметрыКомандыPush = Новый Массив;
		ПараметрыКомандыPush.Добавить("push -u");
		ПараметрыКомандыPush.Добавить(СтрЗаменить(УдаленныйРепозиторий, "%", "%%"));
		ПараметрыКомандыPush.Добавить("--tags");

		ГитРепозиторий.ВыполнитьКоманду(ПараметрыКомандыPush);

	КонецЕсли;

	Лог.Отладка(СтрШаблон("Вывод команды Push: %1", СокрЛП(ГитРепозиторий.ПолучитьВыводКоманды())));

КонецФункции

Функция ПолучитьГитРепозиторий(Знач КаталогРабочейКопии)

	ФайлКаталога = Новый Файл(ОбъединитьПути(ТекущийКаталог(), КаталогРабочейКопии));
	Если ФайлКаталога.ПолноеИмя = РабочийКаталогСохр Тогда
		ГитРепозиторий = ГитРепозиторийСохр;
	Иначе
		ГитРепозиторий = Новый ГитРепозиторий;
		ГитРепозиторий.УстановитьРабочийКаталог(КаталогРабочейКопии);
		ГитРепозиторий.УстановитьНастройку("core.quotepath", "false", РежимУстановкиНастроекGit.Локально);
		ГитРепозиторий.УстановитьНастройку("merge.ours.driver", "true", РежимУстановкиНастроекGit.Локально);

		РабочийКаталогСохр = ФайлКаталога.ПолноеИмя;
		ГитРепозиторийСохр = ГитРепозиторий;

	КонецЕсли;

	Возврат ГитРепозиторий;

КонецФункции // ПолучитьГитРепозиторий()

Функция ИмяПлагина()
	возврат "push";
КонецФункции // ИмяПлагина()

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync_plugins_"+ СтрЗаменить(ИмяПлагина(),"-", "_"));
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	КомандыПлагина.Добавить("export");

	URLРепозитория = Неопределено;
	ИмяВетки = "master";
	СчетчикКоммитов = 0;

КонецПроцедуры

Инициализация();