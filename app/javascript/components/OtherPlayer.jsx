import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Card from './Card'

const OtherPlayer = props => (
  <div className="player">
    <div className='player-cards--other'>
      <div className='player-cards__character'>
        <Card name={props.character} visible={true} />
      </div>
      <div className='player__info'>
        <div className='honor'>
          <div className='shuriken_token'>
          </div>
          <span className='honor__amount'>{props.honor}</span>
        </div>
        <div className='resistance'>
          <div className='heart_token'>
          </div>
          <span className='resistance__amount'>{props.resistance}</span>
        </div>
      </div>

      <div className={'player-cards__actions ' + (props.visible ? '' : 'hidden')}>
        {props.cards.map((card, index) =>
          <Card key={index} name={card.name} visible={props.visible} />
        )}
      </div>
    </div>
  </div>
)

OtherPlayer.defaultProps = {
  visible: false,
  role: 'ninja',
  character: 'kojiro',
  cards: [{'name': 'bo'}, {name: 'bokken'}, {name: 'kusarigama'}],
  honor: 0,
  resistance: 0
}

OtherPlayer.propTypes = {
  visible: PropTypes.bool,
  role: PropTypes.string,
  character: PropTypes.string,
  cards: PropTypes.array,
  honor: PropTypes.number,
  resistance: PropTypes.number
}

export default OtherPlayer
