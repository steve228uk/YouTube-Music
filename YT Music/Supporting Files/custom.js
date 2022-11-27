window.setTimeout(function() {
  if (navigator && navigator.serviceWorker) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      for (let registration of registrations) {
        registration.unregister()
      }
      if (registrations && registration.length > 0) {
        window.location.reload()
      }
    })
  }
    
  var observer = new MutationObserver(function(mutations) {

    let bar = document.querySelector('#progress-bar');

    window.webkit.messageHandlers.observer.postMessage({
      title: document.querySelector('.ytmusic-player-bar.title').textContent,
      by: document.querySelector('.ytmusic-player-bar.byline').textContent,
      thumbnail: document.querySelector('ytmusic-player-bar .middle-controls img.image').getAttribute('src'),
      progress: parseInt(bar.getAttribute('value')),
      length: parseInt(bar.getAttribute('aria-valuemax')),
      isPlaying: document.querySelector('.play-pause-button.ytmusic-player-bar').getAttribute('title') == window.yt.msgs_.PAUSE
    })
  });
  
  observer.observe(document.querySelector('ytmusic-player-bar'), {
    attributes: true,
    characterData: true,
    childList: true,
    subtree: true,
    attributeOldValue: true,
    characterDataOldValue: true
  });

}, 1000);

