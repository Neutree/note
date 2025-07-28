from http.server import BaseHTTPRequestHandler, HTTPServer
import os



yaml_config = """
proxies:
  - name: "my-trojan"
    type: trojan
    server: your.domain.com
    port: 443
    password: yourpassword
    udp: true
    sni: your.domain.com
    skip-cert-verify: true

proxy-groups:
  - name: "My_Proxy"
    type: select
    proxies:
      - "my-trojan"

rules:
  - MATCH,My_Proxy
"""

class ClashSubscriptionHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/yaml; charset=utf-8')
        self.end_headers()
        self.wfile.write(yaml_config.encode('utf-8'))

def run(server_class=HTTPServer, handler_class=ClashSubscriptionHandler, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Clash subscription server running at http://localhost:{port}/")
    httpd.serve_forever()

if __name__ == '__main__':
    run()

