-- Учёт мотопомп ДЧС СКО: безопасное размещение в проекте ОПТП.
-- Не меняет таблицы optp_* и не использует общие app_admins / pump_state.
CREATE TABLE IF NOT EXISTS public.mp_pump_state (
  id integer PRIMARY KEY CHECK (id = 1),
  data jsonb NOT NULL DEFAULT '{"departments":[],"pumps":[]}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO public.mp_pump_state(id,data)
VALUES (1,'{"departments":[],"pumps":[]}'::jsonb)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.mp_admins (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
);
ALTER TABLE public.mp_pump_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mp_admins ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.mp_pump_state FROM anon, authenticated;
REVOKE ALL ON public.mp_admins FROM anon, authenticated;
GRANT SELECT ON public.mp_pump_state TO anon, authenticated;
GRANT UPDATE ON public.mp_pump_state TO authenticated;
GRANT SELECT ON public.mp_admins TO authenticated;

CREATE POLICY mp_read_pumps ON public.mp_pump_state
FOR SELECT TO anon,authenticated USING (true);
CREATE POLICY mp_admin_update_pumps ON public.mp_pump_state
FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.mp_admins WHERE user_id=(SELECT auth.uid())))
WITH CHECK (id=1 AND EXISTS (SELECT 1 FROM public.mp_admins WHERE user_id=(SELECT auth.uid())));
CREATE POLICY mp_read_own_admin ON public.mp_admins
FOR SELECT TO authenticated USING (user_id=(SELECT auth.uid()));

INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
VALUES ('mp-photos','mp-photos',true,5242880,ARRAY['image/jpeg'])
ON CONFLICT (id) DO NOTHING;
CREATE POLICY mp_public_photo_read ON storage.objects
FOR SELECT TO anon,authenticated USING (bucket_id='mp-photos');
CREATE POLICY mp_admin_photo_upload ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id='mp-photos' AND EXISTS
(SELECT 1 FROM public.mp_admins WHERE user_id=(SELECT auth.uid())));

-- Администратора назначим ОТДЕЛЬНО после создания/выбора пользователя в Authentication:
-- INSERT INTO public.mp_admins(user_id) VALUES ('UUID-ПОЛЬЗОВАТЕЛЯ') ON CONFLICT DO NOTHING;
