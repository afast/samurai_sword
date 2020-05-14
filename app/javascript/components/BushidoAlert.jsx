 import React from "react"
 

class PlayerAlert extends React.Component {
  componentDidMount() {
    const audioEl = document.getElementsByClassName("audio-element")[0]
    audioEl.volume = 0.3
    audioEl.play()
  }
 
  render() {
    return (
      <div>
        <audio className="audio-element">
          <source src="/bushido.mp3"></source>
        </audio>
      </div>
    )
  }
} 

export default PlayerAlert
