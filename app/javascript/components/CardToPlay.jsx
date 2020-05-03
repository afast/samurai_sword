import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import {  playCard, discardCard } from '../actions/game'
import Card from './Card'

class CardToPlay extends React.Component {
  constructor(props) {
    super(props);
    this.handlePlayCard = this.handlePlayCard.bind(this);
    this.onChangeRadio = this.onChangeRadio.bind(this);
    this.handleDiscardCard = this.handleDiscardCard.bind(this);
    this.onChangeWhatCard = this.onChangeWhatCard.bind(this);
    this.state = { value: this.props.otherPlayers[0].character, availableCards: [], what_card: null }
  }

  onChangeRadio(e) {
    this.setState({ value: e.target.value })
    let currentPlayer = {};

    players.map( (p) => {
      if (p.user.id == currentUser.id)
        currentPlayer = p
    } )
    this.setState({ availableCards: currentPlayer.visible_cards })
  }

  onChangeWhatCard(e) {
    this.setState({ what_card: e.target.value })
  }

  handlePlayCard() {
    const {
      pending_card,
      turnPlayer,
      playCard,
      myTurn,
    } = this.props

    const cardsRequiringSelection = ['respiracion', 'distraccion', 'geisha']

    const requiresPlayerSelection = myTurn && (pending_card.type == 'weapon' || cardsRequiringSelection.includes(pending_card.name))

    if (!requiresPlayerSelection || this.state.value)
      playCard(turnPlayer, pending_card, this.state.value, this.state.what_card)
  }

  handleDiscardCard() {
    console.log(this.props.game_id)
    console.log(this.props.pending_card.name)
    this.props.discardCard(this.props.game_id, this.props.pending_card.name)
  }

  componentDidMount() {
    this.setState({ value: null });
  }

  render () {
    const {
      pending_card,
      phase,
      players,
      turnPlayer,
      currentUser,
      turn,
      otherPlayers
    } = this.props

    let currentPlayer = {};

    players.map( (p) => {
      if (p.user.id == currentUser.id)
        currentPlayer = p
    } )

    const myTurn = currentPlayer.character == turnPlayer.character
    const cardsRequiringSelection = ['respiracion', 'distraccion', 'geisha']
    const requiresPlayerSelection = myTurn && (pending_card.type == 'weapon' || cardsRequiringSelection.includes(pending_card.name))
    console.log(pending_card)

    return (
      <div className='card_to_play'>
        { pending_card.name && <Card name={pending_card.name} visible={true} /> }
        { phase == 3 && requiresPlayerSelection && <div className='card_to_play__player_list'>
          { otherPlayers.map( (player) =>
            <label>
              <input type="radio" checked={this.state.value == player.character} name="target" value={player.character} onChange={this.onChangeRadio}/>
              {player.user.username}
            </label>
          ) }
          { pending_card.name == 'geisha' && <div>
            <span>Descartar de:</span>
            <label>
              <input type="radio" checked={this.state.what_card=='from_hand'} name="what_card" value="from_hand" onChange={this.onChangeWhatCard} />
              De la Mano
            </label>
            { this.state.availableCards.map( (c, i) => 
              <label>
                <input key={i} type="radio" checked={this.state.what_card == c.name} name="what_card" value={c.name} onChange={this.onChangeWhatCard}/>
                {c.name}
              </label>
            ) }
          </div>}
        </div>}
        { phase == 3 && myTurn && pending_card.name && <button onClick={this.handlePlayCard}>Jugar Carta</button> }
        { pending_card.name && phase == 4 && <div className='card_to_play__discard'>
            <button onClick={this.handleDiscardCard}>Descartar Carta</button>
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
  const player = otherPlayers.splice(game.turn, 1)[0]

  let currentPlayer = {};
  game.players.map( (p) => { if (p.user.id == state.currentUser.id) currentPlayer = p } )

  return { 
    pending_card: wantsToPlay,
    otherPlayers: otherPlayers,
    players: game.players,
    phase: game.phase,
    game_id: game.id,
    turn: game.turn,
    currentUser: state.currentUser,
    currentPlayer: currentPlayer,
    myTurn: currentPlayer.character == player.character,
    turnPlayer: player
  }
}

const mapActionsToProps = { playCard, discardCard }

export default connect(mapStateToProps, mapActionsToProps)(CardToPlay)
