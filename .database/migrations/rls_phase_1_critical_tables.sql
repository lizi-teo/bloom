-- Row Level Security Implementation - Phase 1: Critical Tables
-- Execute this SQL in Supabase SQL Editor
-- Target: users, sessions (verify), results, results_answers tables

-- ============================================================================
-- PHASE 1: CRITICAL TABLES RLS IMPLEMENTATION
-- ============================================================================

-- 1. USERS TABLE
-- Enable RLS on users table - users can only access their own data
-- ============================================================================

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (safety measure)
DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;
DROP POLICY IF EXISTS "users_insert_own" ON public.users;

-- Policy: Users can select their own data
CREATE POLICY "users_select_own" ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "users_update_own" ON public.users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Policy: Users can insert their own data (for profile creation)
CREATE POLICY "users_insert_own" ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================================================
-- 2. SESSIONS TABLE (VERIFY EXISTING POLICIES)
-- Sessions should only be accessible by their facilitators
-- ============================================================================

-- Note: RLS is already enabled on sessions table
-- Verify existing policies are correct, add missing ones if needed

-- Drop and recreate policies to ensure consistency
DROP POLICY IF EXISTS "sessions_select_facilitator" ON public.sessions;
DROP POLICY IF EXISTS "sessions_update_facilitator" ON public.sessions;
DROP POLICY IF EXISTS "sessions_insert_facilitator" ON public.sessions;
DROP POLICY IF EXISTS "sessions_delete_facilitator" ON public.sessions;

-- Policy: Facilitators can select their own sessions
CREATE POLICY "sessions_select_facilitator" ON public.sessions
    FOR SELECT
    USING (auth.uid() = facilitator_id);

-- Policy: Facilitators can update their own sessions
CREATE POLICY "sessions_update_facilitator" ON public.sessions
    FOR UPDATE
    USING (auth.uid() = facilitator_id)
    WITH CHECK (auth.uid() = facilitator_id);

-- Policy: Facilitators can insert sessions (they become the facilitator)
CREATE POLICY "sessions_insert_facilitator" ON public.sessions
    FOR INSERT
    WITH CHECK (auth.uid() = facilitator_id);

-- Policy: Facilitators can delete their own sessions
CREATE POLICY "sessions_delete_facilitator" ON public.sessions
    FOR DELETE
    USING (auth.uid() = facilitator_id);

-- ============================================================================
-- 3. RESULTS TABLE
-- Results should only be accessible through session ownership
-- ============================================================================

-- Enable RLS
ALTER TABLE public.results ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "results_select_via_session" ON public.results;
DROP POLICY IF EXISTS "results_update_via_session" ON public.results;
DROP POLICY IF EXISTS "results_insert_via_session" ON public.results;
DROP POLICY IF EXISTS "results_delete_via_session" ON public.results;

-- Policy: Select results through session facilitator ownership
CREATE POLICY "results_select_via_session" ON public.results
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = results.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Update results through session facilitator ownership
CREATE POLICY "results_update_via_session" ON public.results
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = results.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = results.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Insert results through session facilitator ownership
CREATE POLICY "results_insert_via_session" ON public.results
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = results.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Delete results through session facilitator ownership
CREATE POLICY "results_delete_via_session" ON public.results
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.sessions 
            WHERE sessions.session_id = results.session_id 
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- ============================================================================
-- 4. RESULTS_ANSWERS TABLE
-- Results answers should only be accessible through results/session ownership
-- ============================================================================

-- Enable RLS
ALTER TABLE public.results_answers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "results_answers_select_via_results" ON public.results_answers;
DROP POLICY IF EXISTS "results_answers_update_via_results" ON public.results_answers;
DROP POLICY IF EXISTS "results_answers_insert_via_results" ON public.results_answers;
DROP POLICY IF EXISTS "results_answers_delete_via_results" ON public.results_answers;

-- Policy: Select results_answers through results -> session ownership chain
CREATE POLICY "results_answers_select_via_results" ON public.results_answers
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.results
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results.results_id = results_answers.results_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Update results_answers through ownership chain
CREATE POLICY "results_answers_update_via_results" ON public.results_answers
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.results
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results.results_id = results_answers.results_id
            AND sessions.facilitator_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.results
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results.results_id = results_answers.results_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Insert results_answers through ownership chain
CREATE POLICY "results_answers_insert_via_results" ON public.results_answers
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.results
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results.results_id = results_answers.results_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- Policy: Delete results_answers through ownership chain
CREATE POLICY "results_answers_delete_via_results" ON public.results_answers
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.results
            JOIN public.sessions ON sessions.session_id = results.session_id
            WHERE results.results_id = results_answers.results_id
            AND sessions.facilitator_id = auth.uid()
        )
    );

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these queries to verify the policies are working correctly:

-- 1. Check RLS is enabled on all tables
-- SELECT schemaname, tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('users', 'sessions', 'results', 'results_answers');

-- 2. List all policies created
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('users', 'sessions', 'results', 'results_answers')
-- ORDER BY tablename, policyname;

-- ============================================================================
-- ROLLBACK COMMANDS (if needed)
-- ============================================================================

-- Uncomment and run these if you need to rollback the changes:

-- -- Disable RLS on all tables
-- -- ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
-- -- ALTER TABLE public.results DISABLE ROW LEVEL SECURITY;
-- -- ALTER TABLE public.results_answers DISABLE ROW LEVEL SECURITY;

-- -- Drop all policies
-- -- DROP POLICY IF EXISTS "users_select_own" ON public.users;
-- -- DROP POLICY IF EXISTS "users_update_own" ON public.users;
-- -- DROP POLICY IF EXISTS "users_insert_own" ON public.users;
-- -- DROP POLICY IF EXISTS "sessions_select_facilitator" ON public.sessions;
-- -- DROP POLICY IF EXISTS "sessions_update_facilitator" ON public.sessions;
-- -- DROP POLICY IF EXISTS "sessions_insert_facilitator" ON public.sessions;
-- -- DROP POLICY IF EXISTS "sessions_delete_facilitator" ON public.sessions;
-- -- DROP POLICY IF EXISTS "results_select_via_session" ON public.results;
-- -- DROP POLICY IF EXISTS "results_update_via_session" ON public.results;
-- -- DROP POLICY IF EXISTS "results_insert_via_session" ON public.results;
-- -- DROP POLICY IF EXISTS "results_delete_via_session" ON public.results;
-- -- DROP POLICY IF EXISTS "results_answers_select_via_results" ON public.results_answers;
-- -- DROP POLICY IF EXISTS "results_answers_update_via_results" ON public.results_answers;
-- -- DROP POLICY IF EXISTS "results_answers_insert_via_results" ON public.results_answers;
-- -- DROP POLICY IF EXISTS "results_answers_delete_via_results" ON public.results_answers;