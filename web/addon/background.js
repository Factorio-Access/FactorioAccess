function forward_mod_portal_message(message){
   console.log(message)
}

function lost_mod_portal(p){
   mod_portal_open_ports.delete(p)
}

function lost_FA(p){
   FA_connections.delete(p)
   if(!FA_connections.size){
      for(pp of mod_portal_open_ports){
         pp.postMessage({"FA":false})
      }
   }
}


mod_portal_open_ports = new Set()
FA_connections = new Set()

function connected(p) {
   portFromCS = p;
   if(p.name == "mod_portal"){
      if( p.sender.id != browser.runtime.id ){
         p.disconnect()
      }
      mod_portal_open_ports.add(p)
      p.onMessage.addListener(forward_mod_portal_message)
      p.onDisconnect.addListener(lost_mod_portal)
   }else if(p.name == "FA"){
      //allow any orgin sinse people can be using hostnames
      announce= !FA_connections.size
      FA_connections.add(p)
      p.onDisconnect.addListener(lost_FA)
      if(announce){
         for(pp in mod_portal_open_ports){
            pp.postMessage({"FA":true})
         }
      }
   }else{
      p.disconnect()
   }
}

browser.runtime.onConnect.addListener(connected);