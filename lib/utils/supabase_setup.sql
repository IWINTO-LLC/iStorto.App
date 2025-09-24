-- Create or replace function to handle user profile creation
CREATE OR REPLACE FUNCTION create_user_profile(
  user_id UUID,
  user_email TEXT,
  user_phone TEXT DEFAULT NULL,
  user_name TEXT DEFAULT NULL,
  user_username TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  -- Insert user data into users table
  INSERT INTO users (
    user_id,
    email,
    phone_number,
    name,
    username,
    is_active,
    email_verified,
    phone_verified,
    created_at,
    updated_at
  ) VALUES (
    user_id,
    user_email,
    user_phone,
    COALESCE(user_name, split_part(user_email, '@', 1)),
    COALESCE(user_username, split_part(user_email, '@', 1)),
    true,
    false,
    false,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    phone_number = EXCLUDED.phone_number,
    name = EXCLUDED.name,
    username = EXCLUDED.username,
    updated_at = NOW()
  RETURNING to_json(users.*) INTO result;
  
  RETURN result;
END;
$$;

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their own data
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = user_id);

-- Create policy for users to update their own data
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = user_id);

-- Create policy to allow user profile creation via function
CREATE POLICY "Enable user profile creation" ON users
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;
