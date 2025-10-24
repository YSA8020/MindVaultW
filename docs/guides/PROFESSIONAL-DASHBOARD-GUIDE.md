# 👨‍⚕️ Professional Dashboard Guide

## Overview

The Professional Dashboard is a comprehensive platform for mental health professionals to manage their practice, clients, sessions, and track their professional growth on MindVault.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Dashboard Features](#dashboard-features)
3. [Client Management](#client-management)
4. [Session Management](#session-management)
5. [Treatment Planning](#treatment-planning)
6. [Analytics & Reporting](#analytics--reporting)
7. [Best Practices](#best-practices)

---

## Getting Started

### Accessing the Dashboard

1. **Login**: Use your professional credentials to log in at `counselor-dashboard.html`
2. **Complete Onboarding**: If you're new, complete the onboarding process at `professional-onboarding.html`
3. **Verify Credentials**: Ensure your professional credentials are verified by admin

### Initial Setup

```sql
-- Check your professional profile
SELECT * FROM professional_profiles WHERE user_id = 'your-user-id';

-- Initialize availability
INSERT INTO professional_availability (professional_id, available_for_new_clients, max_clients)
VALUES ('your-user-id', true, 20);
```

---

## Dashboard Features

### 1. Overview Statistics

The dashboard displays key metrics at a glance:

- **Total Clients**: All clients you've worked with
- **Active Clients**: Currently active relationships
- **Sessions Today**: Scheduled sessions for today
- **Upcoming Sessions**: Next 7 days
- **Revenue**: Total and monthly earnings
- **Completion Rate**: Session completion percentage

### 2. Quick Actions

- **New Client**: Add a new client relationship
- **Schedule Session**: Book a new session
- **View Calendar**: See your full schedule
- **Client Notes**: Quick access to recent notes

### 3. Recent Activity

- Latest client interactions
- Recent session notes
- Upcoming appointments
- Pending assessments

---

## Client Management

### Adding a New Client

```javascript
// Create a new client-professional relationship
async function addClient(clientId, professionalId) {
    const { data, error } = await supabase
        .from('client_professional_relationships')
        .insert([{
            client_id: clientId,
            professional_id: professionalId,
            relationship_status: 'pending',
            matched_on: new Date().toISOString().split('T')[0],
            matched_by: 'manual'
        }]);
    
    if (error) throw error;
    return data;
}
```

### Client Status

- **Pending**: New relationship, awaiting first session
- **Active**: Regular client with ongoing treatment
- **Paused**: Temporarily on hold
- **Ended**: Relationship terminated

### Client Information

For each client, you can access:

- **Profile**: Basic information and demographics
- **Session History**: All past sessions
- **Treatment Plans**: Current and past plans
- **Assessments**: Progress assessments
- **Notes**: Clinical notes and observations
- **Goals**: Treatment goals and objectives

### Example: Get Client List

```javascript
async function getMyClients(professionalId, status = 'active') {
    const { data, error } = await supabase.rpc('get_professional_clients', {
        p_professional_id: professionalId,
        p_status: status
    });
    
    if (error) throw error;
    return data;
}
```

---

## Session Management

### Scheduling a Session

```javascript
async function scheduleSession(sessionData) {
    const { data, error } = await supabase
        .from('sessions')
        .insert([{
            client_id: sessionData.clientId,
            professional_id: sessionData.professionalId,
            session_date: sessionData.date,
            session_time: sessionData.time,
            session_duration_minutes: sessionData.duration || 60,
            session_type: sessionData.type || 'individual',
            session_format: sessionData.format || 'video',
            session_status: 'scheduled',
            session_fee: sessionData.fee,
            payment_status: 'pending'
        }]);
    
    if (error) throw error;
    return data;
}
```

### Session Types

- **Individual**: One-on-one therapy
- **Group**: Group therapy sessions
- **Couples**: Couples counseling
- **Family**: Family therapy

### Session Formats

- **In-Person**: Face-to-face at your office
- **Video**: Virtual video call
- **Phone**: Phone session
- **Hybrid**: Mix of formats

### Session Status

- **Scheduled**: Upcoming appointment
- **Completed**: Session finished
- **Cancelled**: Client or professional cancelled
- **No-Show**: Client didn't attend
- **Rescheduled**: Moved to different time

### Session Notes (SOAP Format)

```javascript
async function addSessionNote(sessionId, noteData) {
    const { data, error } = await supabase
        .from('client_notes')
        .insert([{
            session_id: sessionId,
            client_id: noteData.clientId,
            professional_id: noteData.professionalId,
            note_type: 'session',
            note_date: new Date().toISOString().split('T')[0],
            note_time: new Date().toTimeString().split(' ')[0],
            subjective: noteData.subjective, // What client reports
            objective: noteData.objective,   // Observations
            assessment: noteData.assessment, // Clinical assessment
            plan: noteData.plan              // Treatment plan
        }]);
    
    if (error) throw error;
    return data;
}
```

### Example: Get Upcoming Sessions

```javascript
async function getUpcomingSessions(professionalId, limit = 10) {
    const { data, error } = await supabase.rpc('get_upcoming_sessions', {
        p_professional_id: professionalId,
        p_limit: limit
    });
    
    if (error) throw error;
    return data;
}
```

---

## Treatment Planning

### Creating a Treatment Plan

```javascript
async function createTreatmentPlan(planData) {
    const { data, error } = await supabase
        .from('treatment_plans')
        .insert([{
            client_id: planData.clientId,
            professional_id: planData.professionalId,
            plan_name: planData.name,
            plan_description: planData.description,
            diagnosis: planData.diagnosis,
            presenting_problems: planData.problems,
            primary_goals: planData.goals,
            treatment_approach: planData.approach,
            interventions_planned: planData.interventions,
            estimated_duration_weeks: planData.duration,
            start_date: new Date().toISOString().split('T')[0],
            status: 'active'
        }]);
    
    if (error) throw error;
    return data;
}
```

### Treatment Plan Components

1. **Presenting Problems**: What brings the client to therapy
2. **Diagnosis**: Clinical diagnosis (if applicable)
3. **Primary Goals**: Main treatment objectives
4. **Measurable Objectives**: Specific, measurable goals
5. **Treatment Approach**: Therapeutic modality (CBT, DBT, etc.)
6. **Interventions**: Specific techniques to use
7. **Duration**: Estimated length of treatment

### Updating Treatment Progress

```javascript
async function updateTreatmentProgress(planId, progressData) {
    const { data, error } = await supabase
        .from('treatment_plans')
        .update({
            progress_notes: progressData.notes,
            outcome_measures: progressData.outcomes,
            status: progressData.status
        })
        .eq('id', planId);
    
    if (error) throw error;
    return data;
}
```

---

## Client Assessments

### Types of Assessments

- **Initial**: First assessment at intake
- **Progress**: Regular progress check-ins
- **Outcome**: Final outcome assessment
- **Custom**: Custom assessments as needed

### Creating an Assessment

```javascript
async function createAssessment(assessmentData) {
    const { data, error } = await supabase
        .from('client_assessments')
        .insert([{
            client_id: assessmentData.clientId,
            professional_id: assessmentData.professionalId,
            assessment_type: assessmentData.type,
            assessment_name: assessmentData.name,
            assessment_date: new Date().toISOString().split('T')[0],
            scores: assessmentData.scores,
            results_summary: assessmentData.summary,
            recommendations: assessmentData.recommendations,
            follow_up_required: assessmentData.followUp,
            follow_up_date: assessmentData.followUpDate
        }]);
    
    if (error) throw error;
    return data;
}
```

### Common Assessment Tools

- **PHQ-9**: Depression screening
- **GAD-7**: Anxiety screening
- **PCL-5**: PTSD assessment
- **DASS-21**: Depression, Anxiety, Stress Scale
- **Custom**: Your own assessment tools

---

## Analytics & Reporting

### Dashboard Statistics

```javascript
async function getDashboardStats(professionalId) {
    const { data, error } = await supabase.rpc('get_professional_dashboard_stats', {
        p_professional_id: professionalId
    });
    
    if (error) throw error;
    return data[0];
}
```

### Revenue Tracking

Track your earnings by:
- **Total Revenue**: All-time earnings
- **Monthly Revenue**: Current month earnings
- **Payment Status**: Pending, paid, insurance, waived
- **Session Fees**: Individual session rates

### Client Metrics

- **Total Clients**: All clients served
- **Active Clients**: Currently in treatment
- **Completion Rate**: Treatment completion percentage
- **Satisfaction Score**: Client feedback

### Session Metrics

- **Total Sessions**: All sessions conducted
- **Completed Sessions**: Successful sessions
- **Cancelled Sessions**: Cancellations
- **No-Shows**: Missed appointments
- **Average Duration**: Average session length

---

## Best Practices

### 1. HIPAA Compliance

- **Secure Notes**: All notes are encrypted and confidential
- **Access Control**: Only you can view your client data
- **Audit Trail**: All actions are logged
- **Data Retention**: Follow your state's retention requirements

### 2. Session Documentation

- **Timely Notes**: Document within 24 hours
- **SOAP Format**: Subjective, Objective, Assessment, Plan
- **Be Specific**: Include concrete observations
- **Avoid Judgments**: Stick to facts and observations

### 3. Treatment Planning

- **SMART Goals**: Specific, Measurable, Achievable, Relevant, Time-bound
- **Client Collaboration**: Involve client in goal-setting
- **Regular Review**: Update plans quarterly
- **Evidence-Based**: Use research-supported interventions

### 4. Client Communication

- **Clear Boundaries**: Set expectations early
- **Consistent Contact**: Regular check-ins
- **Crisis Protocol**: Know emergency procedures
- **Professional Tone**: Maintain therapeutic boundaries

### 5. Time Management

- **Schedule Buffer**: 15-minute breaks between sessions
- **Lunch Break**: At least 30 minutes midday
- **End Time**: Finish at scheduled time
- **Documentation Time**: Block time for notes

### 6. Self-Care

- **Regular Breaks**: Don't skip breaks
- **Supervision**: Regular supervision or consultation
- **Continuing Education**: Stay current with best practices
- **Work-Life Balance**: Maintain healthy boundaries

---

## Troubleshooting

### Issue: Can't see clients

**Solution**:
1. Check if relationship status is 'active'
2. Verify you're logged in with correct professional account
3. Ensure RLS policies are configured correctly

### Issue: Session not saving

**Solution**:
1. Check all required fields are filled
2. Verify date/time format is correct
3. Check for database errors in console

### Issue: Revenue not calculating

**Solution**:
1. Ensure payment_status is 'paid'
2. Check session_fee is not null
3. Verify date range for monthly calculations

---

## Support

For technical issues:
- Check the [Troubleshooting](#troubleshooting) section
- Review console errors in browser
- Contact MindVault support team

For clinical questions:
- Consult your supervisor
- Review professional guidelines
- Check state licensing board requirements

---

## Next Steps

1. ✅ **Complete Onboarding**: Finish professional onboarding
2. ✅ **Set Availability**: Configure your schedule
3. ✅ **Add Clients**: Start adding clients
4. ✅ **Schedule Sessions**: Book your first sessions
5. ✅ **Create Treatment Plans**: Develop treatment plans
6. ✅ **Track Progress**: Monitor client progress
7. ✅ **Review Analytics**: Check your practice metrics

---

**Welcome to MindVault Professional! We're here to support your practice.** 👨‍⚕️
