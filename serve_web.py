import http.server
import os

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if not os.path.exists(self.translate_path(self.path)):
            self.path = '/'
        return super().do_GET()

if __name__ == '__main__':
    os.chdir(os.path.join(os.path.dirname(__file__), 'build', 'web'))
    server = http.server.HTTPServer(('localhost', 8080), SPAHandler)
    print('Serving Rever at http://localhost:8080')
    server.serve_forever()
