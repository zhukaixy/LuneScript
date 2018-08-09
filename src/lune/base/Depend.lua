--lune/base/Depend.lns
local moduleObj = {}
local function _lune_nilacc( val, fieldName, access, ... )
   if not val then
      return nil
   end
   if fieldName then
      local field = val[ fieldName ]
      if not field then
         return nil
      end
      if access == "item" then
         local typeId = type( field )
         if typeId == "table" then
            return field[ ... ]
         elseif typeId == "string" then
            return string.byte( field, ... )
         end
      elseif access == "call" then
         return field( ... )
      elseif access == "callmtd" then
         return field( val, ... )
      end
      return field
   end
   if access == "item" then
      local typeId = type( val )
      if typeId == "table" then
         return val[ ... ]
      elseif typeId == "string" then
         return string.byte( val, ... )
      end
   elseif access == "call" then
      return val( ... )
   elseif access == "list" then
      local list, arg = ...
      if not list then
         return nil
      end
      return val( list, arg )
   end
   error( string.format( "illegal access -- %s", access ) )
end
function _lune_unwrap( val )
  if val == nil then
     _luneScript.error( 'unwrap val is nil' )
  end
  return val
end
function _lune_unwrapDefault( val, defval )
  if val == nil then
     return defval
  end
  return val
end

local function getFileLastModifiedTime( path )

  local file = io.open( path )
  
  do
    local _exp = file
    if _exp ~= nil then
    
        _exp:close(  )
      else
    
        return nil
      end
  end
  
  local stream = io.popen( string.format( "stat -c '%%Y' %s", path) )
  
  do
    local _exp = _lune_nilacc( stream, 'read', 'callmtd' , '*a' )
    if _exp ~= nil then
    
        return tonumber( _exp )
      end
  end
  
  return nil
end
moduleObj.getFileLastModifiedTime = getFileLastModifiedTime
return moduleObj