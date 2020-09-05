import React from 'react'
import { connect } from 'react-redux'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import {  recoverResistance, ieyasuTakeCards, nobunagaTakeCard, wantsToPlay, takeCards, discardCard, endTurn } from '../actions/game'

class PlayerActions extends React.Component {
  constructor(props) {
    super(props);
    this.handleResetResistance = this.handleResetResistance.bind(this);
    this.handleTakeCards = this.handleTakeCards.bind(this);
    this.handleIeyasu = this.handleIeyasu.bind(this);
    this.handleNobunaga = this.handleNobunaga.bind(this);
    this.handleShima = this.handleShima.bind(this);
    this.handleEndTurn = this.handleEndTurn.bind(this);
    this.handleDiscardCards = this.handleDiscardCards.bind(this);
  }

  handleResetResistance () {
    this.props.recoverResistance(this.props.game.id);
  }

  handleTakeCards () {
    this.props.takeCards(this.props.game.id);
  }

  handleIeyasu () {
    this.props.ieyasuTakeCards(this.props.game.id);
  }

  handleNobunaga () {
    this.props.nobunagaTakeCard(this.props.game.id); 
  }

  handleShima () {
    this.props.wantsToPlay({ name: 'shima' })
  }

  handleEndTurn () {
    this.props.endTurn(this.props.game.id);
  }

  handleDiscardCards () {
    this.props.discardCard(this.props.game.id);
  }


  render () {
    const { phase, resolve_bushido } = this.props.game;
    const { character, resistance } = this.props;
    const itsIeyasu = character == 'ieyasu';
    const itsNobunaga = character == 'nobunaga' && resistance > 1;
    const itsShima = character == 'shima';
    return (
      <div>
      { phase == 1 && <PhaseOne handleResetResistance={this.handleResetResistance} /> }
      { phase == 2 && !resolve_bushido && <PhaseTwo handleTakeCards={this.handleTakeCards} ieyasu={itsIeyasu} handleIeyasu={this.handleIeyasu} /> }
      { phase == 3 && <PhaseThree handleEndTurn={this.handleEndTurn} /> }
      { itsShima && phase == 3 && <Shima handleShima={this.handleShima} /> }
      { phase == 4 && <PhaseFour handleDiscardCards={this.handleDiscardCards} /> }
      { itsNobunaga && [2, 3].includes(phase) && <Nobunaga handleNobunaga={this.handleNobunaga} /> }
      </div>
    )
  }
}

const PhaseOne = ({handleResetResistance}) => {
  return (
    <div>
      <button onClick={handleResetResistance}>Recuperar Resistencia</button>
    </div>
  )
}

const PhaseTwo = ({handleTakeCards, ieyasu, handleIeyasu}) => {
  return (
    <div>
      { ieyasu && <button onClick={handleIeyasu}>Robar descarte y mazo</button> }
      <button onClick={handleTakeCards}>Robar Cartas</button>
    </div>
  )
}

const PhaseThree = ({handleEndTurn}) => {
  return (
    <div>
      <button onClick={handleEndTurn}>Finalizar Turno</button>
    </div>
  )
}

const PhaseFour = ({handleDiscardCards}) => {
  return (
    <div>
      <span>Please discard cards, max allowed is 7</span>
    </div>
  )
}

const Nobunaga = ({handleNobunaga}) => {
  return (
    <div>
      <button onClick={handleNobunaga}>Robar Carta por 1 de daño</button>
    </div>
  )
}

const Shima = ({handleShima}) => {
  return (
    <div>
      <button onClick={handleShima}>Robar Propiedad Visible por 1 de daño</button>
    </div>
  )
}

PhaseOne.propTypes = { handleResetResistance: PropTypes.func }
PhaseTwo.propTypes = { handleTakeCards: PropTypes.func }
PhaseThree.propTypes = { handleEndTurn: PropTypes.func }
PhaseFour.propTypes = { handleDiscardCards: PropTypes.func }


PlayerActions.defaultProps = {
  visible: false,
  role: 'ninja',
  character: 'kojiro',
  cards: [{'name': 'bo'}, {name: 'bokken'}, {name: 'kusarigama'}],
  honor: 0,
  current_turn: true,
  phase: 1,
  resistance: 0
}

PlayerActions.propTypes = {
  visible: PropTypes.bool,
  role: PropTypes.string,
  character: PropTypes.string,
  cards: PropTypes.array,
  honor: PropTypes.number,
  phase: PropTypes.number,
  game: PropTypes.object,
  resistance: PropTypes.number
}

const mapStateToProps = (state) => {
  const { game } = state
  return { 
    game: game,
  }
}

const mapDispatchToProps = {
  recoverResistance,
  takeCards,
  ieyasuTakeCards,
  nobunagaTakeCard,
  wantsToPlay,
  discardCard,
  endTurn
}

export default connect(mapStateToProps, mapDispatchToProps)(PlayerActions)
