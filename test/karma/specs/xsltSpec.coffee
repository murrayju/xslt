define [
  'cs!xslt'
], (
  xslt
) ->

  describe 'xslt', ->

    it 'should exist', () ->
      expect(xslt).toBeDefined()
      expect(typeof xslt).toBe('object')
