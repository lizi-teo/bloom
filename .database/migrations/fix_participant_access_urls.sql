-- Fix participant_access_url to store only path parts instead of full URLs
-- This allows the Flutter app to construct environment-specific URLs dynamically

UPDATE sessions 
SET participant_access_url = CASE 
  WHEN participant_access_url LIKE 'https://bloom-e0901.web.app%' THEN 
    SUBSTRING(participant_access_url FROM 'https://bloom-e0901\.web\.app(.*)$')
  WHEN participant_access_url LIKE 'https://localhost:8080%' THEN 
    SUBSTRING(participant_access_url FROM 'https://localhost:8080(.*)$')
  ELSE participant_access_url 
END
WHERE participant_access_url IS NOT NULL
  AND (participant_access_url LIKE 'https://bloom-e0901.web.app%' 
       OR participant_access_url LIKE 'https://localhost:8080%');

-- Verify the changes
SELECT session_id, session_name, session_code, participant_access_url 
FROM sessions 
WHERE participant_access_url IS NOT NULL;