const changeCarOwner = require('./changeCarOwner')
const createCar = require('./createCar')
const queryCar = require('./queryCar')
const queryAllCars = require('./queryAllCars')

module.exports.info = 'Random Transaction Combinations';

module.exports.init = async function (blockchain, context, args) {
    await Promise.all([
        changeCarOwner.init(blockchain, context, args),
        createCar.init(blockchain, context, args),
        queryCar.init(blockchain, context, args),
        queryAllCars.init(blockchain, context, args)
    ])
    return Promise.resolve()
};

module.exports.run = function () {
    const randoSeed = Math.floor(Math.random() * Math.floor(4))
    let tx
    switch (randoSeed) {
        case 0:
            tx = changeCarOwner
            break
        case 1:
            tx = createCar
            break
        case 2:
            tx = queryCar
            break
        case 3:
            tx = queryAllCars
            break
        default:
            console.error('RANDOM ERROR HAPPENED')
            break
    }
    return tx.run()
};

module.exports.end = async function () {
    return Promise.resolve();
};