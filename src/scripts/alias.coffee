# Description:
#   Action alias for hubot
#
# Commands:
#   hubot alias xxx=yyy - Make alias xxx for yyy
#   hubot alias xxx= - Remove alias xxx for yyy
#   hubot alias clear - Clear the alias table
#
# Author:
#   dtaniwaki
#
"use strict"

ALIAS_TABLE_KEY = 'hubot-alias-table'

module.exports = (robot) ->
  receiveOrg = robot.receive
  robot.receive = (msg)->
    table = robot.brain.get(ALIAS_TABLE_KEY) || {}
    orgText = msg.text?.trim()
    if new RegExp("(^[@]?(?:#{robot.name}|#{robot.alias})[:,]?)(\\s+)([^\\s]*)(.*)$").test orgText
      name = RegExp.$1
      sp = RegExp.$2
      action = RegExp.$3
      rest = RegExp.$4
      msg.text = "#{name}#{sp}#{table[action] || action}#{rest}" if action != 'alias'
    console.log "Replace \"#{orgText}\" as \"#{msg.text}\"" if orgText != msg.text

    receiveOrg.bind(robot)(msg)

  robot.respond /alias(.*)$/i, (msg)->
    text = msg.match[1].trim()
    table = robot.brain.get(ALIAS_TABLE_KEY) || {}
    if text.toLowerCase() == 'clear'
      robot.brain.set ALIAS_TABLE_KEY, {}
      msg.send "I cleared the alias table."
    else if !text
      s = []
      for k, v of table
        s.push "#{k} : #{v}"
      msg.send "Here you go.\n#{s.join("\n")}"
    else
      match = text.match /([^\s=]*)=(.*)?$/
      alias = match[1]
      action = match[2]
      if action?
        table[alias] = action
        robot.brain.set ALIAS_TABLE_KEY, table
        msg.send "I made an alias #{alias} for \"#{action}\"."
      else
        delete table[alias]
        robot.brain.set ALIAS_TABLE_KEY, table
        msg.send "I removed the alias #{alias}."

