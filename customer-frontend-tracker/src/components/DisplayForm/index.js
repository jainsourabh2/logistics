import React from 'react';

/**
 * Displays returned row results from other forms.
 * @param {dict} props.displayData 
 */
export const DisplayForm = (props) => {
    // Converts epoch microsecond timestamps to human-readable form. 
    const timestampToHumanReadable = (timestamp) => {
        return new Date(parseInt(timestamp) / 1000).toLocaleString('en-US');
    };
    // Esoteric function to unpack returned results into an dict
    // Dict format: {packageID: [(loc1, ts1), (loc2,ts2)...]}
    const unpack = (data) => {
        const displayDict = {};
        Object.keys(data).forEach(packageId => {
            displayDict[packageId] = [];
            data[packageId].delivery_stats.status.forEach(locationData => {
                let trans_time = JSON.parse(JSON.stringify(locationData.value))
                let time = JSON.parse(trans_time)
                displayDict[packageId].push([
                    time.transaction_time,
                    time.status
                ]);
            });
        });
        return displayDict;
    };
    try {
        const displayDict = unpack(props.displayData);
        return <div>
            <h2>Package Lookup Result</h2>
            <div>Total entries returned: {Object.keys(displayDict).length}</div>
            <div style={{
                overflow: 'auto',
                height: '30vh',
                border: '0.5px solid lightgrey'
            }}>
                {Object.entries(displayDict).map(([packageId, locationArr]) => {
                    return (
                        <>
                            <div>Package ID: {packageId}</div>
                            {
                                locationArr.map(([timestamp, location]) => (
                                    <div>{timestamp} - {location}</div>
                                ))
                            }
                            <br />
                        </>

                    );
                })}
            </div>
        </div>;
    } catch (err) {
        console.log(err)
        return <div>
            <h2>Package Lookup Result</h2>
            <div>Error Block</div>
        </div>;
    }


};