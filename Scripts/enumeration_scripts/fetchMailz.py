#!/usr/bin/env python3

import imaplib
import argparse
import getpass
import sys

def show_help():
    help_text = """
IMAP FetchMailz Tool
========================

Description:
This tool connects to an IMAP server, lists available mailboxes (directories), and fetches all emails from a selected mailbox.

Usage:
------
python fetchMailz.py -t <target_ip> --login <user:pass>

Parameters:
-----------
  -t, --target         Target IP address or hostname of the IMAP server
  --login              Login credentials in the format username:password
  --help               Show this help message and exit

Example:
--------
python fetchMailz.py -t 10.129.14.128 --login robin:robin
    """
    print(help_text)
    sys.exit(0)

def list_mailboxes(imap):
    status, mailboxes = imap.list()
    if status != 'OK':
        print("[!] Failed to retrieve mailboxes.")
        sys.exit(1)

    print("\nAvailable Mailboxes:")
    mailbox_dict = {}
    for i, box in enumerate(mailboxes):
        parts = box.decode().split(' "/" ')
        if len(parts) == 2:
            mailbox_name = parts[1].strip('"')
            print(f"  [{i}] {mailbox_name}")
            mailbox_dict[str(i)] = mailbox_name
    return mailbox_dict

def fetch_emails(imap, mailbox):
    status, _ = imap.select(mailbox)
    if status != 'OK':
        print(f"[!] Cannot select mailbox: {mailbox}")
        sys.exit(1)

    typ, data = imap.search(None, 'ALL')
    if typ != 'OK':
        print("[!] Failed to search emails.")
        sys.exit(1)

    print(f"\n[*] Fetching emails from {mailbox}...")
    for num in data[0].split():
        typ, msg_data = imap.fetch(num, '(RFC822.HEADER)')
        if typ == 'OK':
            print(f"\n--- Email #{num.decode()} Header ---")
            print(msg_data[0][1].decode(errors='ignore'))
        else:
            print(f"[!] Could not fetch email #{num.decode()}")

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--help', action='store_true')
    parser.add_argument('-t', '--target', type=str, help='Target IP/Hostname')
    parser.add_argument('--login', type=str, help='Login in format user:pass')
    args = parser.parse_args()

    if args.help or not args.login or not args.target:
        show_help()

    try:
        username, password = args.login.split(':')
    except ValueError:
        print("[!] Login format should be username:password")
        sys.exit(1)

    try:
        imap = imaplib.IMAP4_SSL(args.target)
        imap.login(username, password)
        print(f"[+] Logged in as {username}")
    except imaplib.IMAP4.error as e:
        print(f"[!] Login failed: {e}")
        sys.exit(1)

    mailboxes = list_mailboxes(imap)
    choice = input("\nSelect mailbox number to extract emails from: ")

    if choice not in mailboxes:
        print("[!] Invalid selection.")
        sys.exit(1)

    fetch_emails(imap, mailboxes[choice])
    imap.logout()

if __name__ == '__main__':
    main()
