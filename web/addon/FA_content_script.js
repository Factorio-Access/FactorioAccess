p=browser.runtime.connect(null,{"name":"FA"})
p.onMessage.addListener(console.log)