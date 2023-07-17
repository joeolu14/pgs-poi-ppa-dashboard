'use strict'

const { Command } = require('@adonisjs/ace')

class EtlRun extends Command {
  static get signature () {
    return 'etl:run'
  }

  static get description () {
    return 'Tell something helpful about this command'
  }

  async handle (args, options) {
    this.info('Dummy implementation for etl:run command')
  }
}

module.exports = EtlRun
