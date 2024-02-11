# python3 passwordCracker.py

import hashlib
import base64
import os
import threading
import time

class PasswordCracker:
    @staticmethod
    def hash_password(hash_type, salt, value):
        if not hash_type:
            hash_type = "SHA1"
        if not salt:
            salt_bytes = os.urandom(16)
            salt = base64.urlsafe_b64encode(salt_bytes).decode("utf-8")
        hash_biz = hashlib.new(hash_type)
        hash_biz.update(salt.encode("utf-8"))
        hash_biz.update(value)
        hashed_bytes = hash_biz.digest()
        result = f"${hash_type}${salt}${base64.urlsafe_b64encode(hashed_bytes).decode('utf-8').rstrip('=')}"
        return result

def check_password(value, search, hash_type, salt, results):
    hashed_password = PasswordCracker.hash_password(hash_type, salt, value.encode("utf-8"))
    if hashed_password == search:
        print(f" [👌] Hash Matched! \n\nPassword Found: {value}, hash: {hashed_password}")
        results.append(True)
        return True
    return False

def show_loading_spinner():
    spinner_frames = ["◐", "◓", "◑", "◒"]
    i = 0
    while not done.is_set():
        print(f"\rChecking passwords {spinner_frames[i]}", end="", flush=True)
        time.sleep(0.1)
        i = (i + 1) % len(spinner_frames)

def main():
    hash_type = "SHA1"
    salt = "d"                                                   
    search = "$SHA1$d$uP0_QaVBpDWFeo8-dRzDqRwXQ2I"
    wordlist = "/usr/share/wordlists/rockyou.txt"

    results = []
    global done
    done = threading.Event()
    threading.Thread(target=show_loading_spinner).start()

    with open(wordlist, 'r', encoding='latin-1') as password_list:
        for password in password_list:
            value = password.strip()
            if check_password(value, search, hash_type, salt, results):
                done.set()
                break

    if not any(results):
        print("\n[❌] Password not found in the given timeout.")

if __name__ == "__main__":
    main()