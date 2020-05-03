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
    console.log(this.props.phase)
    if (this.props.phase >= 3 && this.props.clickable && this.props.index >= 0 ) {
      this.props.wantsToPlay(this.props)
    } else {
      console.log('card not clickable')
    }
  }

  render () {
    return (
      <div className={'card ' + (this.props.visible ? this.props.name :  'hidden')} onClick={this.handleClick}>
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
  return { phase: state.game.phase }
}

const mapActionsToProps = { wantsToPlay }

export default connect(mapStateToProps, mapActionsToProps)(Card)
