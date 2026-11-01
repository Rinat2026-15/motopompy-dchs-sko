УЧЁТ МОТОПОМП ДЧС СКО — ПОДКЛЮЧЕНИЕ К ПРОЕКТУ ОПТП

1. Таблицы mp_pump_state и mp_admins уже созданы пользователем в SQL Editor (Success).
2. Откройте github.com/rinat2026-15/motopompy-dchs-sko.
3. Замените в корне репозитория файлы index.html, config.js, manifest.webmanifest, service-worker.js и папку icons из этого архива; сохраните структуру.
4. Дождитесь публикации Pages и откройте https://rinat2026-15.github.io/motopompy-dchs-sko/.
5. В Supabase в Authentication > Users создайте администратора (Add user). Лучше использовать реальный email и сильный пароль. Учитывайте настройки подтверждения email.
6. Скопируйте User UID созданного пользователя (НЕ пароль).
7. В SQL Editor выполните команду ниже, заменив UUID на настоящий UID:

INSERT INTO public.mp_admins(user_id)
VALUES ('UUID_ПОЛЬЗОВАТЕЛЯ')
ON CONFLICT (user_id) DO NOTHING;

8. В приложении нажмите Администратор и войдите с email/паролем пользователя.
9. Добавьте тестовое подразделение и проверьте отображение на другом устройстве.

Важно: публичный publishable key безопасен только при корректных политиках RLS. Не помещайте в GitHub секретные ключи.
В существующих таблицах optp_* ничего менять не требуется.
