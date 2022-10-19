import React, { useState } from 'react';
import axios from 'axios';

/**
 * Single row-key lookup form. 
 */
export const CustomerLookupForm = (props) => {
    const [id, setId] = useState('');
    const [submitType, setSubmitType] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        axios.post(`https://bigtable-apis-q5cbfb3b6a-el.a.run.app/api/${submitType}`, {
            packageId: id,
        }).then(res => {
            // console.log('res', res.data)
            props.dataCallback(res.data);
            setId('');
        });
    };
    return (
        <div>
            <h2>Customer Package Lookup </h2>
            <form onSubmit={handleSubmit}>
                <label>
                    ID:
                </label>
                <input type='text' name='packageId' onChange={(e) => setId(e.target.value)} value={id} />
                <input type='submit' value='Latest Location' onClick={() => setSubmitType('get')} />
                <input type='submit' value='History' onClick={() => setSubmitType('getAll')} />
            </form>
        </div>

    );
};
