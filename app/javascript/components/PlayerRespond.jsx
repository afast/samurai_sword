import React from 'react'
import { connect } from 'react-redux'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { discardWeapon, hanzoAbility, defendBushido, takeDamage, playStop } from '../actions/game'

class PlayerRespond extends React.Component {
  constructor(props) {
    super(props);
    this.takeDamage = this.takeDamage.bind(this);
    this.playStop = this.playStop.bind(this);
    this.discardWeapon = this.discardWeapon.bind(this);
    this.hanzoAbility = this.hanzoAbility.bind(this);
    this.state = {};
  }

  takeDamage () {
    this.props.takeDamage(this.props.game.id, this.props.character);
  }

  hanzoAbility () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.type == 'weapon')
      this.props.hanzoAbility(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    else
      this.setState({ errorMessage: 'Elige un arma' })
  }

  playStop () {
    this.props.playStop(this.props.game.id, this.props.character);
  }

  discardWeapon () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.type == 'weapon')
      if (this.props.resolveBushido) {
        this.props.defendBushido(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
      } else {
        this.props.discardWeapon(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
      }
    else
      this.setState({ errorMessage: 'Elige un arma' })
  }

  render () {
    const { phase } = this.props.game;
    const { discard_weapon, character, cards, discard_stop, wantsToPlay } = this.props;
    const has_stop_card = cards.map( (c) => c.name ).includes('parada')
    const has_weapon = cards.map( (c) => c.type ).includes('weapon')
    const hanzo_ability = character == 'hanzo' && discard_stop && has_weapon && cards.length > 1
    const { errorMessage } = this.state;
    return (
      <div className="player__respond">
        { (!wantsToPlay || !wantsToPlay.type) && errorMessage && <span>{errorMessage}</span> }
        <div><button onClick={this.takeDamage}>Aceptar Daño</button></div>
        { discard_stop && has_stop_card && <div><button onClick={this.playStop}>Usar Parada</button></div> }
        { discard_weapon && has_weapon && <div><button onClick={this.discardWeapon}>Descartar Arma</button></div> }
        { hanzo_ability && <div><button onClick={this.hanzoAbility}>Descartar Arma como Parada</button></div> }
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
    discard_stop: (game.defend_from.type == 'weapon' || game.defend_from.name == 'grito_de_batalla') && !game.resolve_bushido,
    discard_weapon: game.defend_from.name == 'jiujitsu' || game.resolve_bushido,
    wantsToPlay: wantsToPlay,
  }
}

const mapDispatchToProps = {
  takeDamage,
  discardWeapon,
  defendBushido,
  hanzoAbility,
  playStop
}

export default connect(mapStateToProps, mapDispatchToProps)(PlayerRespond)
