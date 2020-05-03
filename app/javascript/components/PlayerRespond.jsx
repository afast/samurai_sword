import React from 'react'
import { connect } from 'react-redux'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { discardWeapon, takeDamage, playStop } from '../actions/game'

class PlayerRespond extends React.Component {
  constructor(props) {
    super(props);
    this.takeDamage = this.takeDamage.bind(this);
    this.playStop = this.playStop.bind(this);
    this.discardWeapon = this.discardWeapon.bind(this);
    this.state = {};
  }

  takeDamage () {
    console.log('takeDamage')
    this.props.takeDamage(this.props.game.id, this.props.character);
  }

  playStop () {
    console.log('playStop')
    this.props.playStop(this.props.game.id, this.props.character);
  }

  discardWeapon () {
    console.log('discard Weapon')
    if (this.props.wantsToPlay && this.props.wantsToPlay.type == 'weapon')
      this.props.discardWeapon(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    else
      this.setState({ errorMessage: 'Please select a Weapon' })
  }

  render () {
    const { phase } = this.props.game;
    const { discard_weapon, cards, discard_stop, wantsToPlay } = this.props;
    const has_stop_card = cards.map( (c) => c.name ).includes('parada')
    const has_weapon = cards.map( (c) => c.type ).includes('weapon')
    const { errorMessage } = this.state;
    console.log(phase)
    return (
      <div className="player__respond">
        { (!wantsToPlay || !wantsToPlay.type) && errorMessage && <span>{errorMessage}</span> }
        <div><button onClick={this.takeDamage}>Aceptar Daño</button></div>
        { discard_stop && has_stop_card && <div><button onClick={this.playStop}>Usar Parada</button></div> }
        { discard_weapon && has_weapon && <div><button onClick={this.discardWeapon}>Descartar Arma</button></div> }
      </div>
    )
  }
}


PlayerRespond.defaultProps = {
  game: {}
}

PlayerRespond.propTypes = {
  game: PropTypes.object,
  cards: PropTypes.array,
  discard_stop: PropTypes.bool,
  discard_weapon: PropTypes.bool,
  character: PropTypes.string
}

const mapStateToProps = (state) => {
  const { game, wantsToPlay } = state
  return { 
    game: game,
    discard_stop: game.defend_from.type == 'weapon' || game.defend_from.name == 'grito_de_batalla',
    discard_weapon: game.defend_from.name == 'jiujitsu',
    wantsToPlay: wantsToPlay,
  }
}

const mapDispatchToProps = {
  takeDamage,
  discardWeapon,
  playStop
}

export default connect(mapStateToProps, mapDispatchToProps)(PlayerRespond)
