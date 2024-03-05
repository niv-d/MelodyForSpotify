setTimeout(() => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));

  var elements = document.querySelectorAll("*:not([data-testid])");
  elements.forEach(function (element) {
    element.style.backgroundColor = "#0000";
  });

  document.addEventListener("contextmenu", (event) => {
    event.preventDefault();
  });

  window.getState = function () {
    let state = {
      albumImage: "",
      albumName: "",
      artistName: "",
      device: "",
      heart: false,
      lyrics: false,
      playing: false,
      queue: false,
      repeat: "none",
      shuffle: false,
      songLength: 0,
      songName: "",
      songPercent: 0,
      songPosition: 0,
    };
    try {
      function parseTimeToSeconds(timeString) {
        const parts = timeString.split(":");
        const minutes = parseInt(parts[0], 10);
        const seconds = parseInt(parts[1], 10);
        return minutes * 60 + seconds;
      }

      let playing =
        document
          .querySelector('button[data-testid="control-button-playpause"]')
          .getAttribute("aria-label") === "Pause";
      let songLength = document.querySelector(
        'div[data-testid="playback-duration"]'
      ).innerHTML;
      //Regex for --progress-bar-transform: 9.663865546218489%;
      const regex = /--progress-bar-transform: (\d+.\d+)%/;
      let songPercent = document
        .querySelector('div[data-testid="progress-bar"]')
        .style.cssText.match(regex)[1];
      let songPosition = document.querySelector(
        'div[data-testid="playback-position"]'
      ).innerHTML;
      let heart =
        document
          .querySelector('button[data-testid="add-button"]')
          .getAttribute("aria-checked") === "true";
      let repeat = document
        .querySelector('button[data-testid="control-button-repeat"]')
        .getAttribute("aria-label");
      switch (repeat) {
        case "Enable repeat":
          repeat = "none";
          break;
        case "Enable repeat one":
          repeat = "all";
          break;
        default:
          repeat = "one";
          break;
      }
      let shuffle =
        document
          .querySelector('button[data-testid="control-button-shuffle"]')
          .getAttribute("aria-checked") === "true";
      //TODO: Get device name
      let songName = document.querySelector(
        'a[data-testid="context-item-link"]'
      ).innerHTML;
      let artistName = document.querySelector(
        'a[data-testid="context-item-info-artist"]'
      ).innerHTML;
      //TODO: Album name
      let albumImage = document.querySelector(
        'img[data-testid="cover-art-image"]'
      )?.src;

      let queue =
        document
          .querySelector('button[data-testid="control-button-queue"]')
          ?.getAttribute("aria-pressed") === "true";
      let lyrics =
        document
          .querySelector('button[data-testid="lyrics-button"]')
          ?.getAttribute("aria-pressed") === "true";
      state = {
        albumImage: albumImage,
        albumName: "",
        artistName: artistName,
        device: "",
        heart: heart,
        lyrics: lyrics,
        playing: playing,
        queue: queue,
        repeat: repeat,
        shuffle: shuffle,
        songLength: Number(parseTimeToSeconds(songLength)),
        songName: songName,
        songPercent: Number(songPercent),
        songPosition: Number(parseTimeToSeconds(songPosition)),
      };
    } catch (e) {
      console.log(JSON.stringify(e));
    }

    try {
      var jsonString = JSON.stringify(state);
      window.webkit?.messageHandlers &&
        window.webkit.messageHandlers.pushState.postMessage(jsonString);
    } catch (e) {
      console.log(JSON.stringify(e));
    }

    console.log(JSON.stringify(state));
    return state;
  };

  setInterval(() => {
    window.getState();
  }, 850);
}, 400);
