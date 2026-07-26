"""
Threaded HTTPS CONNECT proxy — routes emulator tile requests through the host.
Run on the host; configure the Dart HttpClient to use 10.0.2.2:8888.
"""
import select
import socket
import socketserver
from http.server import BaseHTTPRequestHandler, HTTPServer


class ConnectProxy(BaseHTTPRequestHandler):
    def do_CONNECT(self):
        host, _, port = self.path.rpartition(':')
        port = int(port) if port else 443
        try:
            remote = socket.create_connection((host, port), timeout=15)
            self.send_response(200, 'Connection Established')
            self.end_headers()
            self._tunnel(self.connection, remote)
        except Exception as e:
            try:
                self.send_error(502, str(e))
            except Exception:
                pass

    def _tunnel(self, client, server):
        sockets = [client, server]
        while True:
            try:
                r, _, _ = select.select(sockets, [], [], 60)
                if not r:
                    break
                for s in r:
                    other = server if s is client else client
                    data = s.recv(65536)
                    if not data:
                        return
                    other.sendall(data)
            except Exception:
                break

    def log_message(self, fmt, *args):
        print(f"[proxy] {fmt % args}", flush=True)


class ThreadingHTTPServer(socketserver.ThreadingMixIn, HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


if __name__ == '__main__':
    PORT = 8888
    server = ThreadingHTTPServer(('0.0.0.0', PORT), ConnectProxy)
    print(f"Threaded tile proxy on 0.0.0.0:{PORT}", flush=True)
    server.serve_forever()
