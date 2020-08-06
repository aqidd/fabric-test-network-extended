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

const name = 'Creating cars.';
module.exports.info = name;

const helper = require('./helper');

let txIndex = 0;
let colors = ['blue', 'red', 'green', 'yellow', 'black', 'purple', 'white', 'violet', 'indigo', 'brown'];
let makes = ['Toyota', 'Ford', 'Hyundai', 'Volkswagen', 'Tesla', 'Peugeot', 'Chery', 'Fiat', 'Tata', 'Holden'];
let models = ['Prius', 'Mustang', 'Tucson', 'Passat', 'S', '205', 'S22L', 'Punto', 'Nano', 'Barina'];
let owners = ['Tomoko', 'Brad', 'Jin Soo', 'Max', 'Adrianna', 'Michel', 'Aarav', 'Pari', 'Valeria', 'Shotaro'];
let bc, contx;

module.exports.init = function(blockchain, context, args) {
    bc = blockchain;
    contx = context;

    return Promise.resolve();
};

module.exports.run = function() {
    txIndex++;
    const carNumber = helper.generateNumber(contx.clientIdx, `${name.hashCode()}${txIndex}`);
    const carColor = colors[Math.floor(Math.random() * colors.length)];
    const carMake = makes[Math.floor(Math.random() * makes.length)];
    const carModel = models[Math.floor(Math.random() * models.length)];
    const carOwner = owners[Math.floor(Math.random() * owners.length)];

    const args = {
        chaincodeFunction: 'createCar',
        chaincodeArguments: [carNumber, carMake, carModel, carColor, carOwner]
    };

    return bc.invokeSmartContract(contx, 'fabcar', 'v1', args, 30);
};

module.exports.end = function() {
    return Promise.resolve();
};
