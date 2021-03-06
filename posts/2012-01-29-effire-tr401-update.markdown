---
title: Обновление Effire TR401
published: 2012-01-29T11:02:00Z
categories: 
tags: hardware,windows, howto
description: Рецепт по обновлению прошивки на читалке Effire TR401.
---

Двенадцатого января Effire выпустили обновление прошивки для <a href='http://effire.ru/catalogue/ebooks/colorbook_tr401/'>Colorbook TR401</a> — небольшого медиаридера, который мне как раз недавно подарили. Учитывая кривоватость стандартной прошивки, я немедленно приступил к обновлению.

Кстати говоря, впоследствии оказалось, что это не обновление вовсе, а та самая прошивка, которая была установлена на читалке при покупке. И этого поста вообще не было бы, если бы инструкция по обновлению, прилагаемая к прошивке, была работоспособна. Но увы…

Сразу замечу, что для обновления понадобилась настоящая Windows-машина — XPюшка, запущенная под QEMU, вывалилась в BSOD на одном из диалогов программы обновления. Запускать же LiveSuit (так называется обновлялка) под Wine я не пробовал ввиду отсутствия последнего в Debian Wheezy.
<a name='more'></a>
Собственно, основная проблема прилагаемой к прошивке инструкции заключается в том, что предлагается сначала поставить драйвер для устройства, а потом уже проводить обновление. Но на деле при подключении читалки к компьютеру она сразу же определяется как USB Mass Storage Device и Windows XP ни в какую не хочет менять драйвер на тот, что поставляет Effire.

Решается проблема элементарно: сначала запускаем LiveSuit, а потом уже подключаем ридер к компьютеру. Не знаю, что там делает запущенная обновлялка, но в такой последовательности устройство уже не считается флешкой и WinXP требует драйвера, которые мы и подсовываем в полном соответствии с инструкцией.

На всякий случай приведу пошаговое описание процесса обновления:

<ol><li>Бекапим книги, фильмы, музыку — всё, что жалко будет потерять, если вдруг что-то пойдёт не так. Учтите также, что настройки сбросятся в любом случае, так что запомните, что на какой странице читаете. И закладки из книг тоже на листочек выпишите.</li><li>Запускаем LiveSuit.</li><li>Подключаем читалку.</li><li>Windows определяет устройство и спрашивает про драйвера, скармливаем <code>usbdrv.inf</code> согласно инструкции, прилагаемой к прошивке.</li><li>Устройство переподключается и снова требует драйвер. Я на этом шаге снова подсунул мастеру установки <code>usbdrv.inf</code>, но уверен, что можно просто кликать <i>Далее</i> — драйвер-то мы поставили на предыдущем шаге.</li><li>Нажимаем SysUpdate.</li><li><b>Важно</b>: в появившемся диалоге нужно нажать <i>Да</i>, иначе процесс обновления прекратится с ошибкой «Jump to update mode failed». О данных не волнуйтесь — про них ещё раз спросят позже.</li><li>Спустя некоторое время появится диалог с вопросом о том, хотите ли вы форматировать внутреннюю память устройства. Вот это уже возможность потерять данные, так что хорошенько подумайте и отвечайте <i>Нет</i> ☺</li><li>Спустя некоторое время появилтся сообщение «Update success!» — поздравляю, всё прошло хорошо.</li><li>Как и написано в инструкции, книга загрузится, попросит подождать, после чего предложит откалибровать экран.</li><li>По завершении этих нехитрых манипуляций можете приступать к восстановлению своих настроек.</li></ol>

На этом всё. До новых встреч!
