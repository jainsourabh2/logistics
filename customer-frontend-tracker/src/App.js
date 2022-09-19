import './App.css';
import React, { useState } from 'react';

import { CustomerLookupForm } from './components/CustomerLookupForm';
import { VendorEditForm } from './components/VendorEditForm';
import { DisplayForm } from './components/DisplayForm';
import { VendorLookupForm } from './components/VendorLookupForm';

function App() {
  // Results from the API will be stored in displayData and transferred 
  // to DisplayForm to display. 
  const [displayData, setDisplayData] = useState('');
  return (
    <div className="App">
      <h1 className='title'>Package Tracker Demo</h1>
      <div className='grid'>
        <CustomerLookupForm dataCallback={setDisplayData} />
        <VendorEditForm dataCallback={setDisplayData} />
        <DisplayForm displayData={displayData} />
        <VendorLookupForm dataCallback={setDisplayData} />
      </div>
    </div >
  );
}

export default App;
