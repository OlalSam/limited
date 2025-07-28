package com.ignium.nganya;

import jakarta.annotation.Resource;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility class for sending email notifications via JavaMail.
 * Uses container-managed mail Session looked up via JNDI.
 * Provides reusable methods for plain text and HTML messages,
 * with optional company signature.
 *
 * Configure your mail session in your application server under JNDI name java:app/nganyaMail
 *
 * Example usage:
 *   @Inject MailUtility mailUtil;
 *   mailUtil.send("user@example.com", "Subject", "Hello World");
 */ 
@ApplicationScoped
public class MailUtility {
    private static final Logger logger = Logger.getLogger(MailUtility.class.getName());

    // Inject the JavaMail Session from JNDI
    @Resource(lookup = "java:app/nganyaMail")
    private Session mailSession;

    // Default values (can be overridden per-call)
    private static final String DEFAULT_FROM = "no-reply@nganya.co.ke";
    private static final String DEFAULT_SUBJECT = "Notification from Fleet Management system";
    private static final String COMPANY_SIGNATURE = "\n\n—\nFleet management Dashboard";
    private static final String HTML_SIGNATURE = "<br/><br/>—<br/><strong> Fleet Management Admin Dashboard</strong>";


    // SMTP error codes
    private static final String SMTP_INVALID_ADDRESS = "553-5.1.3";
    private static final String SMTP_MAILBOX_NOT_FOUND = "550-5.1.1";
    private static final String SMTP_MAILBOX_UNAVAILABLE = "550-5.1.2";





        /**
     * Send an HTML email with proper error handling and logging
     * @param to recipient email address
     * @param subject email subject
     * @param htmlBody email body (HTML)
     * @param recipientName name of the recipient (for logging)
     * @return true if email was sent successfully, false otherwise
     */
    public boolean sendHtmlWithErrorHandling(String to, String subject, String htmlBody, String recipientName) {
        

        try {
            sendHtml(to, subject, htmlBody);
            return true;
        } catch (MessagingException e) {
            String errorMessage = e.getMessage();
            
            if (errorMessage != null) {
                if (errorMessage.contains(SMTP_INVALID_ADDRESS)) {
                    logger.warning("Invalid email address for " + recipientName + ": " + to);
                } else if (errorMessage.contains(SMTP_MAILBOX_NOT_FOUND) || 
                          errorMessage.contains(SMTP_MAILBOX_UNAVAILABLE)) {
                    logger.warning("Email account does not exist for " + recipientName + ": " + to);
                } else {
                    logger.log(Level.WARNING, "Failed to send email to " + recipientName + " (" + to + ")", e);
                }
            } else {
                logger.log(Level.WARNING, "Failed to send email to " + recipientName + " (" + to + ")", e);
            }
            return false;
        }
    }
    /**
     * Send a simple text email.
     * @param to      recipient email address
     * @param subject email subject
     * @param body    email body (plain text)
     * @throws jakarta.mail.MessagingException
     */
    public void send(String to, String subject, String body) throws MessagingException {
        MimeMessage msg = new MimeMessage(mailSession);
        msg.setFrom(new InternetAddress(DEFAULT_FROM));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
        msg.setSubject(subject);
        msg.setText(body);
        Transport.send(msg);
    }

    /**
     * Send a text email using the default subject and appends a company signature.
     * @param to   recipient email address
     * @param body email body (plain text)
     * @throws jakarta.mail.MessagingException
     */
    public void sendWithSignOff(String to, String body) throws MessagingException {
        String bodyWithSignOff = body + COMPANY_SIGNATURE;
        send(to, DEFAULT_SUBJECT, bodyWithSignOff);
    }

    /**
     * Send an HTML email with custom subject and body, appending an HTML signature.
     * @param to       recipient email address
     * @param subject  email subject
     * @param htmlBody email body (HTML)
     * @throws jakarta.mail.MessagingException
     */
    public void sendHtml(String to, String subject, String htmlBody) throws MessagingException {
        MimeMessage msg = new MimeMessage(mailSession);
        msg.setFrom(new InternetAddress(DEFAULT_FROM));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
        msg.setSubject(subject);
        msg.setContent(htmlBody + HTML_SIGNATURE, "text/html; charset=UTF-8");
        Transport.send(msg);
    }

    /**
     * Send an HTML email using the default subject, appending an HTML signature.
     * @param to       recipient email address
     * @param htmlBody email body (HTML)
     * @throws jakarta.mail.MessagingException
     */
    public void sendHtmlWithSignOff(String to, String htmlBody) throws MessagingException {
        sendHtml(to, DEFAULT_SUBJECT, htmlBody);
    }
}

