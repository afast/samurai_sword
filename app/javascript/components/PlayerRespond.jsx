import React from 'react'
import { connect } from 'react-redux'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { discardWeapon, proposeForIntuicion, hanzoAbility, kanbeiAbility, playCard, okuniAbility, defendBushido, takeDamage, playStop, playCounterStop, playWeaponAlsoStop } from '../actions/game'

class PlayerRespond extends React.Component {
  constructor(props) {
    super(props)
    this.takeDamage = this.takeDamage.bind(this)
    this.takeDamageAndUseOneCampesino = this.takeDamageAndUseOneCampesino.bind(this)
    this.takeDamageAndUseTwoCampesinos = this.takeDamageAndUseTwoCampesinos.bind(this)
    this.takeDamageAndUseThreeCampesinos = this.takeDamageAndUseThreeCampesinos.bind(this)
    this.playStop = this.playStop.bind(this)
    this.playCounterStop = this.playCounterStop.bind(this)
    this.playWeaponAlsoStop = this.playWeaponAlsoStop.bind(this)
    this.discardWeapon = this.discardWeapon.bind(this)
    this.discardCard = this.discardCard.bind(this)
    this.hanzoAbility = this.hanzoAbility.bind(this)
    this.kanbeiAbility = this.kanbeiAbility.bind(this)
    this.okuniAbility = this.okuniAbility.bind(this)
    this.ignoreOkuniAbility = this.ignoreOkuniAbility.bind(this)
    this.proposeForIntuicion = this.proposeForIntuicion.bind(this)
    this.state = {}
  }

  takeDamage () {
    this.props.takeDamage(this.props.game.id, this.props.character);
  }

  takeDamageAndUseOneCampesino () {
    this.props.takeDamage(this.props.game.id, this.props.character, 1);
  }

  takeDamageAndUseTwoCampesinos () {
    this.props.takeDamage(this.props.game.id, this.props.character, 2);
  }

  takeDamageAndUseThreeCampesinos () {
    this.props.takeDamage(this.props.game.id, this.props.character, 3);
  }

  hanzoAbility () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.type == 'weapon')
      this.props.hanzoAbility(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    else
      this.setState({ errorMessage: 'Elige un arma' })
  }

  kanbeiAbility () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.type == 'property' && this.props.visible_cards.map( (c) => c.name ).includes(this.props.wantsToPlay.name)) {
      this.props.kanbeiAbility(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    } else {
      this.setState({ errorMessage: 'Elige una propiedad en juego' })
    }
  }

  okuniAbility () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.symbol == 'origami') {
      this.props.okuniAbility(this.props.game.id, this.props.character, this.props.wantsToPlay.name)
    } else {
      this.setState({ errorMessage: 'Elige una carta con origami' })
    }
  }

  ignoreOkuniAbility () {
    const { playCard, game, character } = this.props;
    const turnPlayer = game.players[game.turn]
    const defend_from = game.defend_from
    playCard(turnPlayer, defend_from, character, defend_from.what_card, true)
  }

  playStop () {
    this.props.playStop(this.props.game.id, this.props.character);
  }

  playCounterStop () {
    this.props.playCounterStop(this.props.game.id, this.props.character);
  }

  proposeForIntuicion () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.name) {
      this.props.proposeForIntuicion(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    } else {
      this.setState({ errorMessage: 'Debes elegir una carta' })
    }
  } 

  discardCard () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.name) {
      this.props.discardWeapon(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    } else {
      this.setState({ errorMessage: 'Debes descartar una carta' })
    }
  } 

  playWeaponAlsoStop () {
    if (this.props.wantsToPlay && this.props.wantsToPlay.is_also == 'parada') {
      this.props.playWeaponAlsoStop(this.props.game.id, this.props.character, this.props.wantsToPlay.name);
    } else {
      this.setState({ errorMessage: 'Elige un arma que tambien es parada' });
    }
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
    const { discard_weapon, enableOkuniAbility, acceptAction, defendFromWeapon, defendFromIntuicion, defendFromHeridaSangrante, discard_any, select_kote, character, cards, visible_cards, discard_stop, wantsToPlay } = this.props;
    console.log('defend from herida sangrante: ' + defendFromHeridaSangrante)
    const has_stop_card = cards.map( (c) => c.name ).includes('parada')
    const has_counter_card = cards.map( (c) => c.name ).includes('contrataque')
    const has_weapon = cards.map( (c) => c.type ).includes('weapon')
    const has_weapon_also_stop_card = cards.map( (c) => c.is_also ).includes('parada')
    const hanzo_ability = character == 'hanzo' && discard_stop && has_weapon && cards.length > 1
    const kanbei_ability = character == 'kanbei' && discard_stop && visible_cards.length > 0
    const campesinos = visible_cards.filter(c => c.name == 'campesino').length
    const showOkuniAbility = enableOkuniAbility && character == 'okuni' && cards.map( (c) => c.symbol ).includes('origami')
    const aceptarDanio = !discard_any && !select_kote && !defendFromIntuicion && !acceptAction || defendFromHeridaSangrante
    const { errorMessage } = this.state;
    return (
      <div className="player__respond">
        { errorMessage && <span>{errorMessage}</span> }
        { aceptarDanio && <div><button onClick={this.takeDamage}>Aceptar Daño</button></div> }
        { aceptarDanio && campesinos >= 1 && <div><button onClick={this.takeDamageAndUseOneCampesino}>Usar 1 Campesino y Aceptar Daño</button></div> }
        { aceptarDanio && campesinos >= 2 && <div><button onClick={this.takeDamageAndUseTwoCampesinos}>Usar 2 Campesinos y Aceptar Daño</button></div> }
        { aceptarDanio && campesinos >= 3 && <div><button onClick={this.takeDamageAndUseThreeCampesinos}>Usar 3 Campesinos y Aceptar Daño</button></div> }
        { discard_stop && has_stop_card && <div><button onClick={this.playStop}>Usar Parada</button></div> }
        { discard_stop && defendFromWeapon && has_counter_card && <div><button onClick={this.playCounterStop}>Usar Contrataque</button></div> }
        { discard_stop && has_weapon_also_stop_card && <div><button onClick={this.playWeaponAlsoStop}>Usar Arma con Habilidad de Parada</button></div> }
        { discard_weapon && has_weapon && <div><button onClick={this.discardWeapon}>Descartar Arma</button></div> }
        { discard_any && <div><button onClick={this.discardCard}>Descartar Carta</button></div> }
        { hanzo_ability && <div><button onClick={this.hanzoAbility}>Descartar Arma como Parada</button></div> }
        { kanbei_ability && <div><button onClick={this.kanbeiAbility}>Descartar Propiedad como Parada</button></div> }
        { defendFromIntuicion && <div><button onClick={this.proposeForIntuicion}>Proponer Carta</button></div>  }
        { acceptAction && <div><button onClick={this.ignoreOkuniAbility}>Aceptar Acción</button></div> }
        { showOkuniAbility && <div><button onClick={this.okuniAbility}>Defender con Origami</button></div> }
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
  const isChigiriki = game.defend_from.name == 'chigiriki'
  const isManrikigusari = game.defend_from && game.defend_from.name == 'manrikigusari'
  const defendFromWeapon = game.defend_from.type == 'weapon'
  const enableOkuniAbility = game.defend_from.type == 'action'
  const acceptAction = enableOkuniAbility && !['grito_de_batalla', 'contrataque', 'jiujitsu'].includes(game.defend_from.name)

  return { 
    game: game,
    discard_stop: (game.defend_from.type == 'weapon' || ['grito_de_batalla', 'contrataque'].includes(game.defend_from.name)) && !game.resolve_bushido && !isChigiriki,
    discard_weapon: game.defend_from.name == 'jiujitsu' || game.resolve_bushido || isChigiriki,
    discard_any: isManrikigusari && game.defend_from.already_damaged,
    select_kote: game.defend_from.name == 'kote',
    defendFromWeapon: defendFromWeapon,
    defendFromIntuicion: game.defend_from.name == 'intuicion',
    defendFromHeridaSangrante: game.defend_from.name == 'herida_sangrante',
    wantsToPlay: wantsToPlay,
    enableOkuniAbility: enableOkuniAbility,
    acceptAction: acceptAction,
  }
}

const mapDispatchToProps = {
  takeDamage,
  discardWeapon,
  defendBushido,
  hanzoAbility,
  kanbeiAbility,
  playWeaponAlsoStop,
  playStop,
  playCard,
  okuniAbility,
  proposeForIntuicion,
  playCounterStop,
}

export default connect(mapStateToProps, mapDispatchToProps)(PlayerRespond)
