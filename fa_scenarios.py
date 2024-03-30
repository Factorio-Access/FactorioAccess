import re
from collections import defaultdict, namedtuple
import json

import fa_paths
import translations
from launch_and_monitor import launch_with_params
import fa_menu

Scenario = namedtuple('Scenario','order start_key name description')

def get_scenario_from_path(path):
   with open(path,encoding='utf8') as fp:
      json_desc=json.load(fp)
   parts=translations.get_mod_path_parts(path)
   key = parts[0]+'/'+parts[2]
   locale=path.parent.joinpath('locale')
   if not locale:
      return None
   temp_translations=defaultdict(dict)
   for code in ['en',translations.code]:
      sub=locale.joinpath(code)
      if not sub.is_dir():
         continue
      for possible_cfg in sub.iterdir():
         if not possible_cfg.name.endswith('.cfg'):
            continue
         with open(possible_cfg,encoding='utf8') as fp:
            translations.read_cfg(fp,ret=temp_translations)
   return Scenario(
         json_desc['order'],
         key,
         temp_translations['']['scenario-name'],
         temp_translations['']['description'])

def get_freeplay():
   return get_scenario_from_path(fa_paths.READ_DIR.joinpath('base','scenarios','freeplay','description.json'))

def get_scenarios(m_scenario=None):
   if m_scenario:
      return m_scenario.name
   scenarios=[]
   for path in translations.iterate_over_mod_files('scenarios/.*/description.json',re.compile(r'FactorioAccess.*')):
      scenario=get_scenario_from_path(path)
      if scenario:
         scenarios.append(scenario)
   scenarios.sort()
   return {s.name:s for s in scenarios}

def launch_scenario(scenario:Scenario):
   return launch_with_params(['--load-scenario',scenario.start_key],)

def scenario_name(*args):
   return args[-1].name
def scenario_desc(*args):
   return args[-1].description

pre_launch_scenario = fa_menu.menu_item(get_scenarios,{("gui-new-game.play",):launch_scenario},scenario_desc)

if __name__ == "__main__":
   print(get_scenarios())