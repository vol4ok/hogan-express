var request = require("supertest");
var cheerio = require("cheerio");
var coffeescript = require("coffee-script");
var app = require("./../app.coffee");
var expect = require('expect.js');

describe("example-page", function() {
  var cheer;
  //render and parse page
  before(function(done) {
    request(app).get('/').end(function(err,res) {
      if(err) {
        console.error(err);
      }
      else {
        cheer = cheerio.load(res.text);
      }
      done();
    });
  });
  
  it("should have a body", function() {
    expect(cheer("body").length).to.be(1);
  });
  it("should have a h1 = Test", function() {
    expect(cheer("h1").text()).to.be("Test");
  });

  it("should be able to handle lambdas (reverse)", function() {
    expect(cheer("[rel='test-reverse-lambda']").text().trim()).to.be("dlroW");
  });
  it("should be able to handle lambdas within arrays (reverse)", function() {
    expect(cheer("[rel='test-reverse-lambda-with-context'] tr:first-child th").text().trim()).to.be("tsrif")
  });
  it("should be able to handle lambdas within arrays (reverse) - including 'locals' data", function() {
    expect(cheer("[rel='test-reverse-lambda-with-context'] tr:nth-child(1) td").text().trim()).to.be("atad motsuc")
    expect(cheer("[rel='test-reverse-lambda-with-context'] tr:nth-child(2) td").text().trim()).to.be("atad tluafed")
  });

  it("should be able to have more than one lambda defined", function() {
    expect(cheer("[rel='test-uppercase-lambda']").text().trim()).to.be("WORLD")
  });

  it("should be able to have nested lambdas", function() {
    expect(cheer("[rel='test-nested-lambdas']").text().trim()).to.be("DLROW")
  });

});
