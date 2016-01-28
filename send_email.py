#!/usr/bin/env python
import sys

def send_email(user, password, recipient, subject, body):
    import smtplib

    gmail_user = user
    gmail_pwd = password
    FROM = user
    TO = recipient if type(recipient) is list else [recipient]
    SUBJECT = subject
    TEXT = body

    # Prepare actual message
    message = """\From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (FROM, ", ".join(TO), SUBJECT, TEXT)
    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.ehlo()
        server.starttls()
        server.login(gmail_user, gmail_pwd)
        server.sendmail(FROM, TO, message)
        server.close()
        print 'successfully sent the mail'
    except:
        print "failed to send mail"
        
if len(sys.argv) < 6:
    print "need more arguments: " + str(sys.argv);
else:
    user=sys.argv[1];
    password=sys.argv[2];
    recipient=sys.argv[3];
    subject=sys.argv[4];
    body=sys.argv[5];
    print "goint to send email: " + str(sys.argv);