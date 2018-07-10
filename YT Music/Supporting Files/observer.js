window.setTimeout(function() {
             
  var observer = new MutationObserver(function(mutations) {

    let bar = document.querySelector('#progress-bar');

    window.webkit.messageHandlers.observer.postMessage({
      title: document.querySelector('.ytmusic-player-bar.title').textContent,
      by: document.querySelector('.ytmusic-player-bar.byline').textContent,
      thumbnail: document.querySelector('#img').getAttribute('src'),
      progress: parseInt(bar.getAttribute('value')),
      length: parseInt(bar.getAttribute('aria-valuemax')),
      isPlaying: document.querySelector('.play-pause-button.ytmusic-player-bar').getAttribute('title') == window.yt.msgs_.YTP_PAUSE
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

