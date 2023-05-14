/** @type {import('next').NextConfig} */
const DFXWebPackConfig = require('./dfx.webpack.config');
DFXWebPackConfig.initCanisterIds();

const nextConfig = {};

module.exports = nextConfig;
