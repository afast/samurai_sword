import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import Deck from './Deck'
import Discarded from './Discarded'
import CardToPlay from './CardToPlay'
import GameLog from './GameLog'
import HandleKote from './HandleKote'

const GameInfo = props => (
  <div className="game_info">
    <Deck size={props.deckSize}/>
    <Discarded />
    <GameLog />
    <CardToPlay />
    { props.handleKote && <HandleKote /> }
    { props.game_ended && <div className='game_end'>
      <span className='points'>Samurai Points: {props.samuraiPoints}</span><br />
      <span className='points'>Ninja Points: {props.ninjaPoints}</span><br />
      <span className='points'>Ronin Points: {props.roninPoints}</span><br />
      <span className='winner'>Winners: { props.winningTeam }</span>
    </div>}
  </div>
)

GameInfo.defaultProps = {
  deckSize: 0,
  discardedSize: 0
}

GameInfo.propTypes = {
  deckSize: PropTypes.number,
  discardedSize: PropTypes.number,
  samuraiPoints: PropTypes.number,
  ninjaPoints: PropTypes.number,
  roninPoints: PropTypes.number,
  game_ended: PropTypes.bool,
  winningTeam: PropTypes.string,
}

const mapStateToProps = (state) => {
  const { game } = state
  const otherPlayers = [...game.players]
  const player = otherPlayers.splice(game.turn, 1)[0]

  let currentPlayer = {};
  game.players.map( (p) => { if (p.user.id == state.currentUser.id) currentPlayer = p } )

  return { 
    deckSize: game.deck.length,
    discardedSize: game.discarded.length,
    samuraiPoints: game.samurai_points,
    ninjaPoints: game.ninja_points,
    roninPoints: game.ronin_points,
    game_ended: game.game_ended,
    winningTeam: game.winning_team,
    action: game.last_action,
    handleKote: currentPlayer.character == player.character && game.defend_from && game.defend_from.name == 'kote',
    error: game.last_error,
  }
}

export default connect(mapStateToProps)(GameInfo)
