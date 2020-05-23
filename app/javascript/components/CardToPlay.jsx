import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import {  playCard, discardCard, stealByIntuicion } from '../actions/game'
import Card from './Card'

class CardToPlay extends React.Component {
  constructor(props) {
    super(props);
    this.handlePlayCard = this.handlePlayCard.bind(this);
    this.onChangeRadio = this.onChangeRadio.bind(this);
    this.handleDiscardCard = this.handleDiscardCard.bind(this);
    this.onChangeWhatCard = this.onChangeWhatCard.bind(this);
    this.handleSelectIntuicion = this.handleSelectIntuicion.bind(this);
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

    const cardsRequiringSelection = ['respiracion', 'distraccion', 'geisha', 'bushido', 'maldicion', 'ataque_simultaneo', 'imitacion', 'herida_sangrante']

    const requiresPlayerSelection = myTurn && (pending_card.type == 'weapon' || cardsRequiringSelection.includes(pending_card.name))

    if (!requiresPlayerSelection || this.state.value) {
      playCard(turnPlayer, pending_card, this.state.value, this.state.what_card)
      this.setState({value: null })
    }
  }

  handleSelectIntuicion () {
    const {
      pending_card,
      game_id,
      turnPlayer,
      selectForIntuicion,
      myTurn,
    } = this.props

    if (selectForIntuicion) {
      this.props.stealByIntuicion(game_id, pending_card.character, pending_card.name)
    }
  }

  handleDiscardCard() {
    this.props.discardCard(this.props.game_id, this.props.pending_card.name)
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
      pending_card,
      phase,
      selectForIntuicion,
      players,
      turnPlayer,
      currentUser,
      turn,
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
    const cardsRequiringSelection = ['respiracion', 'distraccion', 'geisha', 'bushido', 'maldicion', 'ataque_simultaneo', 'imitacion', 'herida_sangrante']
    const requiresPlayerSelection = myTurn && (pending_card.type == 'weapon' || cardsRequiringSelection.includes(pending_card.name))

    return (
      <div className='card_to_play'>
        { pending_card.name && <Card name={pending_card.name} visible={true} /> }
        { phase == 3 && requiresPlayerSelection && <div className='card_to_play__player_list'>
          { otherPlayers.map( (player, i) =>
            <label key={`otherplayerlabel-${i}`}>
              <input key={`otherplayer-${i}`} type="radio" checked={this.state.value == player.character} name="target" value={player.character} onChange={this.onChangeRadio}/>
              {player.user.username}
            </label>
          ) }
          { pending_card.name == 'tanto' &&  <label key={`otherplayerlabel-9`}>
              <input key={`otherplayer-9`} type="radio" checked={this.state.value == currentPlayer.character} name="target" value={currentPlayer.character} onChange={this.onChangeRadio}/>
              {currentPlayer.user.username}
            </label> }
        </div>}
        { phase == 3 && myTurn && !selectForIntuicion && pending_card.name && <button onClick={this.handlePlayCard}>Jugar Carta</button> }
        { phase == 3 && myTurn && selectForIntuicion && pending_card.name && <button onClick={this.handleSelectIntuicion}>Robar Via Intuicion</button> }
        { phase == 3 && requiresPlayerSelection && pending_card.name == 'geisha' && <div className='card_to_play__player_list--geisha'>
            <span>Descartar de:</span>
            <label>
              <input type="radio" checked={this.state.what_card=='from_hand'} name="what_card" value="from_hand" onChange={this.onChangeWhatCard} />
              De la Mano
            </label>
            { player && player.visible_cards && [...new Set(player.visible_cards.map((c) => c.name))].map( (name, i) => 
              <label key={`whatlabel-${i}`}>
                <input key={`whatinput-${i}`} type="radio" checked={this.state.what_card == name} name="what_card" value={name} onChange={this.onChangeWhatCard}/>
                {name}
              </label>
            ) }
          </div>}
        { phase == 3 && requiresPlayerSelection && pending_card.name == 'imitacion' && <div className='card_to_play__player_list--geisha'>
            <span>Robar:</span>
            { player && player.visible_cards && [...new Set(player.visible_cards.map((c) => c.name))].map( (name, i) => 
              <label key={`whatlabel-${i}`}>
                <input key={`whatinput-${i}`} type="radio" checked={this.state.what_card == name} name="what_card" value={name} onChange={this.onChangeWhatCard}/>
                {name}
              </label>
            ) }
          </div>}
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
  console.log(game.players)
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
    selectForIntuicion: game.defend_from && game.defend_from.name == 'intuicion',
    turnPlayer: player
  }
}

const mapActionsToProps = { playCard, discardCard, stealByIntuicion }

export default connect(mapStateToProps, mapActionsToProps)(CardToPlay)
