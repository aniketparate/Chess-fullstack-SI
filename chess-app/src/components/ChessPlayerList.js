import React, { useState, useEffect } from "react";
import { getPlayers } from "../services/chessServices";
import './style.css';

const ChessPlayerList = () => {
  const [playerList, setPlayerList] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPlayers = async () => {
      try {
        const data = await getPlayers();
        setPlayerList(data);
      } catch (err) {
        setError(err.message);
      }
    };
    fetchPlayers();
  }, []);

  return (
    <div className="player-list">
      <h1 className="header">List of Players: {playerList.length}</h1>
      {error && <p className="error-message">Error: {error}</p>}
      <div className="table-container">
        <table className="player-table">
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
            {playerList.map((player, index) => (
              <tr className="data-list" key={index}>
                <td>{player.playerId}</td>
                <td>{player.fullName}</td>
                <td>{player.totalMatches}</td>
                <td>{player.totalWins}</td>
                <td>{player.winPercentage}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ChessPlayerList;