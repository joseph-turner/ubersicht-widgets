set musicApp to "Spotify"

if application musicApp is running then
  tell application musicApp
    set theTrack to current track
    set theArtist to artist of theTrack
    set trackName to name of theTrack
    set artworkUrl to artwork url of theTrack
    set playerState to player state
    return  trackName & "|" & theArtist & "|" & artworkUrl & "|" & playerState
  end tell
end if
