translateHandler = require 'translateHandler'

mapHandler = (value, transform, mapFunction) ->
   result = {}
   for handler in *translateHandler(value, transform)
      import modifiers, handles, up, down from handler
      for k, v in pairs mapFunction(modifiers, handles, up, down)
         if type(k) == 'number'
            table.insert(result, v)
         else
            result[k] = v

   return result

return mapHandler
