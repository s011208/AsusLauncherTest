#!/usr/bin/env python
import sys
import smtplib

def send_email(user, password, recipient, subject, body):

    gmail_sender = user
    gmail_passwd = password

    TO = recipient if type(recipient) is list else [recipient]
    SUBJECT = subject
    TEXT = body

    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()
    server.starttls()
    server.login(gmail_sender, gmail_passwd)

    BODY = '\r\n'.join(['To: %s' % TO, 'From: %s' % gmail_sender, 'Subject: %s' % SUBJECT, '', TEXT])

    try:
        server.sendmail(gmail_sender, [TO], BODY)
        print ('email sent')
    except:
        print ('error sending mail')

    server.quit()
        
if len(sys.argv) < 6:
    print ("need more arguments: ") + str(sys.argv);
else:
    user=sys.argv[1];
    password=sys.argv[2];
    recipient=sys.argv[3];
    subject=sys.argv[4];
    body=sys.argv[5];
    print ("goint to send email: " + str(sys.argv));
    send_email(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]);