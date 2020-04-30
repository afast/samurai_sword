import React from 'react'
import { connect } from 'react-redux'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import {  recoverResistance, takeCards, discardCard, endTurn } from '../actions/game'

class PlayerActions extends React.Component {
  constructor(props) {
    super(props);
    this.handleResetResistance = this.handleResetResistance.bind(this);
    this.handleTakeCards = this.handleTakeCards.bind(this);
    this.handleEndTurn = this.handleEndTurn.bind(this);
    this.handleDiscardCards = this.handleDiscardCards.bind(this);
  }

  handleResetResistance () {
    console.log('handleResetResistance')
    this.props.recoverResistance(this.props.game.id);
  }

  handleTakeCards () {
    console.log('handleTakeCards')
    this.props.takeCards(this.props.game.id);
  }

  handleEndTurn () {
    console.log('handleEndTurn')
    this.props.endTurn(this.props.game.id);
  }

  handleDiscardCards () {
    console.log('handleDiscardCards')
    this.props.discardCard(this.props.game.id);
  }


  render () {
    const { phase } = this.props.game;
    console.log(phase)
    return (
      <div>
      { phase == 1 && <PhaseOne handleResetResistance={this.handleResetResistance} /> }
      { phase == 2 && <PhaseTwo handleTakeCards={this.handleTakeCards} /> }
      { phase == 3 && <PhaseThree handleEndTurn={this.handleEndTurn} /> }
      { phase == 4 && <PhaseFour handleDiscardCards={this.handleDiscardCards} /> }
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

const PhaseTwo = ({handleTakeCards}) => {
  return (
    <div>
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
      <button onClick={handleDiscardCards}>Descartar Cartas Automaticamente</button>
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
  return { game: game }
}

const mapDispatchToProps = {
  recoverResistance,
  takeCards,
  discardCard,
  endTurn
}

export default connect(mapStateToProps, mapDispatchToProps)(PlayerActions)
