 import React from "react"
 

class PlayerAlert extends React.Component {
  componentDidMount() {
    const audioEl = document.getElementsByClassName("audio-element")[0]
    audioEl.play()
  }
 
  render() {
    return (
      <div>
        <audio className="audio-element">
          <source src="/fast_beep.mp3"></source>
        </audio>
      </div>
    )
  }
} 

export default PlayerAlert
