import './App.css';
import React, { useState } from 'react';

import { CustomerLookupForm } from './components/CustomerLookupForm';
import { DisplayForm } from './components/DisplayForm';

function App() {
  // Results from the API will be stored in displayData and transferred 
  // to DisplayForm to display. 
  const [displayData, setDisplayData] = useState('');
  return (
    <div className="App">
      <h1 className='title'>Next 2022 - Logistics Package Tracker Demo</h1>
      <div className='grid'>
        <CustomerLookupForm dataCallback={setDisplayData} />
        <DisplayForm displayData={displayData} />
      </div>
    </div >
  );
}

export default App;
