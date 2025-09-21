-- Add participant_count column to sessions table
ALTER TABLE sessions 
ADD COLUMN participant_count INTEGER DEFAULT NULL;

-- Add a comment to explain the column
COMMENT ON COLUMN sessions.participant_count IS 'Expected number of participants for this session, used to calculate response rates';

-- Optional: Set some example values for existing sessions
-- UPDATE sessions SET participant_count = 10 WHERE session_id IN (88, 89, 90);