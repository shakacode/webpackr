/* test expect, describe, afterAll, beforeEach */

const { resolve } = require('path')
const { chdirTestApp } = require('../helpers')

const rootPath = process.cwd()
chdirTestApp()

describe('Test environment', () => {
  afterAll(() => process.chdir(rootPath))

  describe('generateWebpackConfig', () => {
    beforeEach(() => jest.resetModules())

    test('should use test config and production environment', () => {
      process.env.RAILS_ENV = 'test'
      process.env.NODE_ENV = 'test'

      const { generateWebpackConfig } = require('../../package/index')

      const webpackConfig = generateWebpackConfig()

      expect(webpackConfig.output.path).toEqual(resolve('public', 'packs-test'))
      expect(webpackConfig.output.publicPath).toEqual('/packs-test/')
      expect(webpackConfig.devServer).toEqual(undefined)
    })
  })
})