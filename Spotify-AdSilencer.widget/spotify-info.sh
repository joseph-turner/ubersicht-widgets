#!/bin/bash

trackInfo=`osascript <<<'
  if application "Spotify" is running
    tell application "Spotify"
        set theTrack to current track
        set theArtist to artist of theTrack
        set trackName to name of theTrack
        set artworkUrl to artwork url of theTrack
        set albumName to album of theTrack
        set playerState to player state
        return  trackName & "|" & theArtist & "|" & artworkUrl & "|" & playerState & "|" & albumName
    end tell
  end if'`;

echo $trackInfo;
