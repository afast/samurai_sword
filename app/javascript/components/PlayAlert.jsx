import React from "react"
import PropTypes from 'prop-types'

class PlayAlert extends React.Component {
  componentDidMount() {
    const audioEl = document.getElementsByClassName(`audio-element-${this.props.name}`)[0]
    addEventListener('ended', this.props.callback, false);
    setTimeout(() => this.props.callback.call(this.props.name), 10000)
    audioEl.currentTime = 0
    audioEl.play()
  }
 
  render() {
    return (
      <div>
        {Object.keys(this.props.available).map( (key) =>
          <audio className={`audio-element-${key}`}>
            <source src={this.props.available[key]}></source>
          </audio>
        )}
      </div>
    )
  }
} 

PlayAlert.defaultProps = {
  name: 'playAlert',
  available: {
    bushido: '/bushido.mp3',
    playerAlert: '/ding.mp3',
    honor: '/wasted.mp3',
    robbed: '/abanicazo.mp3',
    waitingOnMyAnswer: '/fast_beep.mp3',
    lostResistance: '/chan.mp3',
    recoveredResistance: '/moneda_mario.mp3',
  },
  callback: () => { }
}

PlayAlert.propTypes = {
  name: PropTypes.string,
  available: PropTypes.object,
  callback: PropTypes.func,
}

export default PlayAlert
