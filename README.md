# Лендинг Context

Одна статичная страница. Цель — перевести человека в приложение (кнопки «Начать бесплатно»).

Стек: Astro, Tailwind CSS 4. Клиентского JavaScript нет.

## Как запустить у себя

Нужны Node.js 22.22+ и pnpm.

```bash
pnpm install       # один раз
pnpm dev           # страница с автообновлением: http://localhost:4321
```

Проверить готовую сборку:

```bash
pnpm build         # собирает страницу в папку dist/
pnpm preview       # показывает dist/ на http://localhost:4321
```

## Куда ведут кнопки

Все три кнопки ведут на `https://app.context-crm.site`. Адрес задан в `src/config.ts`.
Чтобы при сборке подставить другой адрес, задайте переменную `PUBLIC_APP_URL` (пример — в `.env.example`).

## Где что лежит

- `design/` — макет: эталонные скриншоты, HTML и тексты
- `src/styles/tokens.css` — дизайн-токены: цвета, шрифты, размеры текста, тени
- `src/components/sections/` — блоки страницы сверху вниз: Hero, Problem, Solution, Benefits, FinalCta
- `src/icons/` — пиксельные иконки, `public/fonts/` — шрифты

## Выкатка

Лендинг работает на сервере `62.109.29.244` по адресу <https://context-crm.site>. Выкатывается сам при каждом push в `main`.

### Как выкатить новую версию

1. Закоммить изменения и сделай push в `main`
2. Посмотри, как идёт выкатка: на GitHub вкладка **Actions** → **Deploy**, или в терминале `gh run watch`. Обычно она занимает 1–2 минуты
3. Зелёная галочка — новая версия на сайте. Красный крестик — выкатка упала: открой упавший шаг, в последних строках написано, что пошло не так. Исправь и сделай новый push
4. Проверь: открой <https://context-crm.site> и обнови страницу

Отката нет: если что-то сломалось, правим и катим новую версию.

### Что происходит при выкатке

`.github/workflows/deploy.yml` на GitHub Actions:

1. Собирает страницу: `pnpm install` и `pnpm build` — получается папка `dist/`
2. Копирует `dist/` на сервер в `/var/www/context-crm.site` через `rsync --delete`: файлы, которых больше нет в `dist/`, удаляются с сервера
3. Проверяет главную <https://context-crm.site>: должна ответить 200 и отдать именно ту страницу, которую только что собрали

### Что настроено один раз

- На сервере: пользователь `landing` (без sudo и без Docker), папка `/var/www/context-crm.site`, nginx отдаёт её по адресу context-crm.site. Ключ GitHub может только загружать файлы в эту папку — ни команд, ни чтения, ни других папок. Всё это делает `deploy/setup-server.sh`, настройка nginx — `deploy/nginx/context-crm.site.conf`
- В настройках репозитория на GitHub (**Settings** → **Secrets and variables** → **Actions**): секрет `DEPLOY_SSH_KEY` — ключ, которым GitHub заходит на сервер как `landing`, и переменные `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_KNOWN_HOSTS` — адрес сервера, пользователь и отпечаток сервера

Настройка nginx сама на сервер не выкатывается: поменял `deploy/nginx/` — её ставят на сервер, запустив `deploy/setup-server.sh` от root. Скрипт можно запускать повторно: он только добавляет недостающее, а прежнюю настройку nginx сохраняет копией `.bak-...`. Если новая настройка с ошибкой, nginx не перезагружается и прежняя возвращается на место.

Как обновить настройку nginx на сервере — из папки репозитория; `crm` — сервер из `~/.ssh/config`, пользователь с sudo; ключ GitHub при повторном запуске не нужен:

```bash
dir=$(ssh crm 'mktemp -d') && scp -r deploy/. "crm:$dir/" && ssh -t crm "sudo bash $dir/setup-server.sh; rm -rf $dir"
```

### Заголовки безопасности

nginx отдаёт с каждым ответом лендинга (настройка — `deploy/nginx/context-crm.site.conf`):

- `Strict-Transport-Security` — браузер ходит на сайт только по HTTPS. Задан в общем с приложением файле `/etc/nginx/snippets/context-crm-ssl.conf` на сервере
- `Content-Security-Policy` — страница грузит скрипты, стили, шрифты и картинки только с самого сайта; встроенные скрипты и стили разрешены
- `X-Frame-Options: DENY` и `frame-ancestors 'none'` в CSP — ни один сайт не может показать лендинг внутри своей страницы
- `Referrer-Policy` — при переходе на другой сайт тот узнаёт только адрес сайта, без пути
- `X-Content-Type-Options: nosniff` — браузер не угадывает тип файла
- `Permissions-Policy` — странице закрыты камера, микрофон, геолокация, оплата и USB
- `Server: nginx` без номера версии (`server_tokens off`)

Как проверить: `curl -I https://context-crm.site` — заголовки в ответе. Или в Chrome: DevTools → Network → документ → Headers; на вкладке Console не должно быть ошибок «Content Security Policy».

Если на страницу добавится что-то с другого сайта (шрифт, картинка, счётчик), CSP это заблокирует: адрес нужно добавить в `Content-Security-Policy` и обновить настройку nginx на сервере.
