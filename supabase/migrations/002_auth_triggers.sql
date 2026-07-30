-- Auto-create account record when a new user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.accounts (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Allow users to insert their own account record
CREATE POLICY "account_insert" ON accounts
  FOR INSERT WITH CHECK (id = auth.uid());

-- Allow users to upsert their own account record
CREATE POLICY "account_update" ON accounts
  FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- Allow users to insert profiles linked to their account
CREATE POLICY "profile_insert" ON profiles
  FOR INSERT WITH CHECK (account_id = auth.uid());
