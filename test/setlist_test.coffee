URL = require 'url'
Setlist = require '../lib/pnet/setlist'
{expect} = require 'chai'

halloween2013 = require('./stubs/2013-10-31')[0]
missingFirstSetShow = require('./stubs/1988-07-28')[0]
multipleEncoreShow = require('./stubs/1992-03-26')[0]
noEncoreShow = require('./stubs/1989-12-02')[0]

describe 'setlist', ->
  describe '#parse', ->
    it 'handles an empty setlist', ->
      setlistdata = "<p class='pnetset pnetset1'><span class='pnetsetlabel'>Set 1:</span> "

      expect(Setlist.parse setlistdata).to.eql
        sets: []
        encores: []
        footnotes: []

    it 'correctly parses sets, encore and footnotes', ->
      {sets, encores, footnotes} = Setlist.parse(halloween2013.setlistdata)

      expect(sets[0]).to.eql [
        {
          "id": "heavy-things"
          "title": "Heavy Things"
          "url": "http://phish.net/song/heavy-things"
        }
        {
          "id": "the-moma-dance"
          "title": "The Moma Dance"
          "url": "http://phish.net/song/the-moma-dance"
          "segue": "->"
        }
        {
          "id": "poor-heart"
          "title": "Poor Heart"
          "url": "http://phish.net/song/poor-heart"
          "segue": ">"
        }
        {
          "id": "back-on-the-train"
          "title": "Back on the Train"
          "url": "http://phish.net/song/back-on-the-train"
          "segue": ">"
        }
        {
          "id": "silent-in-the-morning"
          "title": "Silent in the Morning"
          "url": "http://phish.net/song/silent-in-the-morning"
        }
        {
          "id": "kill-devil-falls"
          "title": "Kill Devil Falls"
          "url": "http://phish.net/song/kill-devil-falls"
        }
        {
          "id": "mound"
          "title": "Mound"
          "url": "http://phish.net/song/mound"
        }
        {
          "id": "free"
          "title": "Free"
          "url": "http://phish.net/song/free"
          "segue": ">"
        }
        {
          "id": "camel-walk"
          "title": "Camel Walk"
          "url": "http://phish.net/song/camel-walk"
        }
        {
          "id": "stash"
          "title": "Stash"
          "url": "http://phish.net/song/stash"
        }
        {
          "id": "golgi-apparatus"
          "title": "Golgi Apparatus"
          "url": "http://phish.net/song/golgi-apparatus"
          "segue": ">"
        }
        {
          "id": "bathtub-gin"
          "title": "Bathtub Gin"
          "url": "http://phish.net/song/bathtub-gin"
        }
      ]

      expect(sets[1]).to.eql [
        {
          "id": "wingsuit"
          "title": "Wingsuit"
          "url": "http://phish.net/song/wingsuit"
          "notes": "[1]"
        }
        {
          "id": "fuego"
          "title": "Fuego"
          "url": "http://phish.net/song/fuego"
          "notes": "[2]"
        }
        {
          "id": "the-line"
          "title": "The Line"
          "url": "http://phish.net/song/the-line"
          "notes": "[2]"
        }
        {
          "id": "monica"
          "title": "Monica"
          "url": "http://phish.net/song/monica"
          "notes": "[3]"
        }
        {
          "id": "waiting-all-night"
          "title": "Waiting All Night"
          "url": "http://phish.net/song/waiting-all-night"
          "notes": "[2]"
        }
        {
          "id": "wombat"
          "title": "Wombat"
          "url": "http://phish.net/song/wombat"
          "notes": "[4]"
        }
        {
          "id": "snow"
          "title": "Snow"
          "url": "http://phish.net/song/snow"
          "notes": "[3]"
        }
        {
          "id": "devotion-to-a-dream"
          "title": "Devotion To A Dream"
          "url": "http://phish.net/song/devotion-to-a-dream"
          "notes": "[2]"
        }
        {
          "id": "555"
          "title": "555"
          "url": "http://phish.net/song/555"
          "segue": ">"
          "notes": "[2]"
        }
        {
          "id": "winterqueen"
          "title": "Winterqueen"
          "url": "http://phish.net/song/winterqueen"
          "notes": "[5]"
        }
        {
          "id": "amidst-the-peals-of-laughter"
          "title": "Amidst the Peals of Laughter"
          "url": "http://phish.net/song/amidst-the-peals-of-laughter"
          "notes": "[3]"
        }
        {
          "id": "you-never-know"
          "title": "You Never Know"
          "url": "http://phish.net/song/you-never-know"
          "notes": "[2]"
        }
      ]

      expect(sets[2]).to.eql [
        {
          "id": "ghost"
          "title": "Ghost"
          "url": "http://phish.net/song/ghost"
          "segue": ">"
        }
        {
          "id": "carini"
          "title": "Carini"
          "url": "http://phish.net/song/carini"
        }
        {
          "id": "birds-of-a-feather"
          "title": "Birds of a Feather"
          "url": "http://phish.net/song/birds-of-a-feather"
        }
        {
          "id": "harry-hood"
          "title": "Harry Hood"
          "url": "http://phish.net/song/harry-hood"
          "segue": ">"
        }
        {
          "id": "bug"
          "title": "Bug"
          "url": "http://phish.net/song/bug"
        }
        {
          "id": "run-like-an-antelope"
          "title": "Run Like an Antelope"
          "url": "http://phish.net/song/run-like-an-antelope"
          "notes": "[6]"
        }
      ]

      expect(encores).to.eql [
        [
          {
            "id": "quinn-the-eskimo"
            "title": "Quinn the Eskimo"
            "url": "http://phish.net/song/quinn-the-eskimo"
          }
        ]
      ]

      expect(footnotes).to.eql [
        '[1] Debut. Ended with Mike on power drill.'
        '[2] Debut.'
        '[3] Debut; Acoustic.'
        '[4] Debut; with Abe Vigoda and the Abe Vigoda Dancers.'
        '[5] Phish debut.'
        '[6] Abe Vigoda Dancers reference.'
      ]

    it "doesn't choke on a show without an encore", ->
      {encores} = Setlist.parse(noEncoreShow.setlistdata)
      expect(encores).to.eql []

    it "doesn't choke on a show without footnotes", ->
      setlistdata = "<p class='pnetset pnetset1'><span class='pnetsetlabel'>Set 1:</span> <a href=\"http://phish.net/song/big-leg-emma\">Big Leg Emma</a> "
      {footnotes} = Setlist.parse(setlistdata)

      expect(footnotes).to.eql []

    it "doesn't choke on a show missing a set", ->
      {sets} = Setlist.parse(missingFirstSetShow.setlistdata)

      # First set is empty
      expect(sets).to.eql [
        []
        [
          {
            "id": "fluffhead",
            "title": "Fluffhead",
            "url": "http://phish.net/song/fluffhead"
          },
          {
            "id": "la-grange",
            "title": "La Grange",
            "url": "http://phish.net/song/la-grange"
          },
          {
            "id": "the-lizards",
            "title": "The Lizards",
            "url": "http://phish.net/song/the-lizards"
          },
          {
            "id": "take-the-a-train",
            "title": "Take the 'A' Train",
            "url": "http://phish.net/song/take-the-a-train"
          },
          {
            "id": "corinna",
            "title": "Corinna",
            "url": "http://phish.net/song/corinna",
            "segue": ">"
          },
          {
            "id": "david-bowie",
            "title": "David Bowie",
            "url": "http://phish.net/song/david-bowie"
          },
          {
            "id": "fee",
            "title": "Fee",
            "url": "http://phish.net/song/fee"
          },
          {
            "id": "big-black-furry-creature-from-mars",
            "title": "Big Black Furry Creature from Mars",
            "url": "http://phish.net/song/big-black-furry-creature-from-mars"
          }
        ]
      ]

    it 'handles multiple encores correctly', ->
      {encores} = Setlist.parse(multipleEncoreShow.setlistdata)

      expect(encores).to.eql [
        [
          {
            "id": "sleeping-monkey",
            "title": "Sleeping Monkey",
            "url": "http://phish.net/song/sleeping-monkey"
          }
        ],
        [
          {
            "id": "chalk-dust-torture",
            "title": "Chalk Dust Torture",
            "url": "http://phish.net/song/chalk-dust-torture"
          }
        ],
        [
          {
            "id": "harpua",
            "title": "Harpua",
            "url": "http://phish.net/song/harpua",
            "notes": "[3]"
          }
        ]
      ]
