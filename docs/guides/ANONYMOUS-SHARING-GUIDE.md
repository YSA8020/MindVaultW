# Anonymous Sharing Platform Guide - MindVault

## Overview
The Anonymous Sharing Platform allows users to share their thoughts, feelings, and experiences anonymously while maintaining the ability for emergency response teams to provide immediate help when needed.

## Key Features

### 1. Anonymous Posting
- Users can share thoughts without revealing their identity
- Anonymous usernames protect privacy
- Posts are visible to all users in the community
- User IDs are hidden from other users

### 2. Risk Assessment
- Automatic risk level detection based on:
  - Mood level (1-10 scale)
  - Post type (thought, question, support, crisis)
  - Content analysis
- Risk levels: Low, Medium, High, Critical

### 3. Emergency Response
- Admin access to user information for emergency response
- Geolocation tracking for medium-high risk users
- Automatic emergency response initiation for critical posts
- Emergency contact information storage

### 4. Safety Features
- Crisis support resources always visible
- 24/7 emergency contact information
- Automatic risk monitoring
- User risk assessment tracking

## User Guide

### Creating an Anonymous Post

**Step 1: Choose an Anonymous Name**
- Create a unique anonymous username
- This name will be visible to others
- Your real identity remains hidden

**Step 2: Share Your Thoughts**
- Write your post content
- Be honest and open
- Remember: You're in a safe space

**Step 3: Select Post Type**
- **Thought**: General thoughts or reflections
- **Question**: Ask for advice or information
- **Support Request**: Request peer support
- **Crisis**: Need immediate help

**Step 4: Indicate Your Mood**
- Use the slider (1-10 scale)
- 1 = Very low
- 10 = Very high
- This helps assess your risk level

**Step 5: Enable Location (Optional)**
- Allow location sharing for emergency response
- Only used in crisis situations
- Helps emergency services reach you

**Step 6: Submit**
- Click "Share Anonymously"
- Your post is now live
- Other users can respond and support you

### Privacy and Safety

**What's Anonymous:**
- Your real name
- Your email address
- Your user ID (from other users)
- Your personal information

**What's Visible:**
- Your anonymous username
- Your post content
- Your mood level
- Your post type

**Admin Access:**
- Admins can see your real identity
- Only for emergency response purposes
- Never shared with other users
- Used to send help when needed

### Emergency Response

**When Emergency Response is Initiated:**
- Automatic for critical risk posts
- Manual by admins for high-risk posts
- Based on risk assessment algorithms
- Uses your location if provided

**What Happens:**
1. Admin receives alert
2. Admin reviews post and user information
3. Admin contacts emergency services if needed
4. Admin follows up with user
5. Response is logged for tracking

**Emergency Contacts:**
- National Suicide Prevention Lifeline: 988
- Crisis Text Line: 741741
- Emergency Services: 911
- MindVault Crisis Support: 24/7

## Admin Guide

### Monitoring Risk Levels

**Risk Level Indicators:**
- **Critical**: Immediate danger, suicidal thoughts, self-harm
- **High**: Severe distress, depression, anxiety
- **Medium**: Moderate distress, seeking support
- **Low**: General thoughts, questions, reflections

### Emergency Response Protocol

**Step 1: Review Alert**
- Check risk level
- Read post content
- Review user information
- Assess urgency

**Step 2: Initiate Response**
- Click "Initiate Emergency Response"
- Choose response method:
  - Phone call
  - Text message
  - Email
  - In-person visit
  - Emergency services

**Step 3: Document Response**
- Log response details
- Add responder notes
- Update response status
- Schedule follow-up if needed

**Step 4: Follow Up**
- Check on user regularly
- Monitor for additional posts
- Update risk assessment
- Close case when resolved

### Accessing User Information

**User Details Available:**
- Real name and email
- Location (if enabled)
- Emergency contacts
- Post history
- Risk assessment history
- Response history

**How to Access:**
1. Go to Emergency Response Dashboard
2. Click on alert or post
3. Click "View User Details"
4. Review all available information
5. Take appropriate action

### Geolocation Features

**Location Tracking:**
- Enabled for medium-high risk users
- Updates with each post
- Used for emergency response only
- Never shared with other users

**Location Data:**
- Latitude and longitude
- City, state, country
- Street address (if available)
- Last known location
- Location history

## Technical Details

### Database Tables

**anonymous_posts**
- Stores all anonymous posts
- Contains user_id (hidden from users)
- Tracks risk levels and emergency response

**anonymous_post_comments**
- Stores comments on posts
- Maintains anonymity
- Tracks engagement

**anonymous_post_likes**
- Tracks likes on posts
- Anonymous to other users
- Used for engagement metrics

**emergency_response_log**
- Logs all emergency responses
- Admin-only access
- Tracks response status and outcomes

**user_risk_assessment**
- Tracks user risk levels over time
- Updates automatically
- Used for monitoring

### Risk Assessment Algorithm

**Factors Considered:**
1. **Mood Level**
   - 1-3: High risk
   - 4-5: Medium risk
   - 6-10: Low risk

2. **Post Type**
   - Crisis: Critical risk
   - Support Request: Medium risk
   - Question: Low risk
   - Thought: Variable

3. **Recent Activity**
   - Multiple crisis posts: Higher risk
   - Frequent posts: Increased monitoring
   - No engagement: Potential concern

4. **Content Analysis**
   - Keywords indicating crisis
   - Emotional tone
   - Request for help
   - Mention of self-harm

### Row Level Security (RLS)

**User Access:**
- Can view anonymous posts
- Cannot see user_id
- Can create posts
- Can update own posts
- Can delete own posts

**Admin Access:**
- Can view all data
- Can see user_id
- Can initiate emergency response
- Can access location data
- Can view emergency logs

## Best Practices

### For Users

**Do:**
- Be honest about your feelings
- Enable location for emergency response
- Use the crisis option when needed
- Engage with the community
- Report concerning posts

**Don't:**
- Share personal identifying information
- Post harmful or threatening content
- Use the platform for illegal activities
- Bully or harass other users
- Ignore crisis warnings

### For Admins

**Do:**
- Respond to alerts quickly
- Follow emergency protocols
- Document all responses
- Monitor high-risk users
- Maintain confidentiality

**Don't:**
- Delay emergency responses
- Share user information publicly
- Ignore risk indicators
- Skip documentation
- Make assumptions

## Compliance and Ethics

### HIPAA Compliance
- All data encrypted
- Access logs maintained
- User consent for data use
- Secure data storage

### Privacy Protection
- User anonymity maintained
- Location data protected
- Emergency contacts secured
- Admin access logged

### Ethical Guidelines
- Respect user autonomy
- Provide appropriate support
- Maintain confidentiality
- Act in user's best interest
- Follow professional standards

## Support and Resources

### For Users
- Help Center: https://mindvault.fit/help-center.html
- Crisis Support: Available 24/7
- Community Guidelines: See help center
- Privacy Policy: See help center

### For Admins
- Emergency Response Dashboard: https://mindvault.fit/emergency-response-dashboard.html
- Admin Dashboard: https://mindvault.fit/admin-dashboard.html
- Training Materials: See admin portal
- Support: support@mindvault.fit

## Frequently Asked Questions

### Q: Is my information really anonymous?
A: To other users, yes. Admins can see your information for emergency response only.

### Q: When will emergency response be initiated?
A: Automatic for critical risk posts, or manually by admins for high-risk situations.

### Q: What happens to my location data?
A: Only used for emergency response. Never shared with other users.

### Q: Can I delete my posts?
A: Yes, you can delete your own posts at any time.

### Q: How do I report concerning content?
A: Use the "Report" button on any post, or contact support.

### Q: What if I'm in immediate danger?
A: Call 988, text 741741, or call 911. Don't rely solely on the platform.

## Contact

**Support Email**: support@mindvault.fit
**Crisis Support**: Available 24/7 in the platform
**Emergency**: 911

---

**Remember**: Your safety is our priority. Help is always available.
