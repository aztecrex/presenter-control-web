
// all of the static assets
require.context("./public/", true)

const entry = require('./Main.purs').main;

entry()


// If hot-reloading, hook into each state change and re-render using the last
// state.
if (module.hot) {
  console.log("i am hot");
  module.hot.accept();
}
