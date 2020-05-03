import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import Card from './Card'
import PlayerActions from './PlayerActions'
import PlayerRespond from './PlayerRespond'

class Player extends React.Component {
  constructor(props) {
    super(props);
  }


  render () {
    const { discard_weapon, visible_cards, game_ended, honor, visible, role, players, turn, character, cards, resistance, pendingAnswers } = this.props;

    const myTurn = character === players[turn].character
    const waitingOnMyAnswer = !!pendingAnswers && pendingAnswers.includes(character)
    const waitingOnAnswer = !!pendingAnswers && pendingAnswers.length > 0

    return ( <div className={`player ${this.props.playerturn ? 'player__turn' : ''}`}>
        <div className="player__visible_cards">
          {visible_cards.map( (c, i) => <Card key={i} index={i} {...c} visible={true} clickable={false} />)}
        </div>
        <div>
          { myTurn && !game_ended && !waitingOnAnswer &&  <PlayerActions /> }
          { myTurn && waitingOnAnswer && <span>Esperando respuesta de: {pendingAnswers.join(', ').toUpperCase()}</span> }
          { !myTurn && !game_ended && waitingOnMyAnswer && <PlayerRespond cards={cards} character={character}/> }
        </div>
        <div> 
        </div>
        <div className='player__info'>
          <div className='honor'>
            <div className='shuriken_token'>
            </div>
            <span className='honor__amount'>{honor}</span>
          </div>
          <div className='resistance'>
            <div className='heart_token'>
            </div>
            <span className='resistance__amount'>{resistance}</span>
          </div>
        </div>
        <div className='player-cards'>
          { visible && <div className='player-cards__role'>
            <Card name={role} visible={visible} />
          </div> }
          <div className='player-cards__character'>
            <Card name={character} visible={true} />
          </div>
          <div className={'player-cards__actions ' + (visible ? '' : 'hidden')}>
            {cards.map((card, index) =>
              <Card key={index} index={index} type={card.type} name={card.name} visible={visible} clickable={myTurn || waitingOnMyAnswer && discard_weapon && card.type == 'weapon'} />
            )}
          </div>
        </div>
      </div>
    )
  }
}

Player.defaultProps = {
  visible: false,
  role: 'ninja',
  character: 'kojiro',
  cards: [{'name': 'bo'}, {name: 'bokken'}, {name: 'kusarigama'}],
  honor: 0,
  game_ended: false,
  resistance: 0
}

Player.propTypes = {
  visible: PropTypes.bool,
  role: PropTypes.string,
  character: PropTypes.string,
  cards: PropTypes.array,
  honor: PropTypes.number,
  game_ended: PropTypes.bool,
  players: PropTypes.array,
  resistance: PropTypes.number
}

const mapStateToProps = (state) => {
  const pendingAnswers = state.game.pending_answer && state.game.pending_answer.length && state.game.pending_answer.map( (p) => p.character )
  return {
    game_ended: state.game.game_ended,
    players: state.game.players,
    pendingAnswers: pendingAnswers,
    turn: state.game.turn,
    discard_weapon: state.game.defend_from && state.game.defend_from.name == 'jiujitsu',
  }
}

export default connect(mapStateToProps)(Player)
