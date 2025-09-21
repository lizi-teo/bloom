-- Migration to fix session ordering in production
-- Run this in the Supabase SQL Editor

-- Step 1: Add a default value for created_at column
ALTER TABLE sessions 
ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP;

-- Step 2: Update sessions that have time as 00:00:00 to have proper timestamps
-- We'll spread them out by minutes based on their session_id to maintain order
UPDATE sessions 
SET created_at = 
  CASE 
    -- For sessions with precise timestamps (like the recent ones), keep them
    WHEN EXTRACT(hour FROM created_at) != 0 
      OR EXTRACT(minute FROM created_at) != 0 
      OR EXTRACT(second FROM created_at) != 0 
    THEN created_at
    -- For sessions with 00:00:00 time, create new timestamps
    -- maintaining their relative order by session_id
    -- Using a base time of noon and adding minutes based on session_id
    ELSE DATE(created_at) + 
         INTERVAL '12 hours' - 
         ((40 - session_id) * INTERVAL '10 minutes')
  END
WHERE created_at IS NOT NULL;

-- Step 3: Verify the fix
SELECT 
  session_id,
  session_name,
  created_at,
  template_id
FROM sessions
ORDER BY created_at DESC, session_id DESC
LIMIT 20;