import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Card from './Card'

const OtherPlayer = props => (
  <div className={`player ${props.turn ? 'player__turn' : (props.pendingAnswer ? 'player--pending_answer' : '')} ${props.firstChild ? 'player--first-child' : ''} ${props.lastChild ? 'player--last-child' : ''}`}>
    <span>{props.name}</span>
    <div className='player-cards--other'>
      { props.role == 'shogun' && <div className='player-cards__role'>
        <Card name={props.role} visible={true} />
      </div> }
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
    <div className="player__visible_cards">
      {props.visible_cards.map( (c, i) => <Card key={i} index={i} {...c} visible={true} clickable={false} />)}
    </div>
  </div>
)

OtherPlayer.defaultProps = {
  visible: false,
  role: 'ninja',
  name: '',
  character: 'kojiro',
  cards: [{'name': 'bo'}, {name: 'bokken'}, {name: 'kusarigama'}],
  honor: 0,
  resistance: 0,
  pendingAnswer: false,
}

OtherPlayer.propTypes = {
  visible: PropTypes.bool,
  role: PropTypes.string,
  character: PropTypes.string,
  cards: PropTypes.array,
  honor: PropTypes.number,
  name: PropTypes.string,
  resistance: PropTypes.number,
  pendingAnswer: PropTypes.bool,
}

export default OtherPlayer
