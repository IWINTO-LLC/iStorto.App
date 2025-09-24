-- Option 1: Disable RLS temporarily (NOT RECOMMENDED for production)
-- ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Option 2: Create a more permissive policy for user creation
CREATE POLICY "Allow user profile creation" ON users
  FOR INSERT 
  WITH CHECK (true);

-- Option 3: Create policy that allows authenticated users to insert their own data
CREATE POLICY "Users can create own profile" ON users
  FOR INSERT 
  WITH CHECK (auth.uid()::text = user_id);

-- Option 4: Grant necessary permissions
GRANT INSERT, SELECT, UPDATE ON users TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Option 5: Create a trigger to automatically create user profile
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO users (user_id, email, name, username, is_active, email_verified, phone_verified)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    COALESCE(new.raw_user_meta_data->>'user_name', split_part(new.email, '@', 1)),
    true,
    new.email_confirmed_at IS NOT NULL,
    false
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();
