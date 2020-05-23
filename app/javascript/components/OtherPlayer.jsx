import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import ReactCSSTransitionGroup from 'react-addons-css-transition-group'
import Card from './Card'
import PlayAlert from './PlayAlert'

class OtherPlayer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { lostHonor: false, recoveredResistance: false,  lostResistance: false, cardRobbed: false };
    this.resetState = this.resetState.bind(this)
  }

  componentDidUpdate(prevProps) {
    if (prevProps.honor > this.props.honor) {
      this.setState({lostHonor: true})
    }
    if (prevProps.resistance > this.props.resistance) {
      this.setState({lostResistance: true})
    }
    if (prevProps.resistance < this.props.resistance) {
      this.setState({recoveredResistance: true})
    }
    if (prevProps.cards.length > this.props.cards.length) {
      this.setState({cardRobbed: true})
    }
    if (prevProps.visible_cards.length > this.props.visible_cards.length) {
      this.setState({cardRobbed: true})
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

  render() {
    const props = this.props;
    const { character, discard_stop, pendingAnswers, discard_weapon, players, turn, intuicionList } = this.props;
    const cardRobbed = !turn && !discard_stop && !discard_weapon && this.state.cardRobbed
    const callbackFunction = (name) => { this.resetState(name) }
    const proposedCardForIntuicion = intuicionList && intuicionList[character]

    return (
      <div className={`player ${props.turn ? 'player__turn' : (props.pendingAnswer ? 'player--pending_answer' : '')} ${props.firstChild ? 'player--first-child' : ''} ${props.lastChild ? 'player--last-child' : ''}`}>
        <div className='player__info'>
          <span className="player__info--other-name">{props.name}</span>
          <div className='honor'>
            <ReactCSSTransitionGroup transitionName="tokens" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
              { Array.from({length: props.honor}, () => <div className='shuriken_token' /> ) }
            </ReactCSSTransitionGroup>
          </div>
          <div className='resistance'>
            <ReactCSSTransitionGroup transitionName="tokens" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
              { Array.from({length: props.resistance}, () => <div className='heart_token' /> ) }
            </ReactCSSTransitionGroup>
          </div>
        </div>
        { this.state.lostHonor && <PlayAlert name='honor' callback={callbackFunction} /> }
        { this.state.lostResistance && <PlayAlert name='lostResistance' callback={callbackFunction}  /> }
        { cardRobbed && <PlayAlert name='robbed' callback={callbackFunction} /> }
        { this.state.recoveredResistance && <PlayAlert name='recoveredResistance' callback={callbackFunction} /> }
        <div className='player-cards--other'>
          { (props.role == 'shogun' || props.gameEnded) && <div className='player-cards__role'>
            <Card name={props.role} visible={true} />
            </div> }
          <div className='player-cards__character'>
            <Card name={character} visible={true} />
          </div>
          <div className={'player-cards__actions ' + (props.visible ? '' : 'hidden')}>
            {props.cards.map((card, index) =>
              <Card key={card.rkey} name={card.name} visible={props.visible} />
            )}
            { props.cards.length > 0 && <span className='player-cards__actions__amount'>{props.cards.length}</span> }
            { proposedCardForIntuicion && <div className='player-cards__actions__intuicion'>
              <Card name={proposedCardForIntuicion} visible={!pendingAnswers} clickable={!pendingAnswers} forIntuicion={true} character={character} />
            </div>}
          </div>
        </div>
        <div className="player__visible_cards">
          <ReactCSSTransitionGroup transitionName="card_animation" transitionEnterTimeout={3000} transitionLeaveTimeout={3000}>
            {props.visible_cards.map( (c, i) => <Card key={c.rkey} index={i} {...c} visible={true} clickable={false} />)}
          </ReactCSSTransitionGroup>
        </div>
      </div>
    )
  }
}

OtherPlayer.defaultProps = {
  visible: false,
  role: 'ninja',
  name: '',
  character: 'kojiro',
  cards: [{'name': 'bo'}, {name: 'bokken'}, {name: 'kusarigama'}],
  honor: 0,
  resistance: 0,
  pendingAnswer: false,
}

OtherPlayer.propTypes = {
  visible: PropTypes.bool,
  role: PropTypes.string,
  character: PropTypes.string,
  cards: PropTypes.array,
  honor: PropTypes.number,
  name: PropTypes.string,
  resistance: PropTypes.number,
  pendingAnswer: PropTypes.bool,
}

const mapStateToProps = (state) => {
  const { game } = state;
  const { defend_from, intuicion_list } = game;
  return {
    players: game.players,
    pendingAnswers: game.pending_answer && game.pending_answer.length > 0,
    discard_stop: defend_from && (defend_from.type == 'weapon' || defend_from.name == 'grito_de_batalla') && !game.resolve_bushido,
    discard_weapon: defend_from && defend_from.name == 'jiujitsu',
    intuicionList: intuicion_list,
  }
}

export default connect(mapStateToProps)(OtherPlayer)
