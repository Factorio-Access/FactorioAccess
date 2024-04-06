import re
from typing import Iterable, Union
from collections import defaultdict,UserDict
from collections.abc import Iterator
import os
import zipfile
from pathlib import Path
import json

from fa_arg_parse import dprint
import config

localised_str = Union[str,Iterator['localised_str']]

def get_control(name:str) ->list[str]:
    if input_type==joy:
        hasalt=name.endswith(alt)
        if hasalt:
            name=name.removesuffix(alt)
        if not name.endswith(con):
            name+=con
        if hasalt:
            name+=alt
    with config.current_conf:
        return config.current_conf.get_setting('controls',name).split(' + ')
            

def t_control(control_name,alt_type=0):
    cont=get_control(control_name)
    if len(cont)==1 and cont[0]=='':
        return translate(['controls.not-set'])
    return "+".join((translate(["?",['control-key.'+key.lower()],key]) for key in cont))

def t_modifer(control_name):
    cont=get_control(control_name)
    if len(cont)<=1:
        return translate(['no-modifier-selected'])
    return ''.join((translate(['control-keys.'+key] for key in cont[:-1])))
def t_alt_control(alt_type,control_name):
    return t_control(control_name,alt_type)
def t_move():
    pass
def t_entity(name):
    pass
def t_item(name):
    pass
def t_tile(name):
    pass
def t_fluid(name):
    pass

def return_blank():
    return ''

knm = 'keyboard-and-mouse'
joy = 'game-controller'

con = '-controller'
alt = '-alternate'

input_type=knm
def do_controller_check():
    global input_type
    try:
        with config.current_conf:
            input_type = config.input.input_method
    except:
        pass



replacements={
    '__CONRTOL__name__'                :t_control,
    '__CONRTOL__MODIFIER__name__'      :t_modifer,
    '__CONTROL_STYLE_BEGIN__'          :return_blank,
    '__CONTROL_STYLE_END__'            :return_blank,
    '__CONTROL_LEFT_CLICK__'           :{
                                        knm:['control-keys.mouse-button-1'],
                                        joy:['control-keys.controller-b'],
                                        },
    '__CONTROL_RIGHT_CLICK__'          :{
                                        knm:['control-keys.mouse-button-2'],
                                        joy:['control-keys.controller-x'],
                                        },
    '__CONTROL_KEY_SHIFT__'            :{
                                        knm:['control-keys.shift'],
                                        joy:['control-keys.controller-leftshoulder'],
                                        },
    '__CONTROL_KEY_CTRL__'             :{
                                        knm:['control-keys.control'],
                                        joy:['control-keys.controller-rightshoulder'],
                                        },
    '__ALT_CONTROL_LEFT_CLICK__n__'    :{
                                        knm:['control-keys.mouse-button-1-alt-n'],
                                        joy:['control-keys.controller-button-alt-n',['control-keys.controller-b']],
                                        },
    '__ALT_CONTROL_RIGHT_CLICK__n__'   :{
                                        knm:['control-keys.mouse-button-2-alt-n'],
                                        joy:['control-keys.controller-button-alt-n',['control-keys.controller-x']],
                                        },
    '__REMARK_COLOR_BEGIN__'           :return_blank,
    '__REMARK_COLOR_END__'             :return_blank,
    '__ALT_CONTROL__n__name__'         :t_alt_control,
    '__CONTROL_MOVE__'                 :t_move,
    '__ENTITY__name__'                 :t_entity,
    '__ITEM__name__'                   :t_item,
    '__TILE__name__'                   :t_tile,
    '__FLUID__name__'                  :t_fluid,
}
repalecement_functions={}
for replace,r_with in replacements.items():
    key, *args=[p for p in replace.split('__') if p]
    if type(r_with) == dict:
        if 'n' in args:
            r_with=lambda n,d=r_with:do_special(d,n)
        else:
            r_with=lambda d=r_with:do_special(d)
    repalecement_functions[key]=(len(args),r_with)

def do_special(special,n=0):
    return translate(special[input_type],n)

def translate(l_str:localised_str,n=0,error=False):
    if type(l_str) == str:
        return l_str
    try:
        key, *args = l_str
    except:
        return str(l_str)
    if key=='':
        return ''.join((translate(arg) for arg in args))
    if key=='?':
        for attempt in args:
            res=translate(attempt,error=True)
            if res is not None:
                return res
        return translate(args[-1])
    try:
        cat,key = key.split('.',1)
    except:
        cat=''
    if n:
        key=re.sub(r'\bn\b',str(n),key)
    if key not in translation_table[cat]:
        if error:
            return None
        return f'Unknown key: "{cat}.{key}"'
    return expand(translation_table[cat][key],args)
    

translation_table=defaultdict(dict)

class translated_args(dict):
    def __init__(self,args:list[localised_str]):
        self.args=args
        super().__init__()
    def __missing__(self,key):
        self[key]=translate(self.args[int(key)-1])
        return self[key]

def expand(template:str,args:list[localised_str] = []):
    parts=template.split('__')
    return expand_r(parts,translated_args(args))

def expand_r(parts:list[str],targs:translated_args,in_plural=False):
    ret=''
    stray__ =False
    while parts:
        p=parts.pop(0)
        if p in repalecement_functions:
            mrf=repalecement_functions[p]
            args=[parts.pop(0) for _ in range(mrf[0])]
            ret+=mrf[1](*args)
        elif 'plural_for_parameter_' in p:
            sub_parts=p.split('_',4)
            my_num=targs[sub_parts[3]]
            remaining=sub_parts[4]
            assert remaining[0]=='{',"Unexpected start of plural. Expected {"
            remaining=remaining[1:]
            matched=False
            while remaining:
                condition, remaining = remaining.split('=',1)
                parts.insert(0,remaining)
                temp_res, remaining = expand_r(parts,targs,True)
                if not matched:
                    matched=True
                    for cond in condition.split(','):
                        if cond == 'rest':
                            break
                        if my_num==cond:
                            break
                        if 'ends in ' in cond:
                            check=cond[8:]
                            if my_num.endswith(check):
                                break
                    else:
                        matched=False
                    if matched:
                        ret+=temp_res
        elif p.isdigit():
            ret+=targs[p]
        else:
            if '|' in p or '}' in p and in_plural:
                p,add_back = re.split(r'}|\|',p,1)
                ret+=p
                return ret,add_back
            if stray__:
                ret+='__'
            ret+=p
            stray__=True
            continue
        stray__=False
    return ret
            

        
        

fancy=re.compile(r'[*.?()\[\]]')

def get_mod_path_parts(path: Union[zipfile.Path , Path]):
    import fa_paths
    if isinstance(path,Path):
        try:
            return path.relative_to(fa_paths.MODS).parts
        except:
            pass
        return path.relative_to(fa_paths.READ_DIR).parts
    parts=[]
    while isinstance(path.parent,zipfile.Path):
        parts.append(path.name)
        path = path.parent
    return tuple(parts[::-1])

def iterate_over_mods(re_filter:re.Pattern[str] =None) -> Iterator[Path]:
    import fa_paths
    if re_filter:
        for mod_path in iterate_over_mods():
            if re_filter.fullmatch(mod_path.name):
                yield mod_path
        return
    base_path = fa_paths.READ_DIR
    for base_core in ['core','base']:
        yield base_path.joinpath(base_core)
    yield from fa_paths.MODS.iterdir()
    

def mod_re_files_sub(parts:list[str],path: Union[zipfile.Path , Path]):
    if not path.exists():
        return
    if not parts:
        if path.is_file():
            yield path
        return
    part=parts[0]
    if not fancy.search(part):
        yield from mod_re_files_sub(parts[1:],path.joinpath(part))
        return
    myre=re.compile(part)
    for path_part in path.iterdir():
        if myre.fullmatch(path_part.name):
            yield from mod_re_files_sub(parts[1:],path_part)

def iterate_over_this_mods_files(parts:list[str],mod_path:Path):
    if mod_path.is_file():
        if not zipfile.is_zipfile(mod_path):
            return
        mod_path = zipfile.Path(mod_path)
        mod_path = next(mod_path.iterdir())
    yield from mod_re_files_sub(parts,mod_path)

def iterate_over_mod_files(inner_re_path:str,mod_filter:re.Pattern[str] =None):
    parts=inner_re_path.split('/')
    for mod in iterate_over_mods(mod_filter):
        yield from iterate_over_this_mods_files(parts,mod)

def read_cfg(fp :Iterable[str],conf=False,ret=defaultdict(dict)):
    name=''
    while True:
        current_cat=ret[name]
        for line in fp:
            if line[0]=='[':
                name = line[1:line.find(']')].strip()
                break
            part = line.split('=',1)
            if len(part)==2:
                key=part[0]
                if conf:
                    key=key.lstrip('; ')
                if key[0]=='#':
                    continue
                if key[0]==';':
                    continue
                current_cat[key]=part[1].rstrip().replace(r'\n','\n')
        else:
            return ret

check_cats={
   "multiplayer-lobby":["config-output","config-help","gui-multiplayer-lobby"],
   "map-view":["gui-map-view-settings"],
   "controls":["controls"],
   "graphics":["gui-graphics-settings"],
   "interface":["gui-interface-settings"],
   "other":["gui-other-settings"],
   "sound":["gui-sound-settings"],
   "general":["gui-interface-settings"]
}


def check_config_locale():
    import fa_paths
    with open(os.path.join(fa_paths.READ_DIR,'core/locale/en/core.cfg')) as fp:
        translations = read_cfg(fp)
    with open(os.path.join(fa_paths.CONFIG)) as fp:
        config = read_cfg(fp,conf=True)
    cross_cats=defaultdict(lambda :defaultdict(list))
    for cat, confs in config.items():
        if cat in check_cats:
            t_to_check={tcat:tlist for tcat,tlist in translations.items() if tcat in check_cats[cat]}
        else:
            t_to_check={}
        for config_key in confs.keys():
            if config_key[-12:] == '-alternative':
                continue
            found=False
            for tcat, trans in t_to_check.items():            
                if config_key in trans:
                    found=True
                    break
            if not found:
                for tcat, trans in translations.items():            
                    if config_key in trans:
                        cross_cats[cat][tcat]+=[(config_key,trans[config_key])]
                        found=True
                if not found:
                    print(f"missing:{cat}.{config_key}")
    for ccat, tcats in cross_cats.items():
        print(ccat)
        for tcat,count in tcats.items():
            print('\t',tcat,count)


def maybe_load(path:Path):
    try:
        with path.open(encoding='utf8') as fp:
            read_cfg(fp,ret=translation_table)
    except FileNotFoundError:
        pass

def load_init(code):
    cfg=Path(__file__).parent.joinpath('r','locale',code+'.cfg')
    maybe_load(cfg)

def load_full(code):
    load_init(code)
    from fa_paths import READ_DIR
    cfg=READ_DIR.joinpath("core","locale",code,'core.cfg')
    maybe_load(cfg)
    import mods
    with mods.mod_manager:
        for cfg in mods.mod_manager.iter_mod_files("locale/"+code+"/.*.cfg"):
            maybe_load(cfg)
    

def get_langs():
    lang={}
    regstr=r'locale/([\w-]+)/info.json'
    reg=re.compile(regstr)
    from fa_paths import READ_DIR
    locs=READ_DIR.joinpath('core','locale')
    for path in locs.iterdir():
        code = path.name
        with path.joinpath('info.json').open(encoding='utf8') as fp: 
            info=json.load(fp)
        if 'language-name' in info:
            lang[code]=info['language-name']
    return lang

def tprint(*args,**kargs):
    print(*(translate(arg) for arg in args),**kargs)

code='en'
load_init('en')
def check_lang():
    global code
    load_full('en')
    with config.current_conf:
        code = config.general.locale
        if not code or code=='auto':
            import locale
            import fa_menu
            import sys
            if  True:# getattr(sys, 'frozen', False) and sys.platform == "WIN":
                import ctypes
                loc = locale.windows_locale[ ctypes.windll.kernel32.GetUserDefaultUILanguage() ]
            else:
                loc,enc = locale.getlocale()
            langs= get_langs()
            short_list=[]
            if loc is not None and len(loc)>1:
                for code, lang in langs.items():
                    if loc.startswith(code) or lang in loc:
                        short_list.append(code)
            if len(short_list):
                if len(short_list)==1:
                    code=short_list[0]
                    load_full(code)
                    op=fa_menu.select_option([
                        ('gui.confirm',),
                        ('fa-l.list-all-langs',)],
                        ('fa-l.guessed-language',langs[code]))
                    if op==0:
                        config.general.locale = code
                        return
                else:
                    dprint("We got a short list for langs",short_list)
            lang_op=fa_menu.select_option(langs.values(),('gui-interface-settings.locale',))
            config.general.locale = list(langs.keys())[lang_op]
        load_full(config.general.locale)


if __name__ == "__main__":
    check_lang()