import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'
import Card from './Card'

const Discarded = props => (
  <div className="discarded">
    <span className="size">{props.size} cards</span>
    { props.size == 0 && <Card /> }
    { props.size > 0 && props.topCard && <Card name={props.topCard.name} visible={true}/> }
  </div>
)

Discarded.defaultProps = {
  size: 0,
  topCard: {}
}

Discarded.propTypes = {
  size: PropTypes.number,
  topCard: PropTypes.object,
}

const mapStateToProps = (state) => {
  const { game } = state
  return { 
    size: game.discarded.length,
    topCard: game.discarded[game.discarded.length - 1],
  }
}

export default connect(mapStateToProps)(Discarded)
