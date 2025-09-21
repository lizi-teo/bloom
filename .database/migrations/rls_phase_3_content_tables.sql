-- Row Level Security Implementation - Phase 3: Content Tables
-- Execute this SQL in Supabase SQL Editor
-- Target: templates, questions, templates_questions, _component_type tables

-- ============================================================================
-- PHASE 3: CONTENT TABLES RLS IMPLEMENTATION
-- ============================================================================

-- 1. TEMPLATES TABLE
-- Templates should be publicly readable, but only modifiable by authenticated users
-- ============================================================================

-- Enable RLS
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "templates_select_public" ON public.templates;
DROP POLICY IF EXISTS "templates_insert_authenticated" ON public.templates;
DROP POLICY IF EXISTS "templates_update_authenticated" ON public.templates;
DROP POLICY IF EXISTS "templates_delete_authenticated" ON public.templates;

-- Policy: Anyone can read templates (public content)
CREATE POLICY "templates_select_public" ON public.templates
    FOR SELECT
    USING (true);

-- Policy: Only authenticated users can insert templates
CREATE POLICY "templates_insert_authenticated" ON public.templates
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can update templates
CREATE POLICY "templates_update_authenticated" ON public.templates
    FOR UPDATE
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can delete templates
CREATE POLICY "templates_delete_authenticated" ON public.templates
    FOR DELETE
    USING (auth.uid() IS NOT NULL);

-- ============================================================================
-- 2. QUESTIONS TABLE
-- Questions should be publicly readable, but only modifiable by authenticated users
-- ============================================================================

-- Enable RLS
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "questions_select_public" ON public.questions;
DROP POLICY IF EXISTS "questions_insert_authenticated" ON public.questions;
DROP POLICY IF EXISTS "questions_update_authenticated" ON public.questions;
DROP POLICY IF EXISTS "questions_delete_authenticated" ON public.questions;

-- Policy: Anyone can read questions (public content)
CREATE POLICY "questions_select_public" ON public.questions
    FOR SELECT
    USING (true);

-- Policy: Only authenticated users can insert questions
CREATE POLICY "questions_insert_authenticated" ON public.questions
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can update questions
CREATE POLICY "questions_update_authenticated" ON public.questions
    FOR UPDATE
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can delete questions
CREATE POLICY "questions_delete_authenticated" ON public.questions
    FOR DELETE
    USING (auth.uid() IS NOT NULL);

-- ============================================================================
-- 3. TEMPLATES_QUESTIONS TABLE (Junction Table)
-- Junction table should follow the same permissions as templates
-- ============================================================================

-- Enable RLS
ALTER TABLE public.templates_questions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "templates_questions_select_public" ON public.templates_questions;
DROP POLICY IF EXISTS "templates_questions_insert_authenticated" ON public.templates_questions;
DROP POLICY IF EXISTS "templates_questions_update_authenticated" ON public.templates_questions;
DROP POLICY IF EXISTS "templates_questions_delete_authenticated" ON public.templates_questions;

-- Policy: Anyone can read template-question relationships (public content)
CREATE POLICY "templates_questions_select_public" ON public.templates_questions
    FOR SELECT
    USING (true);

-- Policy: Only authenticated users can insert template-question relationships
CREATE POLICY "templates_questions_insert_authenticated" ON public.templates_questions
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can update template-question relationships
CREATE POLICY "templates_questions_update_authenticated" ON public.templates_questions
    FOR UPDATE
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can delete template-question relationships
CREATE POLICY "templates_questions_delete_authenticated" ON public.templates_questions
    FOR DELETE
    USING (auth.uid() IS NOT NULL);

-- ============================================================================
-- 4. _COMPONENT_TYPE TABLE
-- Component types are reference data, should be publicly readable
-- ============================================================================

-- Enable RLS
ALTER TABLE public._component_type ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "component_type_select_public" ON public._component_type;
DROP POLICY IF EXISTS "component_type_insert_authenticated" ON public._component_type;
DROP POLICY IF EXISTS "component_type_update_authenticated" ON public._component_type;
DROP POLICY IF EXISTS "component_type_delete_authenticated" ON public._component_type;

-- Policy: Anyone can read component types (reference data)
CREATE POLICY "component_type_select_public" ON public._component_type
    FOR SELECT
    USING (true);

-- Policy: Only authenticated users can insert component types
CREATE POLICY "component_type_insert_authenticated" ON public._component_type
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can update component types
CREATE POLICY "component_type_update_authenticated" ON public._component_type
    FOR UPDATE
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Only authenticated users can delete component types
CREATE POLICY "component_type_delete_authenticated" ON public._component_type
    FOR DELETE
    USING (auth.uid() IS NOT NULL);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these queries to verify the policies are working correctly:

-- 1. Check RLS is enabled on all content tables
-- SELECT schemaname, tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('templates', 'questions', 'templates_questions', '_component_type');

-- 2. List all policies created for content tables
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('templates', 'questions', 'templates_questions', '_component_type')
-- ORDER BY tablename, policyname;

-- 3. Test public read access (should work even without authentication)
-- SELECT COUNT(*) as template_count FROM public.templates;
-- SELECT COUNT(*) as question_count FROM public.questions;
-- SELECT COUNT(*) as component_type_count FROM public._component_type;

-- 4. Check that all tables now have RLS enabled
-- SELECT schemaname, tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN (
--     'users', 'sessions', 'results', 'results_answers', 
--     'feedback_sentiment', 'session_sentiment_summary',
--     'templates', 'questions', 'templates_questions', '_component_type'
-- )
-- ORDER BY tablename;

-- ============================================================================
-- ROLLBACK COMMANDS (if needed)
-- ============================================================================

-- Uncomment and run these if you need to rollback the changes:

-- -- Disable RLS on all content tables
-- -- ALTER TABLE public.templates DISABLE ROW LEVEL SECURITY;
-- -- ALTER TABLE public.questions DISABLE ROW LEVEL SECURITY;
-- -- ALTER TABLE public.templates_questions DISABLE ROW LEVEL SECURITY;
-- -- ALTER TABLE public._component_type DISABLE ROW LEVEL SECURITY;

-- -- Drop all content table policies
-- -- DROP POLICY IF EXISTS "templates_select_public" ON public.templates;
-- -- DROP POLICY IF EXISTS "templates_insert_authenticated" ON public.templates;
-- -- DROP POLICY IF EXISTS "templates_update_authenticated" ON public.templates;
-- -- DROP POLICY IF EXISTS "templates_delete_authenticated" ON public.templates;
-- -- DROP POLICY IF EXISTS "questions_select_public" ON public.questions;
-- -- DROP POLICY IF EXISTS "questions_insert_authenticated" ON public.questions;
-- -- DROP POLICY IF EXISTS "questions_update_authenticated" ON public.questions;
-- -- DROP POLICY IF EXISTS "questions_delete_authenticated" ON public.questions;
-- -- DROP POLICY IF EXISTS "templates_questions_select_public" ON public.templates_questions;
-- -- DROP POLICY IF EXISTS "templates_questions_insert_authenticated" ON public.templates_questions;
-- -- DROP POLICY IF EXISTS "templates_questions_update_authenticated" ON public.templates_questions;
-- -- DROP POLICY IF EXISTS "templates_questions_delete_authenticated" ON public.templates_questions;
-- -- DROP POLICY IF EXISTS "component_type_select_public" ON public._component_type;
-- -- DROP POLICY IF EXISTS "component_type_insert_authenticated" ON public._component_type;
-- -- DROP POLICY IF EXISTS "component_type_update_authenticated" ON public._component_type;
-- -- DROP POLICY IF EXISTS "component_type_delete_authenticated" ON public._component_type;