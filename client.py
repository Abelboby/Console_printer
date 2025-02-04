import socket
import time
import os

def clear_screen():
    os.system('cls')  # Clears CMD screen

def main():
    HOST = input("Enter server IP: ")
    PORT = 65432
    
    clear_screen()
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        while True:
            data = s.recv(1024)
            if not data:
                break
            line = data.decode().strip()
            for char in line:
                print(char, end='', flush=True)
                time.sleep(0.1)  # Speed of letter appearance
            print()

if __name__ == "__main__":
    main() 