program = require 'commander'
main    = require './main'

required = ['username', 'password']

actions =
  schedule: "Schedule a class"
  list:     "List classes"

program
  .version '0.0.1'
  .option  '-u --username <username>'
  .option  '-p --password <password>'
  .parse process.argv

return console.error "Error: no #{e}" for e in required when not program[e]

for k, v of actions
  action = program
  action = action[k] v for k, v of command: k, description: v, action: main[k]

program.parse process.argv

