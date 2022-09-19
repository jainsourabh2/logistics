import React, { useState } from 'react';
import axios from 'axios';

/**
 * Prefix row-key lookup form. Returns all prefix-matching results.
 */
export const VendorLookupForm = (props) => {
    const [id, setId] = useState('');
    const [submitType, setSubmitType] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        axios.post(`/api/${submitType}`, {
            packageId: id,
        }).then(res => {
            // console.log('res', res.data)
            props.dataCallback(res.data);
            setId('');
        });
    };
    return (
        <div>
            <h2>Vendor Package Lookup </h2>
            <p>Allows prefix searching.</p>
            <form onSubmit={handleSubmit}>
                <label>
                    ID:
                </label>
                <input type='text' name='packageId' onChange={(e) => setId(e.target.value)} value={id} />
                <input type='submit' value='Latest Location' onClick={() => setSubmitType('getPrefix')} />
                <input type='submit' value='History' onClick={() => setSubmitType('getPrefixAll')} />            </form>
        </div>

    );
};
