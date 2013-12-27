URL = require 'url'
Path = require 'path'

RE =
  closingTags: /\s*(<\/\w+\s*>\s*)*$/igm
  footnotes: /<p[^>]+pnetfootnotes[^>]+>/ig
  href: /href\s*=\s*'|"([^'"]+)/
  lineBreaks: /\s*<br\s*\/?>\s*/ig
  link: /<a[^>]+>\s*([^<]+)\s*<\/a\s*>/
  newlines: /\n/
  nonWhitespace: /\S+/
  pnetset: /pnetset/
  pnetsete: /pnetsete/
  pnetSection: /(<p[^>]+pnetset[^>]+>)/ig
  segue: /<\/\w+\s*>\s*(-?>)/
  setLabels: /\s*<span[^>]+pnetsetlabel[^>]+>[^<]*<\/span\s*>\s*/ig
  spaces: /\s+/g
  supTag: /<sup[^>]*>([^<]+)<\/sup\s*>/
  tags: /(<\w+[^>]*>[^<]*<\/\w+>[^<]*)/ig

groupBySetsAndEncore = (sections) ->
  sets = []
  encore = []
  currentContext = null

  for section, i in sections
    if RE.pnetset.test(section)
      if RE.pnetsete.test(section)
        currentContext = encore
      else
        currentContext = sets
        if RE.pnetset.test(sections[i + 1])
          currentContext.push ''
    else
      currentContext.push(section)

  [sets, encore]

isSong = RegExp::test.bind(RE.link)
isSup = RegExp::test.bind(RE.supTag)

parseSegue = (tag) ->
  tag.match(RE.segue)?[1]

parseSup = (sup) ->
  sup.match(RE.supTag)[1]

parseLink = (link) ->
  href = link.match(RE.href)[1]
  title = link.match(RE.link)[1]

  url = URL.parse(href)

  song =
    id: Path.basename(url.pathname)
    title: title
    url: href

  if (segue = parseSegue(link))?
    song.segue = segue

  song

parseFootnotes = (footnotes) ->
  footnotes.replace(RE.closingTags, '').split(RE.newlines)

extractSongsFromSet = (set) ->
  songs = []

  if !(tags = set.match(RE.tags))?
    return songs

  lastSong = null

  for tag in tags
    if isSong(tag)
      lastSong = parseLink(tag)
      songs.push(lastSong)
    else if isSup(tag)
      if (segue = parseSegue(tag))?
        lastSong.segue = segue
      lastSong.notes = parseSup(tag)

  songs

exports.parse = (html = '') ->
  html = html.replace(RE.lineBreaks, '\n')
             .replace(RE.setLabels, '')

  [html, footnotes] = html.split(RE.footnotes)

  sections = html.split(RE.pnetSection)
    .filter((elem) -> RE.nonWhitespace.test(elem))

  if sections.length in [0, 1]
    return {
      sets: []
      encores: []
      footnotes: []
    }

  [sets, encores] = groupBySetsAndEncore(sections)

  parsedSets =
    if sets?.length
      extractSongsFromSet(set) for set in sets
    else
      []

  parsedEncores =
    if encores?.length
      extractSongsFromSet(encore) for encore in encores
    else
      []

  parsedFootnotes =
    if footnotes?
      parseFootnotes(footnotes)
    else
      []

  {
    sets: parsedSets
    encores: parsedEncores
    footnotes: parsedFootnotes
  }
