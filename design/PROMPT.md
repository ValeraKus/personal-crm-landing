Положи папку `context-landing-handoff` в корень нового репозитория (или рядом с ним) и вставь в Claude Code:

---

Сверстай статичный лендинг продукта Context по материалам в папке `context-landing-handoff/`.

1. Прочитай `context-landing-handoff/README.md` целиком — там стек, структура компонентов, спецификация блоков и критерии приёмки. Тексты бери только из `content.md`, токены — из `tokens/global.css`, иконки — из `assets/icons/`.
2. Посмотри скриншоты `screenshots/mobile-full.png` и `screenshots/desktop-full.png`; при сомнениях в размерах открой `reference/mobile.html` и `reference/desktop.html`.
3. Подними проект на Astro + Tailwind CSS 4 (команды в README), без клиентского JS. Ссылку кнопок вынеси в `PUBLIC_APP_URL`.
4. Собери компоненты `Window`, `PixelButton`, `PixelIcon`, `Tag`, затем секции по порядку: Hero → Problem → Solution → Benefits → FinalCta → Footer.
5. Проверь результат: `npm run build`, затем сделай скриншоты на 390 и 1440 px (Playwright) и сравни с эталонами; исправь расхождения. Проверь отсутствие горизонтального скролла на 360 px.
6. В конце кратко перечисли, что сделано и что отличается от макета.
