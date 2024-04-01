function install_instead(e){
   e.preventDefault()
   e.target.lastChild.nodeValue="clicked"
   return false
}

let dl_links=document.querySelectorAll('a[href^="/download"]')

for(let i=0; i< dl_links.length; i++){
   let link=dl_links[i]
   link.lastChild.nodeValue=' Install via Factorio Access'
   link.addEventListener('click',install_instead)
}

p=browser.runtime.connect(null,{"name":"mod_portal"})
p.onMessage.addListener(console.log)