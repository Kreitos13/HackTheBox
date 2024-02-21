import socket
import sys

def brute_force_smtp(ip, port, user_file):
    try:
        with open(user_file, 'r') as f:
            users = f.readlines()
        
        users = [user.strip() for user in users]
        
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((ip, port))
        banner = s.recv(1024).decode()
        print("[+] Connected to", ip)
        print("[+] Server response:", banner)
        
        width = max(len(user) for user in users) + 2
        
        # Iterar sobre cada usuario y enviar el comando VRFY al servidor
        for user in users:
            s.sendall("VRFY {}\r\n".format(user).encode())
            response = s.recv(1024).decode()
            print("[+] User:", "{:<{}}".format(user, width), "Response:", response.strip())
        
        s.close()
    except FileNotFoundError:
        print("[-] Error: File not found.")
    except PermissionError:
        print("[-] Error: Permission denied to open the file.")
    except Exception as e:
        print("[-] Error:", str(e))

def print_banner():
    banner = """
    sSSs .S_SsS_S.   sdSS_SSSSSSbs   .S_sSSs            sSSs   .S_sSSs     .S       S.    .S_SsS_S.   
 d&&SP  .SS~S*S~SS.  YSSS~S%SSSSSP  .SS~YS&&b          d&&SP  .SS~YS&&b   .SS       SS.  .SS~S*S~SS.  
d%S'    S%S `Y' S%S       S%S       S%S   `S&b        d%S'    S%S   `Sb   S%S       S%S  S%S `Y' S%S  
S%|     S%S     S%S       S%S       S%S    S%S        S%S     S%S    S%S  S%S       S%S  S%S     S%S  
S&S     S%S     S%S       S&S       S%S    d*S        S&S     S%S    S&S  S&S       S&S  S%S     S%S  
Y&Ss    S&S     S&S       S&S       S&S   .S*S        S&S_Ss  S&S    S&S  S&S       S&S  S&S     S&S  
`S&&S   S&S     S&S       S&S       S&S_sdSSS         S&S~SP  S&S    S&S  S&S       S&S  S&S     S&S  
  `S*S  S&S     S&S       S&S       S&S~YSSY          S&S     S&S    S&S  S&S       S&S  S&S     S&S  
   l*S  S*S     S*S       S*S       S*S               S*b     S*S    S*S  S*b       d*S  S*S     S*S  
  .S*P  S*S     S*S       S*S       S*S               S*S.    S*S    S*S  S*S.     .S*S  S*S     S*S  
sSS*S   S*S     S*S       S*S       S*S                SSSbs  S*S    S*S   SSSbs_sdSSS   S*S     S*S  
YSS'    SSS     S*S       S*S       S*S                 YSSP  S*S    SSS    YSSP~YSSY    SSS     S*S  
                SP        SP        SP                        SP                                 SP   
                Y         Y         Y                         Y                                  Y    
                                                                                            Kr31tos
    """
    print(banner)

# Verificar la cantidad de argumentos de línea de comandos
if len(sys.argv) != 3:
    print("Usage: python smpt_enum.py <IP_address> <user_file>")
    sys.exit(1)

print_banner()

ip = sys.argv[1]
user_file = sys.argv[2]

port = 25

brute_force_smtp(ip, port, user_file)

    