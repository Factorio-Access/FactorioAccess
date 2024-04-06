FA_status=false

let dl_links=document.querySelectorAll('a[href^="/download"]')

function install_instead(e){
   if(!FA_status){
      return true
   }
   e.preventDefault()
   let link = e.target
   let filename=link.attributes.filename.value
   let target=link.href
   p.postMessage({filename,target})
   return false
}
dl_links.forEach((link)=>{
    link.addEventListener('click',install_instead)
})

function unpdate_link_text(){
   let new_text = FA_status ? ' Install via Factorio Access' : ' Download'
   dl_links.forEach(link => link.lastChild.nodeValue = new_text)
}

p.onMessage.addListener((message)=>{
   FA_status = message.FA
   unpdate_link_text()
})