translateHandler = require 'translateHandler'

mapHandler = (value, transform, mapFunction, implicitUp) ->
   result = {}
   for handler in *translateHandler(value, transform, {:implicitUp})
      import modifiers, handles, up, down from handler
      for k, v in pairs mapFunction(modifiers, handles, down, up)
         if type(k) == 'number'
            table.insert(result, v)
         else
            result[k] = v

   return result

return mapHandler
