/* test expect, describe, afterAll, beforeEach */

const { resolve } = require('path')
const { chdirTestApp } = require('../utils/helpers')

const rootPath = process.cwd()
chdirTestApp()

describe('Custom environment', () => {
  afterAll(() => process.chdir(rootPath))

  describe('webpackConfig', () => {
    beforeEach(() => jest.resetModules())

    test('should use staging config and default production environment', () => {
      process.env.RAILS_ENV = 'staging'
      delete process.env.NODE_ENV

      const { webpackConfig: getWebpackConfig } = require('../index')

      const webpackConfig = getWebpackConfig()

      expect(webpackConfig.output.path).toEqual(
        resolve('public', 'packs-staging')
      )
      expect(webpackConfig.output.publicPath).toEqual('/packs-staging/')
      expect(webpackConfig).toMatchObject({
        devtool: 'source-map',
        stats: 'normal'
      })
    })
  })
})
