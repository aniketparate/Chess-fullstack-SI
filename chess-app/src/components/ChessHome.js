import React from 'react'
import './style.css'

const ChessHome = () => {
  return (
    <div className="home-container">
      <header className="banner">
        <h1 className="banner-title">Welcome to Our Chess Page</h1>
        <p className="banner-subtitle">Empowering Dreams and Making a Difference</p>
      </header>
      <section className="content">
        <h2>About Us</h2>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.</p>
        <button className="cta-button">Learn More</button>
      </section>
    </div>
  );
}

export default ChessHome
