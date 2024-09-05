import React, { useState } from 'react';
import { getCountry } from '../services/chessServices';
import './style.css';

const ChessCountryList = () => {
  const [country, setCountry] = useState('');
  const [order, setOrder] = useState(false); // Default order value
  const [countryList, setCountryList] = useState([]);
  const [error, setError] = useState('');

  const handleFetchData = async (e) => {
    e.preventDefault();
    if (!country.trim()) {
      setError('Please enter a country.');
      return;
    }
    setError('');
    try {
      const data = await getCountry(country, order);
      setCountryList(data);
    } catch (err) {
      setError('Error fetching country data.');
    }
  };

  return (
    <div className="country-list">
      <form className="form-group" onSubmit={handleFetchData}>
        <div className="form-group-item">
          <label className="form-label">Country:</label>
          <input
            type="text"
            className="form-control"
            value={country}
            onChange={(e) => setCountry(e.target.value)}
            placeholder="Enter country"
          />
        </div>
        <div className="form-group-item">
          <label className="form-label">Order:</label>
          <select
            className="form-control"
            value={order}
            onChange={(e) => setOrder(e.target.value === 'true')}
          >
            <option value={false}>Descending</option>
            <option value={true}>Ascending</option>
          </select>
        </div>
        <button className="submit-button" type="submit">
          Submit
        </button>
      </form>
      {error && <p className="error-message">{error}</p>}
      {countryList.length > 0 && (
        <div className="table-container">
          <h1 className="table-header">List of Matches</h1>
          <table className="data-table">
            <thead>
              <tr>
                <th>Player ID</th>
                <th>Full Name</th>
                <th>Last Name</th>
                <th>Country</th>
                <th>World Ranking</th>
                <th>Total Matches</th>
              </tr>
            </thead>
            <tbody>
              {countryList.map((player, index) => (
                <tr key={index}>
                  <td>{player.playerId}</td>
                  <td>{player.firstName}</td>
                  <td>{player.lastName}</td>
                  <td>{player.country}</td>
                  <td>{player.currentWorldRanking}</td>
                  <td>{player.totalMatchesPlayed}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default ChessCountryList;
