
import fa_menu
import mods

class _mod_menu(fa_menu.menu_item):
   def __call__(self, *args):
      with mods.mod_manager:
         return super().__call__(*args)
class enable_disable_submenu(fa_menu.setting_menu_bool):
    def get_names(self, *args):
       self.val = mods.mod_manager.dict[args[-1]]['enabled']
       return super().get_names(*args)
    def __call__(self,*args):
         super().__call__(*args)
         if self.val:
            mods.mod_manager.enable(args[0])
         else:
            mods.mod_manager.disable(args[0])
         return 0

def get_names(*args):
   if len(args):
      return args[-1]
   return get_mod_list()
def get_mod_list():
   return {("",name," (",("gui-map-generator.enabled",) if data['enabled'] else ("gui-mod-info.status-disabled",),")"):name for name,data in mods.mod_manager.dict.items()}

enable_menu_setting=enable_disable_submenu(("gui-map-generator.enabled",),None,True,True)
mod_menu = _mod_menu(("gui-menu.mods",),{get_names:{"enabled":enable_menu_setting}})