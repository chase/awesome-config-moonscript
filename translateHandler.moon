mod =
   meta: 'Mod4'
   alt: 'Mod1'
   ctrl: 'Control'
   shift: 'Shift'

translateHandler = (value, map, parent={})->
   -- Initialize
   result = {}
   handles = nil
   :key = parent

   valueType = type(value)
   -- Not a handler
   if valueType != 'table' and not key and valueType != 'function'
      error("Attempted to translate non-handler, #{key}: #{valueType}")

   -- Working with a child element
   if type(key) == 'string' or type(key) == 'number'
      -- There is a handler map
      if type(map) == 'table' and map[key]
         handles = map[key]
      else
         -- Assume the key IS the handled event
         handles = key

      -- Make implicit handlers explicit
      if valueType == 'function'
         if parent.implicitUp
            value = { up: value }
         else
            value = { down: value }
      elseif valueType == 'table' and type(value[1]) == 'function'
         if parent.implicitUp and not value.up
            value.up = value[1]
         elseif not value.down
            value.down = value[1]

      subresult =
         modifiers: parent.modifiers or {}
         :handles

      for subkey in *{'up', 'down'}
         -- There is a handler map override for up or down
         if type(map) == 'table' and type(map[key]) == 'table' and map[key][subkey]
            table.insert(result, {
               modifiers: parent.modifiers or {}
               handles: map[key][subkey]
               up: value[subkey]
            })
         else
            subresult[subkey] = value[subkey]

      -- Ensure that the handler isn't duplicated
      if subresult.up or subresult.down
         table.insert(result, subresult)

   -- Process children
   for subkey, value in pairs(value)
      -- Skip if not a handler
      continue  if type(value) != 'table' and type(value) != 'function'
      -- Up and down are handled explicitly above, skip them
      continue  if subkey == 'up' or subkey == 'down'

      modifiers = parent.modifiers or {}
      -- Add modifiers to parent modifiers
      if modifier = mod[subkey]
         modifiers = [v for v in *modifiers]
         table.insert(modifiers, modifier)

      for handler in *translateHandler(value,map, :modifiers, key: subkey)
         table.insert(result, handler)

   return result

return translateHandler
