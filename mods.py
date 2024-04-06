import json
import re
import zipfile
import pathlib
from urllib import parse
from collections import defaultdict
from typing import Iterator, Union

import config
from fa_paths import MODS,READ_DIR
from fa_arg_parse import dprint
from update_factorio import download, get_credentials,opener

_mod_portal='https://mods.factorio.com'

class mod(object):
   def __init__(self,path:Union[zipfile.Path , pathlib.Path]) -> None:
      if path.is_file():
         if not zipfile.is_zipfile(path):
            raise ValueError(f"non zip file {path} failed mod init")
         self.folder_path = next(zipfile.Path(path).iterdir())
      else:
         self.folder_path = path
      info_path = self.folder_path.joinpath("info.json")
      if not info_path.is_file():
         raise ValueError(f"no info file in {self.folder_path}; failed mod init")
      with info_path.open(encoding='utf8') as fp:
         self.info = json.load(fp)
      i=self.info
      self.name = i["name"]
      self.version = i["version"]

      re_name=f"{i['name']}(_{i['version']})?(.zip)?"
      if not re.fullmatch(re_name,path.stem):
         raise ValueError(f"mod path {path} does not match info {i['name']} init")
   @staticmethod   
   def _iter_files_sub(parts:list[Union[str,re.Pattern]],path: Union[zipfile.Path , pathlib.Path]):
      if not path.exists():
         return
      if not parts:
         if path.is_file():
               yield path
         return
      part=parts[0]
      if isinstance(part,str):
         yield from mod._iter_files_sub(parts[1:],path.joinpath(part))
         return
      for path_part in path.iterdir():
         if part.fullmatch(path_part.name):
               yield from mod._iter_files_sub(parts[1:],path_part)
   
   def iterate_mods_files(self,parts:list[Union[str,re.Pattern]]):
      yield from self._iter_files_sub(parts,self.folder_path)


class __mod_manager(object):
   MOD_LIST_FILE = MODS.joinpath('mod-list.json')
   def __init__(self) -> None:
      self.dict = None
      with config.current_conf:
         self.new_enabled = config.other.enable_new_mods == "true"
   def __enter__(self) -> None:
      assert self.dict==None , "Already in a with statement"
      with open(self.MOD_LIST_FILE,'r',encoding='utf8') as fp:
         data = json.load(fp)
      self.dict = { m['name']:m for m in data['mods']}
      
      self.modified = False
      self.by_name_version=defaultdict(dict)
      self.allmods:list[mod] = []
      for mod_path in self._iterate_over_all_mod_paths():
         self.add_mod(mod_path)

      pre_size=len(self.dict)
      self.dict={name:m for name,m in self.dict.items() if name in self.by_name_version}
      if len(self.dict) != pre_size:
         self.modified = True

   def __exit__(self,*args) -> None:
      if self.modified:
         data={'mods':[m for m in self.dict.values()]}
         with open(self.MOD_LIST_FILE,'w',encoding='utf8') as fp:
            json.dump(data, fp, ensure_ascii=False, indent=2)
      self.dict = None

   def enabled(self) -> list[str]:
      return [name for name,m in self.dict.items() if m['enabled']]
   
   def set_enabled(self,name:str,val:bool) -> None:
      assert self.dict
      self.dict[name]['enabled']=val
      self.modified = True

   def enable(self,name) -> None:
      self.set_enabled(name,True)

   def disable(self,name) -> None:
      self.set_enabled(name,False)

   def select_version(self,name,version):
      self.dict[name]['version']=version
      self.modified = True

   def install_mod(self,name,version=''):
      with opener.open(f"{_mod_portal}/api/mods/{name}") as fp:
         info=json.load(fp)         
      for r in info['releases']:
         if r['version'] == version:
            release=r
            break
      else:
         release=info['releases'][-1]
      self.download_mod(release)
      
   def download_mod(self,release):
      cred=get_credentials()
      url=_mod_portal+release['download_url']+'?'+parse.urlencode(cred)
      new_path=MODS.joinpath(release['file_name'])
      download( url, new_path)
      self.add_mod(new_path)
   
   def add_mod(self,mod_path):
      try:
         m=mod(mod_path)
      except Exception as e:
         dprint(e)
         return
      self.allmods.append(m)
      self.by_name_version[m.name][m.version]=m #TODO: check duplicates?
      if self.dict and m.name not in self.dict:
         self.dict[m.name]={
            "name":m.name,
            "enabled":self.new_enabled
         }
         self.modified = True


   fancy=re.compile(r'[*.?()\[\]]')

   def get_mod_path_parts(self,path: Union[zipfile.Path , pathlib.Path]):
      if isinstance(path,pathlib.Path):
         try:
               return path.relative_to(MODS).parts
         except:
               pass
         return path.relative_to(READ_DIR).parts
      parts=[]
      while isinstance(path.parent,zipfile.Path):
         parts.append(path.name)
         path = path.parent
      return tuple(parts[::-1])
   def _iterate_over_all_mod_paths(self) -> Iterator[pathlib.Path]:
      for base_core in ['core','base']:
         yield READ_DIR.joinpath(base_core)
      yield from MODS.iterdir()
   
   def iter_mods(self,require_enabled=True,mod_filter:re.Pattern =None) -> Iterator[mod]:
      for m in self.dict.values():
         if m['enabled'] or not require_enabled:
            name=m['name']
            if mod_filter and not mod_filter.fullmatch(name):
               continue
            ver='version' in m and m['version'] or max(self.by_name_version[name])
            yield self.by_name_version[name][ver]

   def iter_mod_files(self,inner_re_path:str,require_enabled=True,mod_filter:re.Pattern =None) -> Iterator[Union[zipfile.Path , pathlib.Path]]:
      parts=inner_re_path.split('/')
      parts=[part if not self.fancy.search(part) else re.compile(part) for part in parts]
      for mod in self.iter_mods(require_enabled,mod_filter):
         yield from mod.iterate_mods_files(parts)


mod_manager=__mod_manager()


if __name__ == "__main__":
   with mod_manager:
      pass
      #mod_manager.install_mod('stop-on-red')
      