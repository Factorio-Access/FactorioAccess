import http.server
from http import HTTPStatus
import json
import urllib.parse
from pathlib import Path,PurePath
from typing import Union

_root=Path(__file__).parent.joinpath('web_root').resolve()
assert _root.is_dir()

class FA_handler(http.server.SimpleHTTPRequestHandler):
   resp=json.dumps({"test":"woot"}).encode('utf8')
   def __init__(self, request, client_address, server) -> None:
      super().__init__(request, client_address, server, directory=_root)
   def do_OPTIONS(self):
      path=self.check_path()
      if not path:
         return
      self.send_response(HTTPStatus.OK)
      #self.send_header("Access-Control-Allow-Origin","https://mods.factorio.com")
      self.send_header("Content-Length", str(0))
      self.end_headers()
   def do_HEAD(self) -> None:
      path=self.check_path()
      if not path:
         return
      if isinstance(path,urllib.parse.ParseResult):
         self.api_send_head()
         return
      return super().do_HEAD()
   def do_GET(self) -> None:
      path=self.check_path()
      if not path:
         return
      if isinstance(path,urllib.parse.ParseResult):
         self.api_send_head()
         self.wfile.write(self.resp)
         return
      return super().do_GET()
   def do_POST(self) -> None:
      path = self.check_path()
      if not path:
         return
      if isinstance(path,Path):
         self.send_response(HTTPStatus.METHOD_NOT_ALLOWED)
         self.end_headers()
         return
      self.api_send_head()
      self.wfile.write(self.resp)
   def check_path(self) -> Union[Path, urllib.parse.ParseResult, None]:
      path=urllib.parse.urlparse(self.path,'http',False)
      if path.path.startswith('/api/'):
         return path
      rel=PurePath('.'+path.path)
      maybe_file = _root.joinpath(rel).resolve()
      if maybe_file.is_relative_to(_root) and maybe_file.is_file():
         return maybe_file
      self.send_response(HTTPStatus.NOT_FOUND)
      self.end_headers()
      return False
   def api_send_head(self):
      self.send_response(HTTPStatus.OK)
      self.send_header("Access-Control-Allow-Origin","https://mods.factorio.com")
      self.send_header("Content-type", 'application/json')
      self.send_header("Content-Length", str(len(self.resp)))
      self.end_headers()

server= http.server.HTTPServer(('127.0.0.1',34197),FA_handler)
server.serve_forever()