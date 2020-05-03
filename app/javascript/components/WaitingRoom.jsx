import React from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import Game from './Game'
import {joinGame, startGame} from '../actions/game'

class WaitingRoom extends React.Component {

  constructor(props) {
    super(props);
    this.joinGame = this.joinGame.bind(this);
    this.startGame = this.startGame.bind(this);
  }

  joinGame() {
    this.props.joinGame(this.props.game.id)
  }

  startGame() {
    this.props.startGame(this.props.game.id)
  }

  render() {
    const { users, currentUser } = this.props;
    const alreadyJoined = users.map( (u) => u.id ).includes(currentUser.id)

    return (
      <div className='waiting_room'>
        <h3>Players waiting</h3>
        { users.map( (u, i) => <span key={i} className='waiting_room__player'>{u.username}</span>) }
        { !alreadyJoined && <button onClick={this.joinGame}>Join Game</button> }
        { alreadyJoined && <button onClick={this.startGame}>Start Game</button> }
      </div>
    );
  }
};

WaitingRoom.propTypes = {
  game: PropTypes.object,
  users: PropTypes.array,
  currentUser: PropTypes.object,
}

const mapStateToProps = (state) => {
  const { game, currentUser } = state
  return { 
    game: game,
    users: game.users,
    currentUser: currentUser,
  }
}

const mapActionsToProps = { joinGame, startGame }

export default connect(mapStateToProps, mapActionsToProps)(WaitingRoom)
