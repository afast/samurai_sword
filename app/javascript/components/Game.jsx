import React from 'react'
import { connect } from 'react-redux'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import GameInfo from './GameInfo'
import Player from './Player'
import OtherPlayer from './OtherPlayer'

class Game extends React.Component {
  constructor(props) {
    super(props);
  }

  render () {
    const {
      game,
      users,
      players,
      currentUser,
      turn
    } = this.props;

    let otherPlayers = [];
    let currentPlayer = {};

    players.map( (p) => {
      if (p.user.id == currentUser.id)
        currentPlayer = p
      else
        otherPlayers.push(p)
    } )

    return(
      <div>
        <div className="other_players">
          {otherPlayers.map((player, index) =>
            <OtherPlayer role={player.role} character={player.character} cards={player.cards} honor={player.honor} resistance={player.resistance} visible={false} /> 
          )}
        </div>
        <GameInfo deckSize={this.props.game.deck.length} discardedSize={this.props.game.discarded.length} />
        <div className="logged_in_player">
          <Player {...currentPlayer} visible={true} />
        </div>
      </div>
    )
  }
}

Game.defaultProps = {
  game: {},
  players: [],
  turn: 0
}

Game.propTypes = {
  game: PropTypes.object,
  players: PropTypes.array,
  users: PropTypes.array,
  currentUser: PropTypes.object,
  turn: PropTypes.number
}

const mapStateToProps = (state) => {
  const { game, currentUser } = state
  return { 
    game: game,
    players: game.players,
    users: game.users,
    turn: game.turn,
    currentUser: currentUser
  }
}

export default connect(mapStateToProps)(Game)
