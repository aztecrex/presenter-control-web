'use strict';

const HtmlWebpackPlugin = require('html-webpack-plugin');

const path = require('path');

const webpack = require('webpack');

const isWebpackDevServer = process.argv.filter(a => path.basename(a) === 'webpack-dev-server').length;

const isWatch = process.argv.filter(a => a === '--watch').length

let plugins = []


if (isWebpackDevServer || !isWatch)
  plugins.push(
    function(){
      this.plugin('done', function(stats){
        process.stderr.write(stats.toString('errors-only'));
      });
    });

if (!isWebpackDevServer) {
  plugins.push(
    new webpack.optimize.CommonsChunkPlugin({
        name: 'vendor',
        minChunks: function (module) {
           return module.context && module.context.indexOf('node_modules') !== -1;
        }
    }),
    new webpack.optimize.CommonsChunkPlugin({
        name: 'manifest'
    })
  );
}

module.exports = {

  devServer: {
    contentBase: path.resolve(__dirname, 'build'),
    port: 4008,
    stats: 'errors-only',
    publicPath: '/',
    openPage: '/control.html'
  },

  entry: './src/entry.js',

  output: {
    path: path.join(__dirname, "build"),
    filename: isWebpackDevServer ? '[name].js' : '[name].[chunkhash].js'
  },

  module: {
    rules: [
      {
        test: /\.purs$/,
        use: [
          {
            loader: 'purs-loader',
            options: {
              pscPackage: true,
              src: [
                path.join('src', '**', '*.purs')
              ],
              bundle: !(isWebpackDevServer || isWatch),
              watch: isWebpackDevServer || isWatch,
              pscIde: false
            }
          }
        ]
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: [
            'es2015'
          ]
        }
      },
      { test: /favicon\.ico$/,
        loader: "file-loader?name=[path][name].[ext]&context=./src/public"
      },
      { test: /\.html$/,
        loader: "file-loader?name=[path][name].[ext]&context=./src/public"
      },
      { test: /\.md$/,
        loader: "file-loader?name=[path][name].[ext]&context=./src/public"
      }
    ]
  },

  resolve: {
    modules: [ 'node_modules', '.psc-package' ],
    // extensions: [ '.purs', '.js']
    alias: {
      config: path.resolve(__dirname, './')
    }
  },

  node: {
    fs: 'empty',
    tls: 'empty'
  },

  plugins: [
    new webpack.LoaderOptionsPlugin({
      debug: true
    }),
    new HtmlWebpackPlugin({
      title: 'Presentation Control',
      template: path.join(__dirname, "src", "control.ejs"),
      filename: 'control.html'
    }),

  ].concat(plugins)
};
