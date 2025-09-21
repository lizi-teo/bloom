# Row Level Security (RLS) Implementation Plan

## Overview
This document outlines the comprehensive implementation of Row Level Security (RLS) for the Bloom app's Supabase database to address critical security vulnerabilities.

## Current Security Issues

### Critical RLS Vulnerabilities
- **9 out of 10 tables have RLS disabled**, exposing all data to unauthorized access
- Only `sessions` table currently has RLS enabled
- All user data, responses, and analytics are publicly accessible

### Tables Requiring RLS Implementation
1. ❌ `users` - Contains personal user data (CRITICAL)
2. ❌ `results` - Contains user response data (HIGH)
3. ❌ `results_answers` - Contains individual user responses (HIGH)
4. ❌ `feedback_sentiment` - Contains sentiment analysis data (MEDIUM)
5. ❌ `session_sentiment_summary` - Contains session analytics (MEDIUM)
6. ❌ `templates` - Contains template data (LOW)
7. ❌ `questions` - Contains question data (LOW)
8. ❌ `templates_questions` - Junction table (LOW)
9. ❌ `_component_type` - Reference data (LOW)

### Additional Security Concerns
- Leaked password protection disabled
- Insufficient MFA options enabled
- Postgres version needs security patches

## Implementation Strategy

### Phase 1: Critical Tables (HIGH PRIORITY)
**Target: User data and session responses**

1. **users table**: Enable RLS with user-specific access policies
2. **sessions table**: Verify existing policies ensure facilitator-only access
3. **results table**: Enable RLS with session-based ownership
4. **results_answers table**: Enable RLS chained through results ownership

### Phase 2: Sensitive Data Tables (MEDIUM PRIORITY)
**Target: Analytics and sentiment data**

5. **feedback_sentiment table**: Enable RLS chained through results_answers
6. **session_sentiment_summary table**: Enable RLS through session ownership

### Phase 3: Content Tables (LOW PRIORITY)
**Target: Templates and reference data**

7. **templates table**: Enable RLS with public read, facilitator ownership
8. **questions table**: Enable RLS with public read access
9. **templates_questions table**: Enable RLS following templates permissions
10. **_component_type table**: Enable RLS with public read access

## Security Model

### User Authentication
- Uses Supabase Auth with `auth.uid()` for user identification
- Facilitator role identified through `facilitator_id` foreign key relationships

### Access Control Patterns

#### User Data Access
- **Rule**: Users can only access their own data
- **Implementation**: `WHERE auth.uid() = id`

#### Facilitator Session Access
- **Rule**: Facilitators can only access sessions they created
- **Implementation**: `WHERE auth.uid() = facilitator_id`

#### Ownership Chain Access
- **Rule**: Access granted through foreign key relationships
- **Example**: Results → Sessions → Facilitator ownership

#### Public Content Access
- **Rule**: Templates and questions are publicly readable
- **Implementation**: Public `SELECT` policies, restricted `INSERT/UPDATE/DELETE`

## Migration Files

Each phase will have corresponding SQL migration files in `.database/migrations/`:

- `rls_phase_1_critical_tables.sql`
- `rls_phase_2_sensitive_data.sql`  
- `rls_phase_3_content_tables.sql`

## Testing Strategy

### Phase 1 Testing
1. Verify users can only access their own profile data
2. Confirm facilitators can only see their created sessions
3. Test that session participants cannot access other sessions
4. Validate results are only accessible through proper session ownership

### Phase 2 Testing
1. Verify sentiment data follows ownership chain
2. Test session summaries are facilitator-restricted

### Phase 3 Testing
1. Confirm templates and questions are publicly readable
2. Verify only authorized users can modify content
3. Test junction table permissions follow parent table rules

## Rollback Plan

Each migration file will include corresponding `DROP POLICY` statements for safe rollback if issues arise.

## Success Metrics

- [ ] All 9 tables have RLS enabled
- [ ] Zero security advisor warnings for RLS
- [ ] All user data properly isolated by ownership
- [ ] Public content remains accessible
- [ ] Application functionality unchanged
- [ ] Performance impact minimal

## Implementation Timeline

- **Phase 1**: Immediate (critical security risk)
- **Phase 2**: Within 24 hours
- **Phase 3**: Within 48 hours

## Post-Implementation

### Security Hardening
1. Enable leaked password protection
2. Configure additional MFA options
3. Schedule Postgres version upgrade
4. Regular security audits

### Monitoring
- Monitor RLS policy performance
- Track unauthorized access attempts
- Regular security advisor reviews