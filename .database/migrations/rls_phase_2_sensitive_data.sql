-- Row Level Security Implementation - Phase 2: Sensitive Data Tables
-- Execute this SQL in Supabase SQL Editor
-- Target: feedback_sentiment, session_sentiment_summary tables

-- ============================================================================
-- PHASE 2: SENSITIVE DATA TABLES RLS IMPLEMENTATION
-- ============================================================================

-- 1. FEEDBACK_SENTIMENT TABLE
-- Sentiment data should only be accessible through results_answers ownership chain
-- ============================================================================

-- Enable RLS
ALTER TABLE public.feedback_sentiment ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "feedback_sentiment_select_via_chain" ON public.feedback_sentiment;
DROP POLICY IF EXISTS "feedback_sentiment_update_via_chain" ON public.feedback_sentiment;
DROP POLICY IF EXISTS "feedback_sentiment_insert_via_chain" ON public.feedback_sentiment;
DROP POLICY IF EXISTS "feedback_sentiment_delete_via_chain" ON public.feedback_sentiment;

-- Policy: Select feedback_sentiment through results_answers -> results -> session ownership chain
CREATE POLICY "feedback_sentiment_select_via_chain" ON public.feedback_sentiment
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.results_answers
            JOIN public.results ON results.results_id = results_answers.results_id
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results_answers.results_answers_id = feedback_sentiment.results_answers_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Update feedback_sentiment through ownership chain
CREATE POLICY "feedback_sentiment_update_via_chain" ON public.feedback_sentiment
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.results_answers
            JOIN public.results ON results.results_id = results_answers.results_id
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results_answers.results_answers_id = feedback_sentiment.results_answers_id
            AND sessions.facilitator_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.results_answers
            JOIN public.results ON results.results_id = results_answers.results_id
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results_answers.results_answers_id = feedback_sentiment.results_answers_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Insert feedback_sentiment through ownership chain
CREATE POLICY "feedback_sentiment_insert_via_chain" ON public.feedback_sentiment
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.results_answers
            JOIN public.results ON results.results_id = results_answers.results_id
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results_answers.results_answers_id = feedback_sentiment.results_answers_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Delete feedback_sentiment through ownership chain
CREATE POLICY "feedback_sentiment_delete_via_chain" ON public.feedback_sentiment
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.results_answers
            JOIN public.results ON results.results_id = results_answers.results_id
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results_answers.results_answers_id = feedback_sentiment.results_answers_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- ============================================================================
-- 2. SESSION_SENTIMENT_SUMMARY TABLE
-- Session summaries should only be accessible by session facilitators
-- ============================================================================

-- Enable RLS
ALTER TABLE public.session_sentiment_summary ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "session_sentiment_summary_select_facilitator" ON public.session_sentiment_summary;
DROP POLICY IF EXISTS "session_sentiment_summary_update_facilitator" ON public.session_sentiment_summary;
DROP POLICY IF EXISTS "session_sentiment_summary_insert_facilitator" ON public.session_sentiment_summary;
DROP POLICY IF EXISTS "session_sentiment_summary_delete_facilitator" ON public.session_sentiment_summary;

-- Policy: Select session sentiment summaries through session facilitator ownership
CREATE POLICY "session_sentiment_summary_select_facilitator" ON public.session_sentiment_summary
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = session_sentiment_summary.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Update session sentiment summaries through session facilitator ownership
CREATE POLICY "session_sentiment_summary_update_facilitator" ON public.session_sentiment_summary
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = session_sentiment_summary.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = session_sentiment_summary.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Insert session sentiment summaries through session facilitator ownership
CREATE POLICY "session_sentiment_summary_insert_facilitator" ON public.session_sentiment_summary
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = session_sentiment_summary.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Delete session sentiment summaries through session facilitator ownership
CREATE POLICY "session_sentiment_summary_delete_facilitator" ON public.session_sentiment_summary
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = session_sentiment_summary.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these queries to verify the policies are working correctly:

-- 1. Check RLS is enabled on both tables
-- SELECT schemaname, tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('feedback_sentiment', 'session_sentiment_summary');

-- 2. List all policies created
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('feedback_sentiment', 'session_sentiment_summary')
-- ORDER BY tablename, policyname;

-- 3. Test ownership chain (replace with actual session_id owned by current user)
-- SELECT COUNT(*) as sentiment_count
-- FROM public.feedback_sentiment fs
-- JOIN public.results_answers ra ON ra.results_answers_id = fs.results_answers_id
-- JOIN public.results r ON r.results_id = ra.results_id
-- JOIN public.sessions s ON s.session_id = r.session_id
-- WHERE s.facilitator_id = auth.uid();

-- ============================================================================
-- ROLLBACK COMMANDS (if needed)
-- ============================================================================

-- Uncomment and run these if you need to rollback the changes:

-- -- Disable RLS on both tables
-- -- ALTER TABLE public.feedback_sentiment DISABLE ROW LEVEL SECURITY;
-- -- ALTER TABLE public.session_sentiment_summary DISABLE ROW LEVEL SECURITY;

-- -- Drop all policies
-- -- DROP POLICY IF EXISTS "feedback_sentiment_select_via_chain" ON public.feedback_sentiment;
-- -- DROP POLICY IF EXISTS "feedback_sentiment_update_via_chain" ON public.feedback_sentiment;
-- -- DROP POLICY IF EXISTS "feedback_sentiment_insert_via_chain" ON public.feedback_sentiment;
-- -- DROP POLICY IF EXISTS "feedback_sentiment_delete_via_chain" ON public.feedback_sentiment;
-- -- DROP POLICY IF EXISTS "session_sentiment_summary_select_facilitator" ON public.session_sentiment_summary;
-- -- DROP POLICY IF EXISTS "session_sentiment_summary_update_facilitator" ON public.session_sentiment_summary;
-- -- DROP POLICY IF EXISTS "session_sentiment_summary_insert_facilitator" ON public.session_sentiment_summary;
-- -- DROP POLICY IF EXISTS "session_sentiment_summary_delete_facilitator" ON public.session_sentiment_summary;