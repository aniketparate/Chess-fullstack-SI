import React from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import ChessHome from '../components/ChessHome'
import ChessNav from '../components/ChessNav'
import ChessPlayerList from '../components/ChessPlayerList'
import ChessWinnerList from '../components/ChessWinnerList'
import ChessCountryList from '../components/ChessCountry'
import ChessAddMatch from '../components/ChessAddMatch'

const ChessRouterConfig = () => {
  return <BrowserRouter>
    <ChessNav />
    <Routes>
        <Route path='/' element={<ChessHome />} />
        <Route path='/players' element={<ChessPlayerList />} />
        <Route path='/aboveavg' element={<ChessWinnerList />} />
        <Route path='/country' element={<ChessCountryList />} />
        <Route path='/addmatch' element={<ChessAddMatch />} />
    </Routes>
  </BrowserRouter>
}

export default ChessRouterConfig
