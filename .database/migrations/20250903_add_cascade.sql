  -- Drop existing foreign key constraints
  ALTER TABLE results DROP CONSTRAINT results_session_id_fkey;
  ALTER TABLE results_answers DROP CONSTRAINT results_answers_results_id_fkey;
  ALTER TABLE feedback_sentiment DROP CONSTRAINT feedback_sentiment_results_answers_id_fkey;

  -- Add new foreign key constraints with CASCADE
  ALTER TABLE results
  ADD CONSTRAINT results_session_id_fkey
  FOREIGN KEY (session_id)
  REFERENCES sessions(session_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

  ALTER TABLE results_answers
  ADD CONSTRAINT results_answers_results_id_fkey
  FOREIGN KEY (results_id)
  REFERENCES results(results_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

  ALTER TABLE feedback_sentiment
  ADD CONSTRAINT feedback_sentiment_results_answers_id_fkey
  FOREIGN KEY (results_answers_id)
  REFERENCES results_answers(results_answers_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;