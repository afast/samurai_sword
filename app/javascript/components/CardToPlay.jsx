import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import {  playCard } from '../actions/game'
import Card from './Card'

class CardToPlay extends React.Component {
  constructor(props) {
    super(props);
    this.handlePlayCard = this.handlePlayCard.bind(this);
    this.onChangeRadio = this.onChangeRadio.bind(this);
    this.state = { value: this.props.otherPlayers[0].character }
  }

  onChangeRadio(e) {
    this.setState({ value: e.target.value })
  }

  handlePlayCard() {
    this.props.playCard(this.props.currentPlayer, this.props.pending_card, this.state.value)
  }

  render () {
    const {
      pending_card,
      otherPlayers
    } = this.props
    return (
      <div className='card_to_play'>
        { pending_card.name && <Card name={pending_card.name} visible={true} /> }
        { pending_card.type == 'weapon' && <div className='card_to_play__player_list'>
          { otherPlayers.map( (player) =>
            <label>
              <input type="radio" checked={this.state.value == player.character} name="target" value={player.character} onChange={this.onChangeRadio}/>
              {player.character}
            </label>
          ) }
          { pending_card.name && <button onClick={this.handlePlayCard}>Jugar Carta</button> }
        </div>}
      </div>
    )
  }
}

CardToPlay.defaultProps = {
  pending_card: {},
  otherPlayers: [],
  currentPlayer: {}
}

CardToPlay.propTypes = {
  pending_card: PropTypes.object,
  otherPlayers: PropTypes.array,
  currentPlayer: PropTypes.object
}

const mapStateToProps = (state) => {
  const { wantsToPlay, game } = state
  let otherPlayers = [...game.players]
  const player = otherPlayers.splice(game.turn, 1)
  return { 
    pending_card: wantsToPlay,
    otherPlayers: otherPlayers,
    currentPlayer: player[0]
  }
}

const mapActionsToProps = { playCard }

export default connect(mapStateToProps, mapActionsToProps)(CardToPlay)
