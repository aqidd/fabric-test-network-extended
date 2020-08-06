/*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

'use strict';

const name = 'Initialize Ledger with Cars.';
module.exports.info = name;

const helper = require('./helper');
const logger = require('@hyperledger/caliper-core').CaliperUtils.getLogger('init-module');

const colors = ['blue', 'red', 'green', 'yellow', 'black', 'purple', 'white', 'violet', 'indigo', 'brown'];
const makes = ['Toyota', 'Ford', 'Hyundai', 'Volkswagen', 'Tesla', 'Peugeot', 'Chery', 'Fiat', 'Tata', 'Holden'];
const models = ['Prius', 'Mustang', 'Tucson', 'Passat', 'S', '205', 'S22L', 'Punto', 'Nano', 'Barina'];
const owners = ['Tomoko', 'Brad', 'Jin Soo', 'Max', 'Adrianna', 'Michel', 'Aarav', 'Pari', 'Valeria', 'Shotaro'];
let bc, contx;

module.exports.init = async function(blockchain, context, args) {
    bc = blockchain
    contx = context
    let assets = args.assets

    while(assets >= 0) {
        const carNumber = helper.generateNumber(context.clientIdx, assets);
        const color = colors[Math.floor(Math.random() * colors.length)];
        const make = makes[Math.floor(Math.random() * makes.length)];
        const model = models[Math.floor(Math.random() * models.length)];
        const owner = owners[Math.floor(Math.random() * owners.length)];
        
        let promises = []
        const myArgs = {
            chaincodeFunction: 'createCar',
            chaincodeArguments: [carNumber, make, model, color, owner]
        };
        
        promises.push(bc.invokeSmartContract(context, 'fabcar', 'v1', myArgs, 30));

        assets--;
    }
    const res = await Promise.all(promises)
    logger.debug(`===INITIALIZATION RESULT SIZE ${res.length}===`)
    return Promise.resolve();
};

module.exports.run = function() {
    const args = {
        chaincodeFunction: 'queryCar',
        chaincodeArguments: [helper.generateNumber(0, 0)]
    };

    return bc.bcObj.querySmartContract(contx, 'fabcar', 'v1', args, 30);
};

module.exports.end = function() {
    return Promise.resolve();
};
