package com.socialmedia.util;

import java.util.Properties;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailSender {

    // IMPORTANT: Replace these with your real Gmail credentials
    private static final String DEFAULT_EMAIL = "shivendramane4@gmail.com";
    private static final String DEFAULT_PASSWORD = "mznl gcst nsuh oocd";

    private static final String SMTP_EMAIL = System.getenv("SMTP_EMAIL") != null ? 
            System.getenv("SMTP_EMAIL") : DEFAULT_EMAIL;
    private static final String SMTP_PASSWORD = System.getenv("SMTP_PASSWORD") != null ? 
            System.getenv("SMTP_PASSWORD") : DEFAULT_PASSWORD;

    public static boolean sendOtpEmail(String recipientEmail, String otp) {
        System.out.println("Trying to send real OTP email to: " + recipientEmail);

        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_EMAIL, SMTP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Your SocialConnect OTP Configuration");
            message.setText("Welcome to SocialConnect!\n\nYour registration OTP is: " + otp + "\n\nThis OTP will expire in 5 minutes.");

            Transport.send(message);
            System.out.println("Email sent successfully!");
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}
