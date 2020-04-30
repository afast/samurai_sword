import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import Card from './Card'
import PlayerActions from './PlayerActions'

class Player extends React.Component {
  constructor(props) {
    super(props);
  }


  render () {
    const { game_ended, honor, visible, role, players, turn, character, cards, resistance } = this.props;

    const myTurn = character === players[turn].character

    return ( <div className="player">
        <div>
          { myTurn && !game_ended && <PlayerActions /> }
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
              <Card key={index} index={index} type={card.type} name={card.name} visible={visible} clickable={true} />
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
  return {
    game_ended: state.game.game_ended,
    players: state.game.players,
    turn: state.game.turn
  }
}

export default connect(mapStateToProps)(Player)
