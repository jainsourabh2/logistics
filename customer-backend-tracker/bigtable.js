const { Bigtable } = require('@google-cloud/bigtable');

class BigTableReader {
    constructor(instanceName, tableName) {
        const bigtable = new Bigtable();
        this.instance = bigtable.instance(instanceName);
        this.table = this.instance.table(tableName);
    }

    /**
     * Sample function for row key verification.
     * Checks if it matches our predefined schema.
     * Row key format:  # shipperId # datetime              # serviceId + randomHash
     *                  # 6 char    # YYYYMMDDHHmmSS (14)   # 1 char   + 3 char
     * 
     * Total key length: 24
     * 
     * char is defined as uppercase/lowercase letters + 0-9
     * 
     * datetime can be hashed to compress space even more, 
     * but the sacrificed complexity and readability was not worth it.
     * 
     * @param {string} keyOrPrefix
     * @returns {int} length of the keyOrPrefix
     */
    checkRowKeyOrPrefix(keyOrPrefix) {
        const regexExpr = /#[A-z0-9]{6}#[0-9]{14}#[A-z0-9]{4}/;
        const padding = '#ACd142#20220813082213#1111';

        const fullKey = keyOrPrefix + padding.substring(keyOrPrefix.length);
        if (fullKey.match(regexExpr)) {
            return keyOrPrefix.length;
        }
        return -1;
    }

    /**
     * Read rows by prefix.
     * @param {string} prefix 
     * @param {dictionary} filter
     * @returns {dictionary} {rowKey1: {locations:[loc1, loc2], },}
     */
    readRowByPrefix(
        prefix,
        filter = null,
    ) {
        return new Promise(async (resolve, reject) => {
            const rowResult = {};
            await this.table
                .createReadStream({
                    prefix,
                    filter,
                })
                .on('error', err => {
                    reject('Row with prefix does not exist.');
                })
                .on('data', row => {
                    rowResult[row.id] = row.data;
                })
                .on('end', () => {
                    resolve(rowResult);
                });
        });
    }

    /**
     * Read a single row. 
     * @param {string} packageId 
     * @param {dictionary} filter 
     * @returns 
     */
    readRow(packageId, filter = null) {
        return new Promise(async (resolve, reject) => {
            try {
                const [result] = await this.table.row(packageId).get({ filter });
                resolve({
                    // Transform result into dictionary of format:
                    // [packageId] : [rowData]
                    [packageId]: {
                        ...result.data
                    }
                });
            } catch (err) {
                reject('Row with key does not exist.');
            }
        });
    }

    // Updates a row if the row with row-key already existed before, else returns failed promise.
    updateRow(packageId, location) {
        if (!packageId) {
            throw 'No package ID provided.';
        }
        if (!location) {
            throw 'No package location provided.';
        }

        return new Promise(async (resolve, reject) => {
            this.table.row(packageId).filter({
                row: packageId
            }, {
                onMatch: [{
                    method: 'insert',
                    data: {
                        locations: {
                            value: location
                        }
                    }
                }],
                onNoMatch: [],
            }).then(result => {
                if (result[0] == true) {
                    resolve(this.readRow(packageId));
                }
                else {
                    reject('Row update failed.');
                }
            }
            );
        });
    }

    // Creates a row if the row with row-key did not exist before.
    createRow(packageId, location) {
        if (!packageId) {
            throw 'No package ID provided.';
        }
        if (!location) {
            throw 'No package location provided.';
        }

        return new Promise(async (resolve, reject) => {
            this.table.row(packageId).filter({
                row: packageId
            }, {
                onNoMatch: [{
                    method: 'insert',
                    data: {
                        locations: {
                            value: location
                        }
                    }
                }],
            }).then(result => {
                if (result[0] == true) {
                    reject('Row already exists.');
                } else {
                    this.readRow(packageId).then(data =>
                        resolve(data)
                    ).catch(err => {
                        reject('Row creation failed.');
                    });
                }
            }
            );
        });
    }

    // Test function to clear a table with rowkeys starting with [0-9] 
    clearTable() {
        return new Promise(async (resolve, reject) => {
            for (const e of ['1', '2', '3', '4', '5', '6', '7', '8', '9']) {
                console.log(e, 'is being removed.');
                await this.table.deleteRows(e.toString()).then(result => {
                    console.log(result, e, 'prefix rows removed.');
                }).catch(err => {
                    console.log(e, 'error');
                });
            };
            resolve('All rows removed.');

        });
    }

}

module.exports = {
    BigTableReader
};