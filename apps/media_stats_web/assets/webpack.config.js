const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const Dotenv = require('dotenv-webpack');

let config_a = {
 optimization: {
   minimizer: [
     new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
     new OptimizeCSSAssetsPlugin({})
   ]
 },
 entry: {
     './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
 },
 output: {
   filename: 'app.js',
   path: path.resolve(__dirname, '../priv/static/js')
 },
 module: {
   rules: [
     {
       test: /\.js$/,
       exclude: /node_modules/,
       use: {
         loader: 'babel-loader'
       }
     },
     {
       test: /\.css$/,
       use: [MiniCssExtractPlugin.loader, 'css-loader']
     }
   ]
 },
 plugins: [
   new MiniCssExtractPlugin({ filename: '../css/app.css' }),
   new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
   new Dotenv({
     path: path.resolve(__dirname,'.env')
   })
 ]
}

let config_b = {
 entry: {
     './js/pusher_index.js': ['./js/pusher_index.js'].concat(glob.sync('./vendor/**/*.js'))
 },
 output: {
   filename: 'pusher.js',
   path: path.resolve(__dirname, '../priv/static/js'),
   libraryTarget: 'var',
   library: 'Pusher',
 },
 module: {
   rules: [
     {
       test: /\.js$/,
       exclude: /node_modules/,
       use: {
         loader: 'babel-loader'
       }
     }
   ]
 },
  plugins: [
    new Dotenv({
      path: path.resolve(__dirname,'.env')
    })
  ]
}

module.exports = [
    config_a,
    config_b
];
