import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { wantsToPlay } from '../actions/game'

class Card extends React.Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick () {
    const { phase, resolveBushido, clickable, index } = this.props;
    if ((phase >= 3 || resolveBushido) && clickable && index >= 0 ) {
      this.props.wantsToPlay(this.props)
    }
  }

  render () {
    let card_visible = this.props.visible;
    const { gameEnded, name } = this.props;
    if (gameEnded && name == 'daimio') {
      card_visible = true
    }

    return (
      <div className={'card ' + (card_visible ? name :  'hidden')} onClick={this.handleClick}>
      </div>
    )
  }
}

Card.defaultProps = {
  name: 'Card',
  visible: false,
  clickable: false,
  index: -1
}

Card.propTypes = {
  name: PropTypes.string,
  type: PropTypes.string,
  distance: PropTypes.number,
  damage: PropTypes.number,
  visible: PropTypes.bool,
  clickable: PropTypes.bool,
  index: PropTypes.number
}

const mapStateToProps = (state) => {
  return { 
    phase: state.game.phase,
    resolveBushido: state.game.resolve_bushido,
    gameEnded: state.game.game_ended,
  }
}

const mapActionsToProps = { wantsToPlay }

export default connect(mapStateToProps, mapActionsToProps)(Card)
