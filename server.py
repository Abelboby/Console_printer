import socket
import time

LYRICS = """[Insert your lyrics here]
Line 2
Line 3..."""

def main():
    HOST = '0.0.0.0'  # Listen on all interfaces
    PORT = 65432
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        conn, addr = s.accept()
        with conn:
            for line in LYRICS.split('\n'):
                conn.sendall(line.encode() + b'\n')
                time.sleep(2)  # Time between lines

if __name__ == "__main__":
    main() 