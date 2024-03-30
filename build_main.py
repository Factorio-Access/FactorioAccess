import os
import sys
import shutil
from pathlib import Path
venv = 'venv'

venv_python = os.path.join('.', venv)

if sys.platform == 'win32':
    venv_python += '\Scripts\python.exe'
else:
    venv_python += '/bin/python3'


linux_hidden_modules=['espeak','python_espeak-0.5.egg-info','speechd_config','speechd']
system_packages="/usr/lib/python3/dist-packages/"
hidden_imports=[]

if not os.path.isdir('./'+venv):
    print('"'+sys.executable+'" -m venv '+venv)
    os.system('"'+sys.executable+'" -m venv '+venv)
    print(venv_python)
    os.system(venv_python+' -m pip install -r requirements.txt pyinstaller')
    if sys.platform == 'linux':
        full_paths=' '.join([system_packages+mod for mod in linux_hidden_modules])
        copy_cmd="cp -r "+full_paths+' ./'+venv+'/lib/python3.*/site-packages/'
        print(copy_cmd)
        if os.system(copy_cmd):
            raise RuntimeError()
if sys.platform == 'linux':
    hidden_imports+=linux_hidden_modules


try:
    p=Path("./mods/FactorioAccess/locale")
    base=Path("./r/locale")
    if not base.is_dir():
        raise Exception("missing resource locale folder")
    for loc in p.iterdir():
        file_to_copy=loc.joinpath('launcher.cfg')
        if not file_to_copy.is_file():
            continue
        dest=base.joinpath(loc.name+'.cfg')
        shutil.copyfile(file_to_copy,dest)

except Exception as e:
    print(e)
    input("WARNING: failed to copy locale files")

if os.path.isfile('launcher.spec'):
    os.system(venv_python+' -m PyInstaller launcher.spec')
else:
    hi="".join([' --hidden-import='+imp for imp in hidden_imports])
    excludes='FixTk tcl tk _tkinter tkinter Tkinter PIL'.split(' ')
    ex="".join([" --exclude-module "+m for m in excludes])
    os.system(venv_python+' -m PyInstaller --onefile'+hi+' main.py -n launcher --add-data="./r:./r"'+ex)
