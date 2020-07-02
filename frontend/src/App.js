import React from 'react';
import './App.css';
import DataController from './components/DataController';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        SARS-CoV2 Mutfunc
      </header>
      <p>
        <DataController/>
      </p>
    </div>
  );
}

export default App;
