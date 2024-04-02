function forward_mod_portal_message(message){
   for(let pp of FA_connections){
      pp.postMessage(message)
      break
   }
}

function lost_mod_portal(p){
   mod_portal_open_ports.delete(p)
}

function lost_FA(p){
   FA_connections.delete(p)
   if(!FA_connections.size){
      for(let pp of mod_portal_open_ports){
         pp.postMessage({"FA":false})
      }
   }
}


mod_portal_open_ports = new Set()
FA_connections = new Set()

function connected(p) {
   if( p.sender.id != browser.runtime.id ){
      p.disconnect()
   }
   if(p.name == "mod_portal"){
      mod_portal_open_ports.add(p)
      p.onMessage.addListener(forward_mod_portal_message)
      p.onDisconnect.addListener(lost_mod_portal)
      p.postMessage({"FA":!!FA_connections.size})
   }else if(p.name == "FA"){
      //allow any orgin since people can be using hostnames
      announce= !FA_connections.size
      FA_connections.add(p)
      p.onDisconnect.addListener(lost_FA)
      if(announce){
         for(let pp of mod_portal_open_ports){
            pp.postMessage({"FA":true})
         }
      }
   }else{
      p.disconnect()
   }
}

browser.runtime.onConnect.addListener(connected);