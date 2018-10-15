# This is a simple example Widget, written in CoffeeScript, to get you started
# with Übersicht. For the full documentation please visit:
#
# https://github.com/felixhageloh/uebersicht
#
# You can modify this widget as you see fit, or simply delete this file to
# remove it.

# the CSS style for this widget, written using Stylus
# (http://learnboost.github.io/stylus/)

# the refresh frequency in milliseconds
refreshFrequency: 1000

style: """

  player = 1
  bottom = 10px
  right = 10px

  if player
    display-player = inherit
  else
    display-player = none

  display: display-player;
  bottom: bottom
  right: right
  width: 250px
  padding: 10px
  background-color: rgba(black,0.3)
  color: white
  font-family: "Helvetica Neue", sans-serif
  text-align: center
  border-radius: 3px;

  .album-img
    width: 100%
    height: auto

  .track-name
    margin: 10px 17px 0
    font-size: 42px
    font-weight: 100

  .artist-name
    font-size: 18px
    font-weight: 200

  .album-name
    color: rgba(white, .7)
    font-weight: 200

  .player
    color: white
    & i
      padding: 15px
      font-size: 1.7em
    & i.hidden
      display: none


"""

# this is the shell command that gets executed every time this widget refreshes
command: "source Spotify-AdSilencer.widget/spotify-info.sh"

# render gets called after the shell command has executed. The command's output
# is passed in as a string. Whatever it returns will get rendered as HTML.
render: (output) -> """
  <img name="album-img" class="album-img">
  <div class="track-name" name="track"></div>
  <div class="artist-name" name="artist"></div>
  <div class="album-name" name="album"></div>
  <div class="player" name="player">
    <i class="fa fa-backward" name="song-backward" aria-hidden="true"></i>
    <i class="fa fa-play" name="song-play" aria-hidden="true"></i>
    <i class="fa fa-pause hidden" name="song-pause" aria-hidden="true"></i>
    <i class="fa fa-forward" name="song-forward" aria-hidden="true"></i>
  </div>
  <link rel="stylesheet" href="Spotify-AdSilencer.widget/css/font-awesome.min.css">
"""

test: (domEl) ->
  self = this
  console.log(self)

# Update the rendered output.
update: (output, domEl) ->

  adDetected = (self) ->
    $('[name="track"]').html("Ad detected")
    $('[name="artist"]').html("Ad detected")
    $('[name="album-img"]').attr('src','Spotify-AdSilencer.widget/images/ad.png')
    self.run "osascript -e 'tell application \"Spotify\" to set sound volume to 0'"
    self.run "osascript -e 'display notification with title \"Spotify Ad detected\"'"
    localStorage.setItem "spotifyAd", 1
    #localStorage.setItem "spotifyVolume", 0

  setTrackName = (trackName) ->
    trackName = cutStringToFill(trackName)
    localStorage.setItem "spotifyTrack", trackName
    $('.track-name').html(trackName)

  setArtistName = ( artistName ) ->
    artistName = cutStringToFill(artistName)

    $('[name="artist"]').html(artistName)

  setAlbumName = ( albumName ) ->
    albumName = cutStringToFill(albumName)
    $('.album-name').html(albumName)

  setAlbumImage = ( albumUrl ) ->
    $('[name="album-img"]').attr('src',albumUrl)

  getSpotifyVolume = (self, callback) ->

    getSpotifyVolumeScript = """
      osascript <<<'tell application "Spotify"
        set soundVolume to sound volume
        return  soundVolume
      end tell'"""

    self.run getSpotifyVolumeScript, (error, data) ->
      if data?
        callback(data)

  setSpotifyVolume = (self,volume) ->
    volume = parseInt(volume, 10) + 1
    setSpotifyVolumeCommand = "osascript -e 'tell application \"Spotify\" to set sound volume to " + volume + "'"
    self.run setSpotifyVolumeCommand

  fromAd = (self) ->
    fromSpotifyAd = localStorage.getItem "spotifyAd"
    if fromSpotifyAd? and fromSpotifyAd is "1"
      spotifyVolume = localStorage.getItem "spotifyVolume"
      setSpotifyVolume(self,spotifyVolume)
      localStorage.setItem "spotifyAd", 0
    else
      getSpotifyVolume( self, (spotifyVolume) ->
        localStorage.setItem "spotifyVolume", spotifyVolume
      )

  cutStringToFill = (string) ->
    maxLength = 27
    stringLength = string.length
    if stringLength > maxLength
      string = string.substring(0,maxLength-2) + " ..."

    return string

  playPausePlayer = (playerState) ->
    if playerState.trim() in ['paused', 'stopped']
      $('[name="song-pause"]').addClass('hidden')
      $('[name="song-play"]').removeClass('hidden')
    else if playerState.trim() in ['playing']
      $('[name="song-play"]').addClass('hidden')
      $('[name="song-pause"]').removeClass('hidden')

  trackInfoArray = output.split "|"
  if trackInfoArray
    trackName = trackInfoArray[0]
    playerState = trackInfoArray[3]
    albumName = trackInfoArray[4]
    playPausePlayer(playerState)
    if trackName
      setTrackName(trackName)
      artistName = trackInfoArray[1]
      if artistName
        setArtistName(artistName)
        fromAd(this)
        albumUrl = trackInfoArray[2]
        if albumUrl
          setAlbumImage(albumUrl)
        if albumName
          setAlbumName(albumName)
      else
        adDetected(this)

    else
      adDetected(this)

afterRender: (domEl)->

  playPauseSong = (self) ->
    self.run "osascript -e 'tell application \"Spotify\" to playpause'"

  forwardSong = (self) ->
    self.run "osascript -e 'tell application \"Spotify\" to next track'"

  backwardSong = (self)->
    self.run "osascript -e 'tell application \"Spotify\" to previous track'"

  self = this

  self.test(domEl)

  $(domEl).find('[name="song-play"]').on 'click', =>
    playPauseSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')

  $(domEl).find('[name="song-pause"]').on 'click', =>
    playPauseSong(self)
    $('[name="song-pause"]').addClass('hidden')
    $('[name="song-play"]').removeClass('hidden')

  $(domEl).find('[name="song-forward"]').on 'click', =>
    forwardSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')

  $(domEl).find('[name="song-backward"]').on 'click', =>
    backwardSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')
