import React, { useState, useEffect } from 'react';
import { getWinners } from '../services/chessServices';
import './style.css';

const ChessWinnerList = () => {
  const [winnerList, setWinnerList] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchWinners = async () => {
      try {
        const data = await getWinners();
        setWinnerList(data);
      } catch (err) {
        setError(err.message);
      }
    };
    fetchWinners();
  }, []);

  return (
    <div className="winner-list">
      <h1 className="header">List of Winners: {winnerList.length}</h1>
      {error && <p className="error-message">Error: {error}</p>}
      <div className="table-container">
        <table className="winner-table">
          <thead>
            <tr>
              <th>Player ID</th>
              <th>Full Name</th>
              <th>Total Matches</th>
              <th>Total Wins</th>
              <th>Win Rate %</th>
            </tr>
          </thead>
          <tbody>
            {winnerList.map((winner, index) => (
              <tr className='data-list' key={index}>
                <td>{winner.playerId}</td>
                <td>{winner.fullName}</td>
                <td>{winner.totalMatches}</td>
                <td>{winner.totalWins}</td>
                <td>{winner.winPercentage}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ChessWinnerList;
