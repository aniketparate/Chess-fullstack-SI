import React, { useState } from 'react';
import { addMatch } from '../services/chessServices';
import './style.css';

const ChessAddMatch = () => {
  const [match, setMatch] = useState({
    player1Id: '',
    player2Id: '',
    matchDate: '',
    matchLevel: '',
    winnerId: '',
  });

  const [errors, setErrors] = useState({});
  const [successMessage, setSuccessMessage] = useState('');
  
  const handleChange = (e) => {
    const { id, value } = e.target;
    setMatch((prevMatch) => ({ ...prevMatch, [id]: value }));
  };

  const validateForm = () => {
    const errors = {};
    if (!match.player1Id) errors.player1Id = 'Player 1 ID is required';
    if (!match.player2Id) errors.player2Id = 'Player 2 ID is required';
    if (!match.matchDate) errors.matchDate = 'Match Date is required';
    if (!match.matchLevel) errors.matchLevel = 'Match Level is required';
    if (!match.winnerId) errors.winnerId = 'Winner ID is required';
    
    return errors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formErrors = validateForm();
    
    if (Object.keys(formErrors).length > 0) {
      setErrors(formErrors);
      return;
    }

    try {
      const response = await addMatch(match);
      if (response) {
        setSuccessMessage('Match added successfully!');
        setMatch({
          player1Id: '',
          player2Id: '',
          matchDate: '',
          matchLevel: '',
          winnerId: '',
        });
        setErrors({});
      } else {
        throw new Error('Failed to add match');
      }
    } catch (error) {
      setErrors({ form: error.message });
    }
  };

  return (
    <div className="form-container">
      <h1>Add a New Match</h1>
      {successMessage && <p className="success-message">{successMessage}</p>}
      {errors.form && <p className="error-message">{errors.form}</p>}
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="player1Id">Player 1 ID</label>
          <input
            type="number"
            id="player1Id"
            value={match.player1Id}
            onChange={handleChange}
            className="form-control"
          />
          {errors.player1Id && <p className="error-message">{errors.player1Id}</p>}
        </div>
        <div className="form-group">
          <label htmlFor="player2Id">Player 2 ID</label>
          <input
            type="number"
            id="player2Id"
            value={match.player2Id}
            onChange={handleChange}
            className="form-control"
          />
          {errors.player2Id && <p className="error-message">{errors.player2Id}</p>}
        </div>
        <div className="form-group">
          <label htmlFor="matchDate">Match Date</label>
          <input
            type="date"
            id="matchDate"
            value={match.matchDate}
            onChange={handleChange}
            className="form-control"
          />
          {errors.matchDate && <p className="error-message">{errors.matchDate}</p>}
        </div>
        <div className="form-group">
          <label htmlFor="matchLevel">Match Level</label>
          <input
            type="text"
            id="matchLevel"
            value={match.matchLevel}
            onChange={handleChange}
            className="form-control"
          />
          {errors.matchLevel && <p className="error-message">{errors.matchLevel}</p>}
        </div>
        <div className="form-group">
          <label htmlFor="winnerId">Winner ID</label>
          <input
            type="number"
            id="winnerId"
            value={match.winnerId}
            onChange={handleChange}
            className="form-control"
          />
          {errors.winnerId && <p className="error-message">{errors.winnerId}</p>}
        </div>
        <button type="submit" className="submit-button">Add New Match</button>
      </form>
    </div>
  );
};

export default ChessAddMatch;
