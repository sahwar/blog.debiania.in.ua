---
title: Управление дотфайлами в $HOME с помощью vcsh
tags: linux
language: russian
description: Описание надстройки над Git, позволяющей хранить свои дотфайлы
    в Git, не создавая при этом симлинков и вообще никак не вмешиваясь в сами
    дотфайлы.
---

Нынешнюю арку о надстройках над Git я хотел бы завершить рассказом о почти
неизвестной[^vcsh-popularity], но весьма крутой программе под названием vcsh.
Расшифровываться это имя [может по-разному][vcsh-lightning-talk], но мне больше
всего нравится «version control system for `$HOME`» — сразу становится понятно,
что программа предназначена для хранения дотфайлов в системе контроля версий.

Одну из причин, по которым вы можете захотеть хранить свои дотфайлы в СКВ, [я
уже приводил][one-reason] в начале этой мини-серии. Для полноты картины приведу
и вторую (наверное, есть куча дополнительных, но эти две я считаю наиболее
важными): благодаря контролю версий у вас появляется возможность
синхронизировать конфиги между разными машинами. Лично меня невероятно
раздражает, когда я посреди какой-то работы вдруг обнаруживаю, что программы
ведут себя не совсем так, как я привык, и всё из-за того, что на текущей машине
конфиги чуть старше, чем на предыдущей. Случается такое редко, но меня это
в итоге настолько достало, что я решился-таки положить свои конфиги под Git.

В результате появился репозиторий, представляющий из себя кучку дотфайлов
и скрипт, который создавал в `$HOME` симлинки. Это было не слишком удобно,
потому что в случае добавления в репозиторий нового дотфайла я должен был не
забыть на всех остальных машинах этот скрипт запустить. Кроме того, мне не
нравилось отсутствие тотальности: репозиторий знал только о тех конфигах,
о которых я позаботился ему сообщить. Если я ставил новую программу, конфиг
которой мне хотелось бы хранить в Git, я должен был не забыть его туда
добавить — сам по себе `git status` мне о нём не сообщал. В общем, пользоваться
этим способом можно, но удобств никаких.

vcsh же даёт гораздо менее костыльное и при этом более мощное решение. Он хранит
репозиторий (историю Git) в `.config/vcsh/repo.d`, а сами конфиги оставляет
лежать в домашней директории. Это гораздо лучше смотрится в выводе `ls`, чем
былое обилие симлинков. Это также даёт возможность разбивать ваши дотфайлы на
несколько наборов, каждый из которых хранится в отдельном репозитории
и клонируется независимо от других[^yes-just-like-symlinks]. Выделив свой
`.vimrc` в отдельный репозиторий, вы наконец-то сможете везде иметь одинаковую
среду редактирования текста, не таская при этом всякую мишуру вроде настроек
MPlayer и XScreenSaver (она теперь будет в отдельном репозитории).

Кроме того, vcsh рассматривает мой `$HOME` как свою рабочую директорию, так что
я получаю желанную «тотальность»: теперь `git status` будет сразу сообщать мне
обо всех незнакомых файлах (с учётом `.gitignore`, конечно). Ура, ура, ура!

<blockquote class="warning">

Сейчас мы будем делать что-то, что может повредить ваши данные. Советую закрыть
все приложения и сделать бекап дотфайлов, например, вот так: `tar cvjf
dotfiles.tbz2 ~/.*`

</blockquote>

От слов — к делу. Предварительно вернув `$HOME` к первозданному виду (чтобы
дотфайлы были файлами, а не симлинками на них), установим vcsh (в Squeeze
придётся подключить backports, в более новых релизах всё уже в main)
и инициализируем репозиторий:

    $ cd    # вся работа происходит непосредственно в $HOME
    $ sudo aptitude install vcsh
    $ vcsh init dotfiles

Теперь перейдём в специальный режим, где все вызовы git будут относиться
к свежесозданному репозиторию, и добавим в него несколько конфигов:

    $ vcsh enter dotfiles
    $ git add .vimrc .tmux.conf
    $ git commit -m'Initial commit'

Чтобы в выводе `git status` вам не мешали обычные файлы, советую добавить
в начало `.gitignore` вот такие строки:

    *       # ignore everything...
    !.*     # ...but dotfiles
    !.*/**  # ...and "dotdirs"

Думаю, из комментариев понятно, что именно они делают.

При желании ваш репозиторий можно опубликовать на GitHub (не забудьте
предварительно создать его через веб-интерфейс и поменять в команде ниже адрес
на тот, который вам сообщит сайт):

    $ git remote add origin 'git@github.com:Minoru/dotfiles.git'
    $ git push origin master:master
    $ git branch --track master origin/master

Выйти из режима, в который мы попали после `vcsh enter`, можно с помощью
`Ctrl-D`, `exit` или просто закрыв окно терминала.

Чтобы не забывать коммитить сделанные изменения, можно добавить в свой crontab
напоминалку, которая будет писать вам на локальное мыло (читается с помощью
`mail`):

    $ crontab -e
    # каждое утро рапортовать о локальных изменениях в репозитории dotfiles
    13 7 * * * vcsh dotfiles status --short

Точно так же можно организовать автоматические `push` и `pull`, но это останется
вам в качестве домашнего задания ☺

На этом обзор базовых возможностей можно считать завершённым. Обязательно
пролистайте `/usr/share/doc/vcsh/README.md.gz` — файл хоть и длинный, но
содержит хорошие описания команд и даст вам представление о том, что же умеет
vcsh. До новых встреч!

[^vcsh-popularity]: В феврале 2012-го в своём [докладе][vcsh-lightning-talk]
    Ричард Хартманн (Richard Hartmann), разработчик vcsh, сказал, что на данный
    момент у него десяток-два пользователей (смотрите видео с 09:32). Согласно
    Debian Popularity Contest, [на данный момент vcsh установило почти две
    с половиной сотни пользователей Debian][vcsh-popcon]. Сколько из них
    действительно пользуются программой, сказать сложно.

[vcsh-lightning-talk]: https://archive.fosdem.org/2012/schedule/event/vcsh "vcsh
    - manage config files in $HOME via fake bare git repositories"

[vcsh-popcon]: http://qa.debian.org/popcon.php?package=vcsh "Popularity contest
    statistics for vcsh"

[vcsh-repo]: https://github.com/RichiH/vcsh "GitHub / RichiH / vcsh"

[one-reason]: /posts/2013-12-14-one-reason-to-put-configs-into-vcs.html
    "Debiania — Одна причина хранить конфиги в системе контроля версий"

[^yes-just-like-symlinks]: Да, решение с симлинками тоже позволяет такое делать,
    но мороки в этом случае всё же больше.
