import React from 'react'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import GameInfo from './GameInfo'
import WaitingRoom from './WaitingRoom'
import Player from './Player'
import Card from './Card'
import OtherPlayer from './OtherPlayer'
import BushidoAlert from './BushidoAlert'

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
      bushidoAlert,
      pendingAnswers,
      turn
    } = this.props;

    const pendingAnswersIds = pendingAnswers && pendingAnswers.map( (p) => p.character ) || []


    if (game.status == 'WAITING')
      return (<WaitingRoom />)
    else {
      let otherPlayers = [];
      let currentPlayer = {};
      let currentPlayerIndex = -1;

      players.map( (p, i) => {
        p.turn = players[turn].character == p.character
        if (p.user.id == currentUser.id) {
          currentPlayer = p
          currentPlayerIndex = i
        } else {
          p.pendingAnswer = pendingAnswersIds.includes(p.character)
        }
      } )

      otherPlayers = players.slice(0, currentPlayerIndex).reverse();
      otherPlayers = otherPlayers.concat(players.slice(currentPlayerIndex + 1, players.length).reverse())

      return(
        <div className="game">
          <div className="other_players">
            {otherPlayers.map((player, index) =>
              <OtherPlayer key={index} {...player} gameEnded={game.game_ended}firstChild={otherPlayers.length > 2 && index==0} lastChild={otherPlayers.length > 2 && index==otherPlayers.length-1} name={player.user.username} visible={false} /> 
            )}
          </div>
          <GameInfo deckSize={this.props.game.deck.length} discardedSize={this.props.game.discarded.length} />
          <div className="logged_in_player">
            <Player playerturn={currentPlayer.turn} {...currentPlayer} visible={true} />
          </div>
          { bushidoAlert && <BushidoAlert /> }
        </div>
      )
    }
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
    pendingAnswers: game.pending_answer,
    bushidoAlert: game.bushido_in_play,
    currentUser: currentUser
  }
}

export default connect(mapStateToProps)(Game)
