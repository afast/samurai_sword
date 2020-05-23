import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import { koteSelectedPlayer } from '../actions/game'

class HandleKote extends React.Component {
  constructor(props) {
    super(props);
    this.onChangeRadio = this.onChangeRadio.bind(this);
    this.koteSelectedPlayer = this.koteSelectedPlayer.bind(this);
    this.state = { value: this.props.otherPlayers[0].character, what_card: null }
  }

  onChangeRadio(e) {
    let player = {};

    this.props.otherPlayers.map( (p) => {
      if (p.character == e.target.value)
        player = p
    } )

    this.setState({ value: e.target.value })
  }

  koteSelectedPlayer() {
    if (this.state.value) {
      this.props.koteSelectedPlayer(this.props.game_id, this.state.value)
      this.setState({value: null })
    }
  }

  componentDidMount() {
    let player = {}
    this.props.players.map( (p) => {
      if (p.user.id == this.state.value)
        player = p
    } )

    this.setState({ value: this.state.value });
  }

  render () {
    const {
      phase,
      players,
      turnPlayer,
      currentUser,
      otherPlayers
    } = this.props

    let currentPlayer = {};
    let player = {};

    players.map( (p) => {
      if (p.user.id == currentUser.id)
        currentPlayer = p
      if (p.character == this.state.value)
        player = p
    } )

    const myTurn = currentPlayer.character == turnPlayer.character

    return (
      <div className='card_to_play'>
        { phase == 3 && <div className='card_to_play__player_list'>
          { otherPlayers.map( (player, i) =>
            <label key={`otherplayerlabel-${i}`}>
              <input key={`otherplayer-${i}`} type="radio" checked={this.state.value == player.character} name="target" value={player.character} onChange={this.onChangeRadio}/>
              {player.user.username}
            </label>
          ) }
        </div>}
        { phase == 3 && myTurn && <button onClick={this.koteSelectedPlayer}>Kote, dar carta a jugador</button> }
      </div>
    )
  }
}

HandleKote.defaultProps = {
  otherPlayers: [],
  currentPlayer: {}
}

HandleKote.propTypes = {
  otherPlayers: PropTypes.array,
  currentPlayer: PropTypes.object
}

const mapStateToProps = (state) => {
  const { wantsToPlay, game } = state
  let otherPlayers = [...game.players]
  const player = otherPlayers.splice(game.turn, 1)[0]

  let currentPlayer = {};
  game.players.map( (p) => { if (p.user.id == state.currentUser.id) currentPlayer = p } )

  return { 
    otherPlayers: otherPlayers,
    players: game.players,
    phase: game.phase,
    game_id: game.id,
    currentUser: state.currentUser,
    currentPlayer: currentPlayer,
    turnPlayer: player
  }
}

const mapActionsToProps = { koteSelectedPlayer }

export default connect(mapStateToProps, mapActionsToProps)(HandleKote)
