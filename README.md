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

Пока не настроена. План — в `CLAUDE.md`: push в main → GitHub Actions собирает `dist/` → rsync на сервер.
