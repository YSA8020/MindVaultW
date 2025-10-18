/**
 * MindVault Email Integration Module
 * Handles all email notifications for the platform
 * 
 * Supports: SendGrid, Mailgun, Amazon SES
 */

class MindVaultEmailService {
    constructor() {
        this.provider = null;
        this.apiKey = null;
        this.fromEmail = 'noreply@mindvault.fit';
        this.fromName = 'MindVault';
        this.baseUrl = null;
    }

    /**
     * Initialize email service with provider credentials
     * @param {string} provider - 'sendgrid', 'mailgun', or 'ses'
     * @param {string} apiKey - API key for the provider
     * @param {string} baseUrl - Base URL for the provider (Mailgun only)
     */
    async initialize(provider, apiKey, baseUrl = null) {
        this.provider = provider.toLowerCase();
        this.apiKey = apiKey;
        this.baseUrl = baseUrl;

        // Validate configuration
        if (!this.provider || !this.apiKey) {
            throw new Error('Email service provider and API key are required');
        }

        if (this.provider === 'mailgun' && !this.baseUrl) {
            throw new Error('Mailgun requires a base URL (e.g., https://api.mailgun.net/v3/your-domain.com)');
        }

        console.log(`Email service initialized with ${this.provider}`);
        return true;
    }

    /**
     * Send email using the configured provider
     * @param {string} to - Recipient email address
     * @param {string} subject - Email subject
     * @param {string} htmlBody - HTML email body
     * @param {string} textBody - Plain text email body (optional)
     * @param {Array} attachments - Array of attachment objects (optional)
     */
    async sendEmail(to, subject, htmlBody, textBody = null, attachments = []) {
        if (!this.provider || !this.apiKey) {
            throw new Error('Email service not initialized. Call initialize() first.');
        }

        try {
            switch (this.provider) {
                case 'sendgrid':
                    return await this.sendViaSendGrid(to, subject, htmlBody, textBody, attachments);
                case 'mailgun':
                    return await this.sendViaMailgun(to, subject, htmlBody, textBody, attachments);
                case 'ses':
                    return await this.sendViaSES(to, subject, htmlBody, textBody, attachments);
                default:
                    throw new Error(`Unsupported email provider: ${this.provider}`);
            }
        } catch (error) {
            console.error('Error sending email:', error);
            throw error;
        }
    }

    /**
     * Send email via SendGrid
     */
    async sendViaSendGrid(to, subject, htmlBody, textBody, attachments) {
        const payload = {
            personalizations: [{
                to: [{ email: to }],
                subject: subject
            }],
            from: {
                email: this.fromEmail,
                name: this.fromName
            },
            content: [
                {
                    type: 'text/html',
                    value: htmlBody
                }
            ]
        };

        if (textBody) {
            payload.content.push({
                type: 'text/plain',
                value: textBody
            });
        }

        if (attachments.length > 0) {
            payload.attachments = attachments.map(att => ({
                content: att.content,
                filename: att.filename,
                type: att.type || 'application/octet-stream'
            }));
        }

        const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${this.apiKey}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`SendGrid API error: ${error}`);
        }

        return { success: true, provider: 'sendgrid' };
    }

    /**
     * Send email via Mailgun
     */
    async sendViaMailgun(to, subject, htmlBody, textBody, attachments) {
        const formData = new FormData();
        formData.append('from', `${this.fromName} <${this.fromEmail}>`);
        formData.append('to', to);
        formData.append('subject', subject);
        formData.append('html', htmlBody);

        if (textBody) {
            formData.append('text', textBody);
        }

        if (attachments.length > 0) {
            attachments.forEach(att => {
                formData.append('attachment', att.content, att.filename);
            });
        }

        const response = await fetch(`${this.baseUrl}/messages`, {
            method: 'POST',
            headers: {
                'Authorization': `Basic ${btoa(`api:${this.apiKey}`)}`
            },
            body: formData
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`Mailgun API error: ${error}`);
        }

        const result = await response.json();
        return { success: true, provider: 'mailgun', messageId: result.id };
    }

    /**
     * Send email via Amazon SES (Note: SES typically requires server-side implementation)
     */
    async sendViaSES(to, subject, htmlBody, textBody, attachments) {
        // Note: SES requires AWS SDK and is typically implemented server-side
        // This is a placeholder for client-side integration
        throw new Error('Amazon SES requires server-side implementation. Use SendGrid or Mailgun for client-side integration.');
    }

    // ========================================
    // EMAIL TEMPLATES
    // ========================================

    /**
     * Send user verification email
     */
    async sendVerificationEmail(userEmail, verificationLink) {
        const subject = 'Verify Your MindVault Account';
        const htmlBody = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .button { display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Welcome to MindVault!</h1>
                    </div>
                    <div class="content">
                        <p>Hi there,</p>
                        <p>Thank you for signing up for MindVault! We're excited to have you on board.</p>
                        <p>To get started, please verify your email address by clicking the button below:</p>
                        <div style="text-align: center;">
                            <a href="${verificationLink}" class="button">Verify Email Address</a>
                        </div>
                        <p>Or copy and paste this link into your browser:</p>
                        <p style="word-break: break-all; color: #667eea;">${verificationLink}</p>
                        <p>This link will expire in 24 hours.</p>
                        <p>If you didn't create an account with MindVault, please ignore this email.</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 MindVault. All rights reserved.</p>
                        <p>Your mental health companion</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return await this.sendEmail(userEmail, subject, htmlBody);
    }

    /**
     * Send password reset email
     */
    async sendPasswordResetEmail(userEmail, resetLink) {
        const subject = 'Reset Your MindVault Password';
        const htmlBody = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .button { display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Password Reset Request</h1>
                    </div>
                    <div class="content">
                        <p>Hi there,</p>
                        <p>We received a request to reset your password for your MindVault account.</p>
                        <p>Click the button below to reset your password:</p>
                        <div style="text-align: center;">
                            <a href="${resetLink}" class="button">Reset Password</a>
                        </div>
                        <p>Or copy and paste this link into your browser:</p>
                        <p style="word-break: break-all; color: #667eea;">${resetLink}</p>
                        <p>This link will expire in 1 hour.</p>
                        <p>If you didn't request a password reset, please ignore this email. Your password will remain unchanged.</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 MindVault. All rights reserved.</p>
                        <p>Your mental health companion</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return await this.sendEmail(userEmail, subject, htmlBody);
    }

    /**
     * Send professional verification email
     */
    async sendProfessionalVerificationEmail(userEmail, professionalName) {
        const subject = 'Professional Status Verified - Welcome to MindVault!';
        const htmlBody = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .button { display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🎉 Professional Status Verified!</h1>
                    </div>
                    <div class="content">
                        <p>Hi ${professionalName},</p>
                        <p>Congratulations! Your professional credentials have been verified.</p>
                        <p>You now have access to MindVault's professional features, including:</p>
                        <ul>
                            <li>Client management and scheduling</li>
                            <li>Treatment planning and assessments</li>
                            <li>Professional analytics dashboard</li>
                            <li>Session documentation</li>
                        </ul>
                        <div style="text-align: center;">
                            <a href="professional-onboarding.html" class="button">Complete Your Profile</a>
                        </div>
                        <p>Welcome to the MindVault professional community!</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 MindVault. All rights reserved.</p>
                        <p>Your mental health companion</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return await this.sendEmail(userEmail, subject, htmlBody);
    }

    /**
     * Send session reminder email
     */
    async sendSessionReminderEmail(userEmail, userName, sessionDate, sessionTime) {
        const subject = 'Upcoming Session Reminder';
        const htmlBody = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .info-box { background: white; padding: 20px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #667eea; }
                    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Session Reminder</h1>
                    </div>
                    <div class="content">
                        <p>Hi ${userName},</p>
                        <p>This is a reminder about your upcoming session:</p>
                        <div class="info-box">
                            <p><strong>Date:</strong> ${sessionDate}</p>
                            <p><strong>Time:</strong> ${sessionTime}</p>
                        </div>
                        <p>Please make sure you're available for your session. If you need to reschedule, please contact your counselor as soon as possible.</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 MindVault. All rights reserved.</p>
                        <p>Your mental health companion</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return await this.sendEmail(userEmail, subject, htmlBody);
    }

    /**
     * Send welcome email
     */
    async sendWelcomeEmail(userEmail, userName) {
        const subject = 'Welcome to MindVault - Your Journey Begins';
        const htmlBody = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .button { display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Welcome to MindVault, ${userName}!</h1>
                    </div>
                    <div class="content">
                        <p>We're thrilled to have you join the MindVault community!</p>
                        <p>MindVault is your personal mental health companion, designed to support you on your journey to better mental well-being.</p>
                        <p>Here's what you can do:</p>
                        <ul>
                            <li>Connect with licensed mental health professionals</li>
                            <li>Track your mood and mental health progress</li>
                            <li>Access resources and tools for self-care</li>
                            <li>Join a supportive community</li>
                        </ul>
                        <div style="text-align: center;">
                            <a href="index-backup.html" class="button">Get Started</a>
                        </div>
                        <p>If you have any questions, our support team is here to help.</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 MindVault. All rights reserved.</p>
                        <p>Your mental health companion</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return await this.sendEmail(userEmail, subject, htmlBody);
    }

    /**
     * Send emergency alert email
     */
    async sendEmergencyAlertEmail(adminEmail, alertDetails) {
        const subject = '🚨 Emergency Alert - MindVault';
        const htmlBody = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #dc2626; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .alert-box { background: #fee2e2; padding: 20px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #dc2626; }
                    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🚨 Emergency Alert</h1>
                    </div>
                    <div class="content">
                        <div class="alert-box">
                            <h2>High-Risk Content Detected</h2>
                            <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
                            <p><strong>Risk Level:</strong> ${alertDetails.riskLevel}</p>
                            <p><strong>Details:</strong> ${alertDetails.description}</p>
                        </div>
                        <p>Please review the emergency response dashboard immediately.</p>
                        <div style="text-align: center;">
                            <a href="emergency-response-dashboard.html" style="display: inline-block; background: #dc2626; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0;">View Dashboard</a>
                        </div>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 MindVault. All rights reserved.</p>
                        <p>Your mental health companion</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return await this.sendEmail(adminEmail, subject, htmlBody);
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MindVaultEmailService;
}

// Global instance for browser use
window.MindVaultEmailService = MindVaultEmailService;

