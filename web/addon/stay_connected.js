'use-strict';
browser=browser||chrome

globalThis.my_name = location.origin === "https://mods.factorio.com" ? "mod_portal" : "FA"

globalThis.p=null

function reconnect(){
   p=browser.runtime.connect(null,{"name":my_name})
   p.onDisconnect.addListener(reconnect)
}
setInterval(()=>{
   if( p && ! p.error){
      return
   }
   reconnect()
},295000)
reconnect()