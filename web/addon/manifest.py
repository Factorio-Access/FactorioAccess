from sys import platform
ff = platform =='linux'
with open(__file__[:-2]+'json','w') as fp:
    fp.write(f'''
{{
   "manifest_version": { '2' if ff else '3'},
   "name": "FA install mods",
   "version": "0.1",
 
   "content_scripts": [
      {{
         "matches": ["https://mods.factorio.com/*"],
         "js": ["stay_connected.js","mod_portal.js"]
      }},
      {{
         "matches": ["http://127.0.0.1{'' if ff else ':34197'}/*"],
         "js": ["stay_connected.js","FA.js"]
      }}
   ],
   "background": {{
      { '"scripts": [' if ff else '"service_worker":'}
         "background.js"
      { ']' if ff else ''}
   }}
}}
''')