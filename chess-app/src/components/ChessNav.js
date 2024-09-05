import React from 'react'
import './style.css'
import { Link } from 'react-router-dom'

const ChessNav = () => {
  return <nav className='chessNav'>
    <Link className='nav-link' to='/'>Home</Link>
    <Link className='nav-link' to='/players'>Performance</Link>
    <Link className='nav-link' to='/aboveavg'>Above average</Link>
    <Link className='nav-link' to='/country'>Get by country</Link>
    <Link className='nav-link' to='/addmatch'>Add Match</Link>
  </nav>
}

export default ChessNav
