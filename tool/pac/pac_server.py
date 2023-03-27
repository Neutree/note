'''
    pac_server.py
    @author neucrack
    @license MIT
'''

from flask import Flask, request, send_file
import os
app = Flask(__name__)
@app.route("/autoproxy_socks5_1088.pac")
def proxy_pac():
    return send_file(os.path.join(os.path.dirname(__file__), "autoproxy_socks5_1088.pac"), mimetype="application/x-ns-proxy-autoconfig")

@app.route("/autoproxy_socks5_1080.pac")
def proxy_pac():
    return send_file(os.path.join(os.path.dirname(__file__), "autoproxy_socks5_1080.pac"), mimetype="application/x-ns-proxy-autoconfig")

@app.route("/")
def index():
    return "hello"
if __name__ == "__main__":
    app.run("0.0.0.0", 6789)

