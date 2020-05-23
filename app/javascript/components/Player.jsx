import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import ReactCSSTransitionGroup from 'react-addons-css-transition-group'
import Card from './Card'
import PlayerActions from './PlayerActions'
import PlayerRespond from './PlayerRespond'
import PlayAlert from './PlayAlert'

class Player extends React.Component {
  constructor(props) {
    super(props)
    this.state = { honorChanged: false, cardRobbed: false, lostResistance: false, recoveredResistance: false }
    this.resetState = this.resetState.bind(this)
  }

  componentDidUpdate(prevProps) {
    if (prevProps.honor > this.props.honor) {
      this.setState({honorChanged: true})
    }
    if (prevProps.cards.length > this.props.cards.length) {
      this.setState({cardRobbed: true})
    }
    if (prevProps.visible_cards.length > this.props.visible_cards.length) {
      this.setState({cardRobbed: true})
    }
    if (prevProps.resistance > this.props.resistance) {
      this.setState({lostResistance: true, recoveredResistance: false})
    } else if (prevProps.resistance < this.props.resistance) {
      this.setState({lostResistance: false, recoveredResistance: true})
    }
  }

  resetState(name) {
    if (name === 'honor') {
      this.setState({ lostHonor: false})
    } else if (name === 'lostResistance') {
      this.setState({lostResistance: false})
    } else if (name === 'recoveredResistance') {
      this.setState({recoveredResistance: false})
    } else if (name === 'robbed') {
      this.setState({cardRobbed: false})
    }
  }

  render () {
    const { 
      discard_weapon,
      discard_any,
      tanto,
      discard_stop,
      isCounterAttack,
      visible_cards,
      game_ended,
      honor,
      visible,
      role,
      players,
      turn,
      character,
      cards,
      resistance,
      waitForIntuicion,
      pendingAnswers,
      pendingAnswersUsers,
      resolveBushido
    } = this.props;

    const myTurn = character === players[turn].character
    const waitingOnMyAnswer = !!pendingAnswers && pendingAnswers.includes(character)
    const waitingOnAnswer = !!pendingAnswers && pendingAnswers.length > 0
    const hanzoAbility = discard_stop && character == 'hanzo'
    const cardRobbed = !myTurn && !discard_stop && !discard_weapon && this.state.cardRobbed
    const counterAttack = myTurn && waitingOnMyAnswer && isCounterAttack
    const defendTanto = myTurn && waitingOnMyAnswer && tanto
    const has_weapon_also_stop_card = cards.map( (c) => c.is_also ).includes('parada')

    const callbackFunction = (name) => { this.resetState(name) }

    return ( <div className={`player ${this.props.playerturn ? 'player__turn' : (waitingOnMyAnswer ? 'player--pending_answer' : '')}`}>
        <div className="player__visible_cards">
          <ReactCSSTransitionGroup transitionName="card_animation" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
            {visible_cards.map( (c, i) => <Card key={c.rkey} index={i} {...c} visible={true} clickable={false} />)}
          </ReactCSSTransitionGroup>
          <div className='player__actions'>
            { myTurn && <PlayAlert name='playerAlert' /> }
            { !myTurn && waitingOnMyAnswer && <PlayAlert name='waitingOnMyAnswer' />}
            { this.state.honorChanged && <PlayAlert name='honor'  callback={callbackFunction}/> }
            { cardRobbed && <PlayAlert name='robbed'  callback={callbackFunction}/> }
            { this.state.lostResistance && <PlayAlert name='lostResistance'  callback={callbackFunction}/> }
            { this.state.recoveredResistance && <PlayAlert name='recoveredResistance'  callback={callbackFunction}/> }
            { myTurn && !game_ended && !waitingOnAnswer && !waitForIntuicion && <PlayerActions character={character} resistance={resistance} /> }
            { myTurn && waitingOnAnswer && <span>Esperando respuesta de: {pendingAnswersUsers.join(', ').toUpperCase()}</span> }
            { (!myTurn && !game_ended && waitingOnMyAnswer || myTurn && (resolveBushido || counterAttack || defendTanto)) && <PlayerRespond resolveBushido={resolveBushido} visible_cards={visible_cards} cards={cards} character={character}/> }
          </div>
        </div>
        <div className='player__info  player__info--current'>
          <div className='honor'>
            <ReactCSSTransitionGroup transitionName="tokens" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
              { Array.from({length: honor}, (i) => <div key={i} className='shuriken_token' /> ) }
            </ReactCSSTransitionGroup>
          </div>
          <div className='resistance'>
            <ReactCSSTransitionGroup transitionName="tokens" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
              { Array.from({length: resistance}, (i) => <div key={i} className='heart_token' /> ) }
            </ReactCSSTransitionGroup>
          </div>
        </div>
        <div className='player-cards'>
          { visible && <div className='player-cards__role'>
            <Card name={role} visible={visible} />
          </div> }
          <div className='player-cards__character'>
            <Card name={character} visible={true} />
          </div>
          <div className={'player-cards__actions ' + (visible ? '' : 'hidden')}>
            <ReactCSSTransitionGroup transitionName="card_animation" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
              {cards.map((card, index) =>
                <Card key={card.rkey} {...card} index={index} visible={visible} clickable={myTurn && !waitForIntuicion || waitingOnMyAnswer && ((discard_weapon || hanzoAbility) && card.type == 'weapon' || discard_any || discard_stop && card.is_also == 'parada')} />
              )}
            </ReactCSSTransitionGroup>
          </div>
        </div>
      </div>
    )
  }
}

Player.defaultProps = {
  visible: false,
  role: 'ninja',
  character: 'kojiro',
  cards: [{'name': 'bo'}, {name: 'bokken'}, {name: 'kusarigama'}],
  honor: 0,
  game_ended: false,
  resistance: 0
}

Player.propTypes = {
  visible: PropTypes.bool,
  role: PropTypes.string,
  character: PropTypes.string,
  cards: PropTypes.array,
  honor: PropTypes.number,
  game_ended: PropTypes.bool,
  players: PropTypes.array,
  resistance: PropTypes.number
}

const mapStateToProps = (state) => {
  const { game } = state;
  const defend_from = game.defend_from;
  const pendingAnswers = game.pending_answer && game.pending_answer.length && game.pending_answer.map( (p) => p.character )
  const pendingAnswersUsers = game.pending_answer && game.pending_answer.length && game.pending_answer.map( (p) => p.user.username )
  const isChigiriki = defend_from && defend_from.name == 'chigiriki'
  const isManrikigusari = defend_from && defend_from.name == 'manrikigusari'
  return {
    game_ended: game.game_ended,
    players: game.players,
    pendingAnswers: pendingAnswers,
    pendingAnswersUsers: pendingAnswersUsers,
    turn: game.turn,
    isCounterAttack: defend_from && defend_from.name == 'contrataque',
    resolveBushido: game.resolve_bushido,
    discard_stop: defend_from && (defend_from.type == 'weapon' || defend_from.name == 'grito_de_batalla') && !game.resolve_bushido,
    discard_weapon: defend_from && defend_from.name == 'jiujitsu' || isChigiriki,
    discard_any: isManrikigusari && defend_from.already_damaged || defend_from && defend_from.name == 'intuicion',
    waitForIntuicion: defend_from && defend_from.name == 'intuicion',
    tanto: defend_from && defend_from.name == 'tanto',
  }
}

export default connect(mapStateToProps)(Player)
